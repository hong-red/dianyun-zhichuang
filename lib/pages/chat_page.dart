import 'package:flutter/material.dart';
import '../models/character.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';
import '../widgets/animated_character.dart';
import '../widgets/affinity_bar.dart';
import 'story_page.dart';

class ChatPage extends StatefulWidget {
  final Character character;
  final String apiKey;

  const ChatPage({
    super.key,
    required this.character,
    required this.apiKey,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late AIService _aiService;
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _affinity = 50;
  bool _isLoading = false;
  bool _isSpeaking = false;
  String _currentExpression = 'normal';

  @override
  void initState() {
    super.initState();
    _aiService = AIService(apiKey: widget.apiKey);
    _loadData();
  }

  Future<void> _loadData() async {
    // 加载好感度
    int affinity = await StorageService.getAffinity(widget.character.id);
    // 加载聊天记录
    List<ChatMessage> history = await StorageService.getChatHistory(widget.character.id);
    setState(() {
      _affinity = affinity;
      _messages.addAll(history);
    });
    // 如果没有历史消息，发送欢迎语
    if (_messages.isEmpty) {
      _addWelcomeMessage();
    }
  }

  void _addWelcomeMessage() {
    String welcome = _getWelcomeMessage();
    setState(() {
      _messages.add(ChatMessage(
        content: welcome,
        role: MessageRole.assistant,
      ));
    });
    _saveHistory();
  }

  String _getWelcomeMessage() {
    switch (widget.character.id) {
      case 'zhouyi':
        return '……来了。观复山云雾缭绕，你既寻我，想必心中有疑。不妨说说看。';
      case 'lunyu':
        return '呵呵，有朋自远方来，不亦乐乎？来，坐下聊聊。你想探讨些什么？';
      case 'shijing':
        return '你好呀……你能听到我的歌声吗？情丝花海很久没有新的访客了。';
      case 'shangshu':
        return '嗯？来者何人？……罢了，既来之，则坐。有什么话直说便是。';
      case 'zhouli':
        return '来者是传礼者？请上座。礼域议事，讲究个条理分明，有话但讲无妨。';
      case 'xiaojing':
        return '嗨！你是新来的？这里是孝域。我叫孝经，你叫什么名字？';
      default:
        return '你好，欢迎来到典籍大陆。';
    }
  }

  Future<void> _sendMessage() async {
    String text = _textController.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(ChatMessage(content: text, role: MessageRole.user));
      _isLoading = true;
      _currentExpression = 'thinking';
    });
    _textController.clear();
    _scrollToBottom();

    // AI 回复
    String reply = await _aiService.sendMessage(
      character: widget.character,
      history: _messages,
      userMessage: text,
      affinity: _affinity,
    );

    // 估算好感度变化
    int change = _aiService.estimateAffinityChange(text, reply);
    int newAffinity = _affinity + change;
    newAffinity = newAffinity.clamp(0, 100);

    setState(() {
      _messages.add(ChatMessage(content: reply, role: MessageRole.assistant));
      _affinity = newAffinity;
      _isLoading = false;
      _isSpeaking = true;
      _currentExpression = change >= 0 ? 'smile' : 'sad';
    });
    _scrollToBottom();
    _saveHistory();
    StorageService.setAffinity(widget.character.id, newAffinity);

    // 说话动画持续一段时间后停止
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _saveHistory() async {
    await StorageService.saveChatHistory(widget.character.id, _messages);
  }

  void _goToStory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoryPage(
          character: widget.character,
          initialAffinity: _affinity,
          onStoryComplete: (newAffinity) {
            setState(() {
              _affinity = newAffinity;
            });
            StorageService.setAffinity(widget.character.id, newAffinity);
          },
        ),
      ),
    );
  }

  Future<void> _clearHistory() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清除'),
        content: const Text('确定要清除对话记录和好感度吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await StorageService.clearCharacterData(widget.character.id);
              setState(() {
                _messages.clear();
                _affinity = 50;
              });
              _addWelcomeMessage();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('确定清除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Color(int.parse('FF${widget.character.primaryColor}', radix: 16));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.15),
              const Color(0xFFF5F5F5),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 顶部栏
              _buildAppBar(primaryColor),

              // 角色立绘区
              _buildCharacterArea(primaryColor),

              // 好感度条
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AffinityBar(affinity: _affinity),
              ),
              const SizedBox(height: 12),

              // 对话区
              Expanded(
                child: _buildChatArea(),
              ),

              // 输入区
              _buildInputArea(primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.character.classicName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  widget.character.roleType,
                  style: TextStyle(fontSize: 12, color: primaryColor),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onSelected: (value) {
              if (value == 'story') {
                _goToStory();
              } else if (value == 'clear') {
                _clearHistory();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'story', child: Text('进入剧情')),
              const PopupMenuItem(value: 'clear', child: Text('清除记录')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterArea(Color primaryColor) {
    return SizedBox(
      height: 180,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedCharacter(
              character: widget.character,
              height: 160,
              isSpeaking: _isSpeaking,
              isThinking: _isLoading,
              onTap: _onCharacterTap,
            ),
            // 加载状态标签
            if (_isLoading)
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '思考中…',
                        style: TextStyle(fontSize: 11, color: primaryColor),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onCharacterTap() {
    final primaryColor =
        Color(int.parse('FF${widget.character.primaryColor}', radix: 16));
    // 点击角色时显示互动气泡
    List<String> interactions = [
      '${widget.character.name}微微颔首。',
      '${widget.character.name}望向了你。',
      '${widget.character.name}似乎在等待你开口。',
      '${widget.character.name}轻轻点头。',
      '${widget.character.name}的目光落在你身上。',
    ];
    final random = (interactions..shuffle()).first;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(random),
        duration: const Duration(seconds: 1),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      ),
    );
  }

  Widget _buildChatArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: _messages.length,
          itemBuilder: (context, index) {
            return _buildMessageBubble(_messages[index]);
          },
        ),
      ),
    );
  }

  Widget _buildMiniAvatar() {
    if (widget.character.imagePath != null) {
      return CircleAvatar(
        radius: 16,
        backgroundImage: AssetImage(widget.character.imagePath!),
      );
    }
    return CircleAvatar(
      radius: 16,
      backgroundColor:
          Color(int.parse('FF${widget.character.primaryColor}', radix: 16)),
      child: Text(
        widget.character.name.substring(0, 1),
        style: const TextStyle(fontSize: 14, color: Colors.white),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    bool isUser = message.role == MessageRole.user;
    Color primaryColor = Color(int.parse('FF${widget.character.primaryColor}', radix: 16));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildMiniAvatar(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? primaryColor : Colors.grey[100],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: isUser ? const Radius.circular(14) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : const Radius.circular(14),
                ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  fontSize: 15,
                  color: isUser ? Colors.white : Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFE0E0E0),
              child: Icon(Icons.person, size: 20, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            // 剧情按钮
            IconButton(
              icon: Icon(Icons.menu_book, color: primaryColor),
              onPressed: _goToStory,
              tooltip: '进入剧情',
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(
                  hintText: '和TA聊聊吧…',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                ),
              ),
            ),
            GestureDetector(
              onTap: _isLoading ? null : _sendMessage,
              child: Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _isLoading ? Colors.grey[300] : primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
