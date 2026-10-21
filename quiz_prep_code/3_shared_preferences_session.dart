import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================================
// 🟢 [60% UNIVERSAL SKELETON] - EXACT SAME ENTRY POINT
// ============================================================================
void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: UserSessionScreen(),
  ));
}

class UserSessionScreen extends StatefulWidget {
  const UserSessionScreen({super.key});

  @override
  State<UserSessionScreen> createState() => _UserSessionScreenState();
}

class _UserSessionScreenState extends State<UserSessionScreen> {
  // ==========================================================================
  // 🔴 [40% SHAREDPREFERENCES STATE VARIABLES]
  // ==========================================================================
  final TextEditingController _usernameController = TextEditingController();
  String _savedUser = 'No user logged in';
  bool _isLoggedIn = false;

  // ==========================================================================
  // 🔴 [40% SHAREDPREFERENCES LIFECYCLE & ASYNC FUNCTIONS]
  // ==========================================================================
  @override
  void initState() {
    super.initState();
    _loadUserSession(); // Load saved preferences when the screen starts!
  }

  // 1. READ DATA (prefs.getString / getBool)
  Future<void> _loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedUser = prefs.getString('saved_user') ?? 'No user logged in';
      _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    });
  }

  // 2. WRITE DATA (prefs.setString / setBool)
  Future<void> _saveUserSession() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_user', username);
    await prefs.setBool('is_logged_in', true);

    _usernameController.clear();
    _loadUserSession(); // Refresh state so UI updates
  }

  // 3. DELETE / REMOVE DATA (prefs.remove / clear)
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_user');
    await prefs.remove('is_logged_in');

    _loadUserSession(); // Refresh state
  }

  // ==========================================================================
  // 🟢 [60% UNIVERSAL SKELETON] - SCAFFOLD + APPBAR + PADDING + COLUMN
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SharedPreferences Session'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 🔴 [40% INPUT FIELDS]
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Enter Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // 🔴 [40% ACTION BUTTONS]
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveUserSession,
                    child: const Text('Save / Login'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                    ),
                    child: const Text('Logout / Clear'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // 🔴 [40% SAVED DATA DISPLAY]
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Session Status: ${_isLoggedIn ? "LOGGED IN" : "LOGGED OUT"}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _isLoggedIn ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Saved Username: $_savedUser',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
