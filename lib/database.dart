import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ChatDatabase {

  ChatDatabase._init();
  static final ChatDatabase instance = ChatDatabase._init();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('chat.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<dynamic> _createDB(Database db, int version) async {
    const chatTable = '''
    CREATE TABLE chat_table (
      chat_id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    );
    ''';

    await db.execute(chatTable);
  }

  Future<dynamic> close() async {
    final db = await instance.database;
    await db.close();
  }
}
