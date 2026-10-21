import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.initDb();
  await DatabaseHelper.instance.initializeUsers();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Management',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const UserList(),
    );
  }
}

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final userMaps = await DatabaseHelper.instance.queryAllUsers();
    setState(() {
      _users = userMaps.map((userMap) => User.fromMap(userMap)).toList();
    });
  }

  void _showUserForm({User? user}) {
    final usernameController =
        TextEditingController(text: user?.username ?? '');
    final emailController =
        TextEditingController(text: user?.email ?? '');

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user == null ? 'Add New User' : 'Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final username = usernameController.text;
                final email = emailController.text;

                if (username.isNotEmpty && email.isNotEmpty) {
                  if (user == null) {
                    await DatabaseHelper.instance.insertUser(
                      User(username: username, email: email),
                    );
                  } else {
                    await DatabaseHelper.instance.updateUser(
                      User(id: user.id, username: username, email: email),
                    );
                  }
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                  _fetchUsers();
                }
              },
              child: Text(user == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.deleteUser(user.id!);
      _fetchUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GFG User List (CRUD)'),
        backgroundColor: Colors.lightGreen,
      ),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final currentUser = _users[index];

          return ListTile(
            title: Text(currentUser.username),
            subtitle: Text(currentUser.email),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  tooltip: 'Edit',
                  onPressed: () => _showUserForm(user: currentUser),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete',
                  onPressed: () => _deleteUser(currentUser),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addBtn',
        backgroundColor: Colors.green,
        onPressed: () => _showUserForm(),
        tooltip: 'Add User',
        child: const Icon(Icons.add),
      ),
    );
  }
}