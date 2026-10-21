import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Task 4: Persistent To-Do Notes List (List / JSON in SharedPreferences)
class Task4TodoPersistenceScreen extends StatefulWidget {
  const Task4TodoPersistenceScreen({super.key});

  @override
  State<Task4TodoPersistenceScreen> createState() => _Task4TodoPersistenceScreenState();
}

class TodoItem {
  final String id;
  final String title;
  bool isCompleted;

  TodoItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  factory TodoItem.fromMap(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}

class _Task4TodoPersistenceScreenState extends State<Task4TodoPersistenceScreen> {
  final List<TodoItem> _todoList = [];
  final TextEditingController _todoInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodoList();
  }

  @override
  void dispose() {
    _todoInputController.dispose();
    super.dispose();
  }

  // Load List from SharedPreferences
  Future<void> _loadTodoList() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('todo_items_json');
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        setState(() {
          _todoList.clear();
          _todoList.addAll(decoded.map((item) => TodoItem.fromMap(item as Map<String, dynamic>)));
        });
      } catch (e) {
        debugPrint('Error parsing stored todo items: $e');
      }
    }
  }

  // Save List to SharedPreferences
  Future<void> _saveTodoList() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> mapList = _todoList.map((item) => item.toMap()).toList();
    final String jsonString = jsonEncode(mapList);
    await prefs.setString('todo_items_json', jsonString);
  }

  void _addTodo() {
    final text = _todoInputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _todoList.add(TodoItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: text,
      ));
      _todoInputController.clear();
    });
    _saveTodoList();
  }

  void _toggleTodo(int index) {
    setState(() {
      _todoList[index].isCompleted = !_todoList[index].isCompleted;
    });
    _saveTodoList();
  }

  void _deleteTodo(int index) {
    setState(() {
      _todoList.removeAt(index);
    });
    _saveTodoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task 4: Persistent To-Do List (JSON)'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _todoInputController,
                    decoration: const InputDecoration(
                      hintText: 'Enter new task...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTodo(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _addTodo,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _todoList.isEmpty
                ? const Center(
                    child: Text(
                      'No tasks yet. Add one above to test persistence!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _todoList.length,
                    itemBuilder: (context, index) {
                      final item = _todoList[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: Checkbox(
                            value: item.isCompleted,
                            onChanged: (_) => _toggleTodo(index),
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                              color: item.isCompleted ? Colors.grey : null,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => _deleteTodo(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
