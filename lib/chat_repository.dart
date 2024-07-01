import 'package:sqflite/sqflite.dart';

class ChatRepository {
  final Database db;

  ChatRepository(this.db);

  Future<int> createChat(String name) async {
    final id = await db.insert('chat_table', {'name': name});
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

  Future<List<Map<String, dynamic>>> getChats() async {
    return await db.query('chat_table');
  }
}
