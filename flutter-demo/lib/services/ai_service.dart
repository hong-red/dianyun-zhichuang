import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/character.dart';

class AIService {
  final String apiKey;
  final String baseUrl = 'https://api.deepseek.com/v1/chat/completions';
  final String model = 'deepseek-chat';

  // 用自定义的 HttpClient，支持更长超时和坏证书容错
  static final HttpClient _httpClient = HttpClient()
    ..connectionTimeout = const Duration(seconds: 30)
    ..idleTimeout = const Duration(seconds: 30)
    ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

  late final IOClient _ioClient;

  AIService({required this.apiKey}) {
    _ioClient = IOClient(_httpClient);
  }

  // 敏感词列表（基础过滤）
  static const List<String> _sensitiveWords = [
    '暴力', '色情', '赌博', '毒品', '自杀',
    '反动', '颠覆', '分裂', '恐怖',
  ];

  // 检查敏感词
  bool containsSensitiveContent(String text) {
    for (String word in _sensitiveWords) {
      if (text.contains(word)) {
        return true;
      }
    }
    return false;
  }

  // 简单缓存
  final Map<String, String> _cache = {};

  /// 测试连接是否正常
  Future<ConnectionTestResult> testConnection() async {
    try {
      final response = await _ioClient.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': model,
          'messages': [{'role': 'user', 'content': 'hi'}],
          'max_tokens': 5,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return ConnectionTestResult(success: true, message: '连接成功！');
      } else {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final msg = data['error']?['message'] ?? '状态码 ${response.statusCode}';
        return ConnectionTestResult(success: false, message: 'API错误：$msg');
      }
    } catch (e) {
      return ConnectionTestResult(
        success: false,
        message: '连接失败：${e.toString()}',
      );
    }
  }

  Future<String> sendMessage({
    required Character character,
    required List<ChatMessage> history,
    required String userMessage,
    required int affinity,
  }) async {
    // 检查输入敏感词
    if (containsSensitiveContent(userMessage)) {
      return '这个话题……不太适合讨论呢。我们聊点别的吧。';
    }

    // 检查缓存（简单的精确匹配）
    String cacheKey = '${character.id}_$userMessage';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    // 构建消息列表
    List<Map<String, dynamic>> messages = [];

    // System prompt
    String affinityDescription = _getAffinityDescription(affinity);
    String systemPrompt = character.systemPrompt;
    systemPrompt += '\n\n【当前好感度】$affinity / 100（$affinityDescription）';
    systemPrompt += '\n请根据当前好感度调整回复的亲疏程度。';
    systemPrompt += '\n请用简洁的语言回复，控制在100字以内。';

    messages.add({'role': 'system', 'content': systemPrompt});

    // 历史消息（最近 8 轮，减少 token 占用）
    int startIndex = history.length > 16 ? history.length - 16 : 0;
    for (int i = startIndex; i < history.length; i++) {
      if (history[i].role != MessageRole.system) {
        messages.add(history[i].toJson());
      }
    }

    // 当前用户消息
    messages.add({'role': 'user', 'content': userMessage});

    // 最多重试 2 次
    int maxRetries = 2;
    String lastError = '';

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final response = await _ioClient.post(
          Uri.parse(baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            'model': model,
            'messages': messages,
            'temperature': 0.8,
            'max_tokens': 200,
            'top_p': 0.9,
          }),
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          String reply = data['choices'][0]['message']['content'] as String;
          reply = reply.trim();

          // 输出敏感词检查
          if (containsSensitiveContent(reply)) {
            reply = '嗯……这个话题，我们还是换一个吧。';
          }

          // 存入缓存
          _cache[cacheKey] = reply;
          if (_cache.length > 100) {
            _cache.remove(_cache.keys.first);
          }

          return reply;
        } else {
          // 4xx 错误不重试（除了 429 限流）
          if (response.statusCode >= 400 && response.statusCode < 500 && response.statusCode != 429) {
            final errorData = jsonDecode(utf8.decode(response.bodyBytes));
            final errorMsg = errorData['error']?['message'] ?? '状态码：${response.statusCode}';
            return '（API 错误）\n$errorMsg';
          }
          lastError = '状态码：${response.statusCode}';
          // 5xx 或 429 重试
          await Future.delayed(Duration(seconds: 1 + attempt));
        }
      } catch (e) {
        String errorMsg = e.toString();
        lastError = errorMsg;

        // 最后一次重试失败，返回详细错误
        if (attempt == maxRetries) {
          if (errorMsg.contains('timeout') || errorMsg.contains('Timeout')) {
            return '（网络超时）\n请求超时了，请检查网络后重试。\n\n详细信息：${errorMsg.substring(0, errorMsg.length > 80 ? 80 : errorMsg.length)}';
          }
          if (errorMsg.contains('SocketException') ||
              errorMsg.contains('Connection') ||
              errorMsg.contains('Failed host lookup') ||
              errorMsg.contains('HandshakeException')) {
            return '（无法连接服务器）\n请检查：\n1. 手机网络是否正常\n2. 是否能访问 api.deepseek.com\n3. 是否使用了代理/VPN\n\n详细信息：${errorMsg.substring(0, errorMsg.length > 100 ? 100 : errorMsg.length)}';
          }
          return '（出错了）\n$errorMsg';
        }

        // 重试前等待
        await Future.delayed(Duration(seconds: 1 + attempt * 2));
      }
    }

    return '（连接失败）\n重试了 ${maxRetries + 1} 次都没有成功。\n最后错误：${lastError.substring(0, lastError.length > 60 ? 60 : lastError.length)}';
  }

  String _getAffinityDescription(int affinity) {
    if (affinity >= 80) return '挚友';
    if (affinity >= 60) return '友好';
    if (affinity >= 30) return '中立';
    return '冷淡';
  }

  // 根据对话内容简单估算好感度变化
  int estimateAffinityChange(String userMessage, String aiReply) {
    int change = 0;

    // 礼貌用语 +1
    List<String> politeWords = ['您好', '你好', '请问', '谢谢', '感谢', '麻烦', '请', '对不起', '抱歉'];
    for (var word in politeWords) {
      if (userMessage.contains(word)) {
        change += 1;
        break;
      }
    }

    // 表达喜欢/赞赏 +2
    List<String> likeWords = ['喜欢', '欣赏', '厉害', '棒', '好棒', '佩服', '赞', '仰慕'];
    for (var word in likeWords) {
      if (userMessage.contains(word)) {
        change += 2;
        break;
      }
    }

    // 无礼/冒犯 -2
    List<String> rudeWords = ['笨蛋', '蠢货', '垃圾', '讨厌', '滚', '白痴'];
    for (var word in rudeWords) {
      if (userMessage.contains(word)) {
        change -= 2;
        break;
      }
    }

    return change;
  }
}

class ConnectionTestResult {
  final bool success;
  final String message;

  ConnectionTestResult({required this.success, required this.message});
}
