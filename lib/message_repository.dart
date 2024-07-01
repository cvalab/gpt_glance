import 'package:sqflite/sqflite.dart';

class MessageRepository {
  final Database db;

  MessageRepository(this.db);

  Future<int> addMessage({
    required int chatId,
    required String message,
    required bool isBot,
  }) async {
    final tableName = 'message_table_$chatId';
    return await db.insert(tableName, {
      'text': message,
      'is_bot': isBot ? 1 : 0,
      'time': '${DateTime.now().hour}:${DateTime.now().minute}',
    });
  }

  Future<List<Map<String, dynamic>>> getMessages(int chatId) async {
    final tableName = 'message_table_$chatId';
    return await db.query(tableName);
  }

  Future<void> deleteMessage(int chatId, int messageId) async {
    final tableName = 'message_table_$chatId';
    await db.delete(tableName, where: 'id = ?', whereArgs: [messageId]);
  }
}
