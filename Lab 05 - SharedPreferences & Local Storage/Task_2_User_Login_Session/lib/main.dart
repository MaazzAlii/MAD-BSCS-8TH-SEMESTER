import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Task2LoginApp(),
  ));
}

class Task2LoginApp extends StatefulWidget {
  const Task2LoginApp({super.key});

  @override
  State<Task2LoginApp> createState() => _Task2LoginAppState();
}

class _Task2LoginAppState extends State<Task2LoginApp> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _rememberMe = false;
  bool _isLoggedIn = false;
  String _savedUser = '';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      _savedUser = prefs.getString('saved_username') ?? '';
      _rememberMe = prefs.getBool('remember_me') ?? false;

      if (_rememberMe && _savedUser.isNotEmpty) {
        _usernameController.text = _savedUser;
      }
    });
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter username and password')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('saved_username', username);
    await prefs.setBool('remember_me', _rememberMe);

    setState(() {
      _isLoggedIn = true;
      _savedUser = username;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome, $username! Session saved in SharedPreferences.')),
      );
    }
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    if (!_rememberMe) {
      await prefs.remove('saved_username');
      _usernameController.clear();
    }
    _passwordController.clear();

    setState(() {
      _isLoggedIn = false;
      _savedUser = '';
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out! Session cleared from SharedPreferences.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task 2: Login & Session State'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _isLoggedIn ? _buildLoggedInView() : _buildLoginForm(),
        ),
      ),
    );
  }

  Widget _buildLoggedInView() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.indigo,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'Session Active!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'User: $_savedUser',
              style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Session is persistently stored in SharedPreferences.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.lock_outline, size: 50, color: Colors.indigo),
            const SizedBox(height: 12),
            const Text(
              'User Login',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Remember Me'),
              value: _rememberMe,
              onChanged: (val) => setState(() => _rememberMe = val ?? false),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Login & Save Session', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
