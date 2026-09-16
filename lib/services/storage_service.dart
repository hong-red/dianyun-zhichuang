import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';

class StorageService {
  static const String _keyAffinityPrefix = 'affinity_';
  static const String _keyChatHistoryPrefix = 'chat_history_';
  static const String _keyStoryProgressPrefix = 'story_progress_';
  static const String _keyLastCharacter = 'last_character';

  // 获取好感度
  static Future<int> getAffinity(String characterId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_keyAffinityPrefix$characterId') ?? 50;
  }

  // 设置好感度
  static Future<void> setAffinity(String characterId, int value) async {
    final prefs = await SharedPreferences.getInstance();
    value = value.clamp(0, 100);
    await prefs.setInt('$_keyAffinityPrefix$characterId', value);
  }

  // 增加好感度
  static Future<int> addAffinity(String characterId, int delta) async {
    int current = await getAffinity(characterId);
    int newValue = (current + delta).clamp(0, 100);
    await setAffinity(characterId, newValue);
    return newValue;
  }

  // 获取聊天记录
  static Future<List<ChatMessage>> getChatHistory(String characterId) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonStr = prefs.getString('$_keyChatHistoryPrefix$characterId');
    if (jsonStr == null) return [];
    List<dynamic> list = jsonDecode(jsonStr);
    return list.map((e) => ChatMessage.fromJson(e)).toList();
  }

  // 保存聊天记录
  static Future<void> saveChatHistory(String characterId, List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    // 只保存最近 50 条
    if (messages.length > 50) {
      messages = messages.sublist(messages.length - 50);
    }
    String jsonStr = jsonEncode(messages.map((e) => {
      'role': e.role == MessageRole.user ? 'user' : 'assistant',
      'content': e.content,
      'timestamp': e.timestamp.toIso8601String(),
    }).toList());
    await prefs.setString('$_keyChatHistoryPrefix$characterId', jsonStr);
  }

  // 获取剧情进度
  static Future<String?> getStoryProgress(String characterId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_keyStoryProgressPrefix$characterId');
  }

  // 保存剧情进度
  static Future<void> saveStoryProgress(String characterId, String nodeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_keyStoryProgressPrefix$characterId', nodeId);
  }

  // 获取上次选择的角色
  static Future<String?> getLastCharacter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastCharacter);
  }

  // 保存上次选择的角色
  static Future<void> setLastCharacter(String characterId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastCharacter, characterId);
  }

  // 清除所有数据
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // 清除单个角色数据
  static Future<void> clearCharacterData(String characterId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyAffinityPrefix$characterId');
    await prefs.remove('$_keyChatHistoryPrefix$characterId');
    await prefs.remove('$_keyStoryProgressPrefix$characterId');
  }
}
