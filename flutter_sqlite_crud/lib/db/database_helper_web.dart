import '../user.dart';

/// Web implementation of DatabaseHelper using an in-memory list.
/// Data lives for the duration of the browser session.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  final List<Map<String, dynamic>> _users = [];
  int _nextId = 1;

  DatabaseHelper._init();

  /// No-op on web — no real DB to open.
  Future<void> initDb() async {}

  Future<int> insertUser(User user) async {
    try {
      final id = _nextId++;
      _users.add({
        'id': id,
        'username': user.username,
        'email': user.email,
      });
      return id;
    } catch (e) {
      throw Exception('Failed to insert user: $e');
    }
  }

  Future<List<Map<String, dynamic>>> queryAllUsers() async {
    try {
      return List<Map<String, dynamic>>.from(_users);
    } catch (e) {
      throw Exception('Failed to query users: $e');
    }
  }

  Future<void> updateUser(User user) async {
    try {
      final idx = _users.indexWhere((u) => u['id'] == user.id);
      if (idx != -1) {
        _users[idx] = {
          'id': user.id,
          'username': user.username,
          'email': user.email,
        };
      }
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      _users.removeWhere((u) => u['id'] == id);
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  Future<void> initializeUsers() async {
    if (_users.isEmpty) {
      await insertUser(User(username: 'John', email: 'john@example.com'));
      await insertUser(User(username: 'Jane', email: 'jane@example.com'));
      await insertUser(User(username: 'Alice', email: 'alice@example.com'));
      await insertUser(User(username: 'Bob', email: 'bob@example.com'));
    }
  }

  /// No-op on web — nothing to dispose.
  void close() {}
}
