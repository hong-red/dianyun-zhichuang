import 'package:flutter/material.dart';
import '../models/character.dart';
import '../models/story.dart';
import '../data/stories.dart';
import '../widgets/character_avatar.dart';
import '../widgets/affinity_bar.dart';

class StoryPage extends StatefulWidget {
  final Character character;
  final int initialAffinity;
  final Function(int newAffinity) onStoryComplete;

  const StoryPage({
    super.key,
    required this.character,
    required this.initialAffinity,
    required this.onStoryComplete,
  });

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  late Story _story;
  late StoryNode _currentNode;
  late int _affinity;
  bool _isTyping = false;
  String _displayedText = '';
  bool _showChoices = false;
  bool _isEnding = false;

  @override
  void initState() {
    super.initState();
    _affinity = widget.initialAffinity;
    Story? story = getStoryByCharacterId(widget.character.id);
    if (story != null) {
      _story = story;
      _currentNode = story.nodes[story.startNodeId]!;
      _startTyping();
    }
  }

  void _startTyping() {
    setState(() {
      _isTyping = true;
      _displayedText = '';
      _showChoices = false;
    });

    String fullText = _currentNode.text;
    int charIndex = 0;

    void typeChar() {
      if (charIndex < fullText.length) {
        setState(() {
          _displayedText += fullText[charIndex];
        });
        charIndex++;
        Future.delayed(const Duration(milliseconds: 30), typeChar);
      } else {
        setState(() {
          _isTyping = false;
          _isEnding = _currentNode.isEnding;
          if (_currentNode.choices.isNotEmpty) {
            _showChoices = true;
          }
        });
      }
    }

    typeChar();
  }

  void _skipTyping() {
    if (_isTyping) {
      setState(() {
        _displayedText = _currentNode.text;
        _isTyping = false;
        _isEnding = _currentNode.isEnding;
        if (_currentNode.choices.isNotEmpty) {
          _showChoices = true;
        }
      });
    } else if (_currentNode.choices.isEmpty && !_currentNode.isEnding) {
      // 无选项且不是结局，点击继续（一般不会出现，因为每个节点都有选项或结局）
    }
  }

  void _makeChoice(StoryChoice choice) {
    setState(() {
      _affinity = (_affinity + choice.affinityChange).clamp(0, 100);
      _currentNode = _story.nodes[choice.nextNodeId]!;
      _showChoices = false;
    });
    _startTyping();
  }

  void _finishStory() {
    widget.onStoryComplete(_affinity);
    Navigator.pop(context);
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
              primaryColor.withOpacity(0.2),
              primaryColor.withOpacity(0.05),
              const Color(0xFF1a1a2e),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 顶部栏
              _buildAppBar(primaryColor),

              // 好感度条
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: AffinityBar(affinity: _affinity, showLabel: true),
              ),

              // 角色立绘
              Expanded(
                flex: 2,
                child: Center(
                  child: CharacterAvatar(character: widget.character, size: 100),
                ),
              ),

              // 对话框
              Expanded(
                flex: 3,
                child: _buildDialogBox(primaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () {
              widget.onStoryComplete(_affinity);
              Navigator.pop(context);
            },
          ),
          Expanded(
            child: Center(
              child: Text(
                _story.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildDialogBox(Color primaryColor) {
    return GestureDetector(
      onTap: _skipTyping,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 说话者
            if (_currentNode.speaker != '旁白')
              Row(
                children: [
                  CharacterAvatar(character: widget.character, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    _currentNode.speaker,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              )
            else
              Text(
                _currentNode.speaker,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 12),

            // 对话内容
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _displayedText,
                  style: TextStyle(
                    fontSize: 16,
                    color: _currentNode.speaker == '旁白' ? Colors.grey[700] : Colors.black87,
                    height: 1.6,
                    fontStyle: _currentNode.speaker == '旁白' ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ),
            ),

            // 选项或提示
            if (_showChoices && _currentNode.choices.isNotEmpty)
              ..._buildChoices(primaryColor)
            else if (_isEnding)
              _buildEndingButton(primaryColor)
            else if (_isTyping)
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  '点击跳过',
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildChoices(Color primaryColor) {
    return [
      const SizedBox(height: 12),
      ..._currentNode.choices.asMap().entries.map((entry) {
        int index = entry.key;
        StoryChoice choice = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => _makeChoice(choice),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: primaryColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      choice.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  Icon(
                    choice.affinityChange > 0
                        ? Icons.favorite
                        : choice.affinityChange < 0
                            ? Icons.heart_broken
                            : Icons.horizontal_rule,
                    size: 16,
                    color: choice.affinityChange > 0
                        ? Colors.redAccent
                        : choice.affinityChange < 0
                            ? Colors.grey
                            : Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    ];
  }

  Widget _buildEndingButton(Color primaryColor) {
    String endingText = '';
    IconData endingIcon = Icons.auto_awesome;
    if (_currentNode.endingType == 'good') {
      endingText = '圆满结局';
      endingIcon = Icons.star;
    } else if (_currentNode.endingType == 'bad') {
      endingText = '遗憾结局';
      endingIcon = Icons.sentiment_dissatisfied;
    } else {
      endingText = '故事暂告一段落';
      endingIcon = Icons.menu_book;
    }

    return Column(
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(endingIcon, size: 16, color: primaryColor),
                const SizedBox(width: 6),
                Text(
                  endingText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _finishStory,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('返回对话'),
          ),
        ),
      ],
    );
  }
}
