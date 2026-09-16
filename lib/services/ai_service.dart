import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';
import '../models/character.dart';

class AIService {
  final String apiKey;
  final String baseUrl = 'https://api.deepseek.com/v1/chat/completions';
  final String model = 'deepseek-chat';

  AIService({required this.apiKey});

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

    messages.add({'role': 'system', 'content': systemPrompt});

    // 历史消息（最近 10 轮）
    int startIndex = history.length > 20 ? history.length - 20 : 0;
    for (int i = startIndex; i < history.length; i++) {
      if (history[i].role != MessageRole.system) {
        messages.add(history[i].toJson());
      }
    }

    // 当前用户消息
    messages.add({'role': 'user', 'content': userMessage});

    try {
      final response = await http.post(
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
      ).timeout(const Duration(seconds: 15));

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
        return '抱歉，我现在有点走神了……能再说一遍吗？';
      }
    } catch (e) {
      return '……（似乎在沉思中，没有回应）';
    }
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
