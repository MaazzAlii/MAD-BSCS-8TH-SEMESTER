// SQLite database 
// Handles database creation 
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/content_item.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  final List<ContentItem> _webStore = [
    ContentItem(id: 1, title: 'Flutter 3.0 Full Roadmap', platform: 'YouTube', views: 15400),
    ContentItem(id: 2, title: 'Top 5 VS Code Shortcuts', platform: 'TikTok', views: 8200),
    ContentItem(id: 3, title: 'UI Design Tips for Devs', platform: 'Instagram', views: 4300),
  ];
  int _webId = 4;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('content_creator.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        platform TEXT NOT NULL,
        views INTEGER NOT NULL
      )
    ''');

    for (var item in _webStore) {
      await db.insert('contents', item.toMap());
    }
  }

  Future<int> insertContent(ContentItem item) async {
    if (kIsWeb) {
      final newItem = item.copyWith(id: _webId++);
      _webStore.insert(0, newItem);
      return newItem.id!;
    }
    final db = await database;
    return await db.insert('contents', item.toMap());
  }

  Future<List<ContentItem>> getContents() async {
    if (kIsWeb) {
      return List<ContentItem>.from(_webStore);
    }
    final db = await database;
    final result = await db.query('contents', orderBy: 'id DESC');
    return result.map((map) => ContentItem.fromMap(map)).toList();
  }

  Future<int> deleteContent(int id) async {
    if (kIsWeb) {
      _webStore.removeWhere((item) => item.id == id);
      return 1;
    }
    final db = await database;
    return await db.delete(
      'contents',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
