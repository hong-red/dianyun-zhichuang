enum MessageRole { user, assistant, system }

class ChatMessage {
  final String content;
  final MessageRole role;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.role,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'role': role == MessageRole.user ? 'user' : role == MessageRole.assistant ? 'assistant' : 'system',
      'content': content,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      content: json['content'] as String,
      role: json['role'] == 'user' ? MessageRole.user : json['role'] == 'assistant' ? MessageRole.assistant : MessageRole.system,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toString()),
    );
  }
}
