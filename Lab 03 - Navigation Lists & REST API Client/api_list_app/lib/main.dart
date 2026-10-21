import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Local JSON Server Base URL for Web
const String apiBaseUrl = 'http://localhost:3000';

void main() => runApp(const StudentApp());

class StudentApp extends StatelessWidget {
  const StudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Student CRUD App',
      debugShowCheckedModeBanner: false,
      home: StudentListScreen(),
    );
  }
}

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  late Future<List<dynamic>> futureStudents;
  List<dynamic> _students = []; // cached list to calculate next ID

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  // Data load ya refresh karne ke liye
  void loadStudents() {
    setState(() {
      futureStudents = fetchStudents();
    });
  }

  // 1. READ: Fetch students from API (/students endpoint)
  Future<List<dynamic>> fetchStudents() async {
    final response = await http.get(Uri.parse('$apiBaseUrl/students'));
    if (response.statusCode == 200) {
      _students = jsonDecode(response.body); // cache for ID calculation
      return _students;
    } else {
      throw Exception('Failed to load students');
    }
  }

  // Calculate next integer ID (max existing ID + 1)
  int _nextId() {
    if (_students.isEmpty) return 1;
    final maxId = _students
        .map((s) => int.tryParse(s['id'].toString()) ?? 0)
        .reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  // 2. CREATE: Add new student (json-server v0 auto-increments id)
  Future<void> createStudent(String name, String email, String course) async {
    await http.post(
      Uri.parse('$apiBaseUrl/students'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'name': name, 'email': email, 'course': course}),
    );
    loadStudents();
  }


  // 3. UPDATE: Edit existing student
  Future<void> updateStudent(dynamic id, String name, String email, String course) async {
    await http.put(
      Uri.parse('$apiBaseUrl/students/$id'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'id': id, 'name': name, 'email': email, 'course': course}),
    );
    loadStudents();
  }

  // 4. DELETE: Remove student
  Future<void> deleteStudent(dynamic id) async {
    await http.delete(Uri.parse('$apiBaseUrl/students/$id'));
    loadStudents();
  }

  // Add ya Edit ke liye Popup Dialog
  void _showStudentDialog({Map<String, dynamic>? student}) {
    final nameController = TextEditingController(text: student != null ? student['name'] : '');
    final emailController = TextEditingController(text: student != null ? student['email'] : '');
    final courseController = TextEditingController(text: student != null ? student['course'] : '');
    bool isEditing = student != null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Student' : 'Add New Student'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Student Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: courseController,
                decoration: const InputDecoration(labelText: 'Course'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  emailController.text.isNotEmpty &&
                  courseController.text.isNotEmpty) {
                if (isEditing) {
                  updateStudent(
                    student['id'],
                    nameController.text,
                    emailController.text,
                    courseController.text,
                  );
                } else {
                  createStudent(
                    nameController.text,
                    emailController.text,
                    courseController.text,
                  );
                }
                Navigator.pop(context);
              }
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Management (CRUD)'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futureStudents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            final students = snapshot.data!;
            if (students.isEmpty) {
              return const Center(child: Text('No students found'));
            }

            return ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final item = students[index];

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 3,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo.shade100,
                      child: Text('${item['id']}'),
                    ),
                    title: Text(
                      item['name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Email: ${item['email']}\nCourse: ${item['course']}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showStudentDialog(student: item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteStudent(item['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text('No data found'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStudentDialog(),
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}