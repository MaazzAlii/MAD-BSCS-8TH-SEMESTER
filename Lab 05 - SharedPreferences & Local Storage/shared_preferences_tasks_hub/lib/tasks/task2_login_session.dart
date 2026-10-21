import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Task 2: Login Session & "Remember Me" Persistence using SharedPreferences
class Task2LoginScreen extends StatefulWidget {
  const Task2LoginScreen({super.key});

  @override
  State<Task2LoginScreen> createState() => _Task2LoginScreenState();
}

class _Task2LoginScreenState extends State<Task2LoginScreen> {
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

  // Load session from SharedPreferences
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

  // Save session to SharedPreferences
  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both username and password')),
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
        SnackBar(content: Text('Welcome back, $username! Session saved.')),
      );
    }
  }

  // Clear session from SharedPreferences
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
        const SnackBar(content: Text('Logged out successfully! Session cleared.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task 2: Login & Session State'),
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
              'Active Session Found!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Logged in as: $_savedUser',
              style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your login state is stored in SharedPreferences and survives app restarts.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout & Clear Session'),
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
              'User Login & Session',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username or Email',
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
              title: const Text('Remember Me (Persist Username)'),
              value: _rememberMe,
              onChanged: (val) {
                setState(() {
                  _rememberMe = val ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Login & Save Session', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
