import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:path/path.dart' as p;
import '../user.dart';

/// Native implementation of DatabaseHelper using sqlite3 via dart:ffi.
/// Works on Windows, Android, iOS, Linux, and macOS.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gfg_users.db');
    return _database!;
  }

  /// Explicitly initializes the database. Called from [main] before [runApp].
  Future<void> initDb() async {
    await database;
  }

  Future<Database> _initDB(String fileName) async {
    String path;
    if (kIsWeb) {
      // Fallback — should never reach here on native, but kept for safety.
      return sqlite3.open(':memory:');
    } else {
      final directory = await getApplicationDocumentsDirectory();
      path = p.join(directory.path, fileName);
    }

    final db = sqlite3.open(path);

    db.execute('''
      CREATE TABLE IF NOT EXISTS gfg_users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email    TEXT NOT NULL
      );
    ''');

    return db;
  }

  Future<int> insertUser(User user) async {
    try {
      final db = await database;
      final stmt = db.prepare(
          'INSERT INTO gfg_users (username, email) VALUES (?, ?);');
      stmt.execute([user.username, user.email]);
      stmt.dispose();
      final rs = db.select('SELECT last_insert_rowid();');
      return rs.first.values.first as int;
    } catch (e) {
      throw Exception('Failed to insert user: $e');
    }
  }

  Future<List<Map<String, dynamic>>> queryAllUsers() async {
    try {
      final db = await database;
      final resultSet = db.select('SELECT * FROM gfg_users;');
      return resultSet
          .map((row) => {
                'id': row['id'],
                'username': row['username'],
                'email': row['email'],
              })
          .toList();
    } catch (e) {
      throw Exception('Failed to query users: $e');
    }
  }

  Future<void> updateUser(User user) async {
    try {
      final db = await database;
      final stmt = db.prepare(
          'UPDATE gfg_users SET username = ?, email = ? WHERE id = ?;');
      stmt.execute([user.username, user.email, user.id]);
      stmt.dispose();
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      final db = await database;
      final stmt = db.prepare('DELETE FROM gfg_users WHERE id = ?;');
      stmt.execute([id]);
      stmt.dispose();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  Future<void> initializeUsers() async {
    final existing = await queryAllUsers();
    if (existing.isEmpty) {
      await insertUser(User(username: 'John', email: 'john@example.com'));
      await insertUser(User(username: 'Jane', email: 'jane@example.com'));
      await insertUser(User(username: 'Alice', email: 'alice@example.com'));
      await insertUser(User(username: 'Bob', email: 'bob@example.com'));
    }
  }

  /// Closes the database connection and releases native resources.
  void close() {
    _database?.dispose();
    _database = null;
  }
}
