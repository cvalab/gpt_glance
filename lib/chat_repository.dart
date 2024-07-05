import 'package:sqflite/sqflite.dart';

class ChatRepository {
  ChatRepository(this.db);
  final Database db;

  Future<int> createChat(String name) async {
    final id = await db.insert('chat_table', {'name': name, 'isRenamed': 0});
    await _createMessageTableForChat(id);
    return id;
  }

  Future<void> _createMessageTableForChat(int chatId) async {
    final tableName = 'message_table_$chatId';
    final messageTable = '''
    CREATE TABLE $tableName (
      message_id INTEGER PRIMARY KEY AUTOINCREMENT,
      text TEXT,
      is_bot INTEGER,
      time TEXT
    );
    ''';
    await db.execute(messageTable);
  }

  Future<List<Map<String, dynamic>>> getChats() {
    return db.query('chat_table');
  }

  Future<void> renameChat(int chatId, String newName) async {
    await db.update(
      'chat_table',
      {'name': newName, 'isRenamed': 1},
      where: 'chat_id = ?',
      whereArgs: [chatId],
    );
  }

  Future<void> deleteChat(int chatId) async {
    await db.delete(
      'chat_table',
      where: 'chat_id = ?',
      whereArgs: [chatId],
    );
    final tableName = 'message_table_$chatId';
    await db.execute('DROP TABLE IF EXISTS $tableName');
  }
}
