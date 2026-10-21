import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// ============================================================================
// 🎓 WHY IS SQFLITE DIFFERENT?
// SQFLite is a local SQL database. On paper exams, professors usually ask:
// "Write a DatabaseHelper class to perform CRUD operations on a Student table."
// Part 1 is the PURE DART Helper class (Singleton + CRUD).
// Part 2 is the standard Flutter UI Screen (60% Universal Skeleton).
// ============================================================================

// ============================================================================
// 🔴 [PART 1: DATABASE HELPER SINGLETON - CRUD ENGINE]
// ============================================================================
class DatabaseHelper {
  // A. Singleton instance & private constructor
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  // B. Database Getter
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('students.db');
    return _database!;
  }

  // C. Open / Create Database File
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // D. Create Table
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        rollNo TEXT NOT NULL
      )
    ''');
  }

  // ==========================================================================
  // E. THE 4 CRUD METHODS (Create, Read, Update, Delete)
  // ==========================================================================

  // [C] CREATE / INSERT
  Future<int> insertStudent(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('students', row);
  }

  // [R] READ / QUERY ALL
  Future<List<Map<String, dynamic>>> queryAllStudents() async {
    final db = await database;
    return await db.query('students');
  }

  // [U] UPDATE
  Future<int> updateStudent(Map<String, dynamic> row) async {
    final db = await database;
    int id = row['id'];
    return await db.update(
      'students',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // [D] DELETE
  Future<int> deleteStudent(int id) async {
    final db = await database;
    return await db.delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

// ============================================================================
// 🟢 [PART 2: 60% UNIVERSAL SKELETON UI SCREEN]
// ============================================================================
void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SqliteStudentScreen(),
  ));
}

class SqliteStudentScreen extends StatefulWidget {
  const SqliteStudentScreen({super.key});

  @override
  State<SqliteStudentScreen> createState() => _SqliteStudentScreenState();
}

class _SqliteStudentScreenState extends State<SqliteStudentScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rollController = TextEditingController();
  List<Map<String, dynamic>> _studentList = [];

  @override
  void initState() {
    super.initState();
    _refreshStudentList();
  }

  // Calling [R] Read
  Future<void> _refreshStudentList() async {
    final data = await DatabaseHelper.instance.queryAllStudents();
    setState(() {
      _studentList = data;
    });
  }

  // Calling [C] Insert
  Future<void> _addStudent() async {
    if (_nameController.text.isEmpty || _rollController.text.isEmpty) return;
    await DatabaseHelper.instance.insertStudent({
      'name': _nameController.text.trim(),
      'rollNo': _rollController.text.trim(),
    });
    _nameController.clear();
    _rollController.clear();
    _refreshStudentList();
  }

  // Calling [D] Delete
  Future<void> _deleteStudent(int id) async {
    await DatabaseHelper.instance.deleteStudent(id);
    _refreshStudentList();
  }

  // 🟢 Standard Scaffold & AppBar
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQFLite Student CRUD'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Student Name'),
            ),
            TextField(
              controller: _rollController,
              decoration: const InputDecoration(labelText: 'Roll Number'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _addStudent,
              child: const Text('Add Student (Insert)'),
            ),
            const Divider(height: 30),
            Expanded(
              child: _studentList.isEmpty
                  ? const Center(child: Text('No students in database'))
                  : ListView.builder(
                      itemCount: _studentList.length,
                      itemBuilder: (context, index) {
                        final student = _studentList[index];
                        return ListTile(
                          title: Text(student['name']),
                          subtitle: Text('Roll: ${student['rollNo']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteStudent(student['id']),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
