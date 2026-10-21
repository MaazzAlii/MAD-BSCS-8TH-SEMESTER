import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Task 3: Multi-Type Data & Counter Persistence using SharedPreferences
class Task3ProfileCounterScreen extends StatefulWidget {
  const Task3ProfileCounterScreen({super.key});

  @override
  State<Task3ProfileCounterScreen> createState() => _Task3ProfileCounterScreenState();
}

class _Task3ProfileCounterScreenState extends State<Task3ProfileCounterScreen> {
  int _counter = 0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  double _volumeLevel = 50.0;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadAllPreferences();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // 1. Load data from SharedPreferences
  Future<void> _loadAllPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = prefs.getInt('persistent_counter') ?? 0;
      _nameController.text = prefs.getString('user_name') ?? '';
      _emailController.text = prefs.getString('user_email') ?? '';
      _volumeLevel = prefs.getDouble('volume_level') ?? 50.0;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  // 2. Increment and save counter
  Future<void> _incrementCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter++;
    });
    await prefs.setInt('persistent_counter', _counter);
  }

  // 3. Reset counter
  Future<void> _resetCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = 0;
    });
    await prefs.setInt('persistent_counter', 0);
  }

  // 4. Save form settings
  Future<void> _saveProfileSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text.trim());
    await prefs.setString('user_email', _emailController.text.trim());
    await prefs.setDouble('volume_level', _volumeLevel);
    await prefs.setBool('notifications_enabled', _notificationsEnabled);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved to SharedPreferences!')),
      );
    }
  }

  // 5. Clear all stored keys
  Future<void> _clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _loadAllPreferences();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All SharedPreferences data cleared!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task 3: Profile & Counter (All Data Types)'),
        actions: [
          IconButton(
            tooltip: 'Clear All Data',
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearAll,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Persistent Counter Section
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Persistent Counter (Type: int)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_counter',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _incrementCounter,
                          icon: const Icon(Icons.add),
                          label: const Text('Increment'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: _resetCounter,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reset'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Profile Form (Strings, Double, Bool)
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'User Settings (String, Double, Bool)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name (String)',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address (String)',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Volume Level (Double): ${_volumeLevel.toStringAsFixed(0)}%'),
                    Slider(
                      value: _volumeLevel,
                      min: 0,
                      max: 100,
                      divisions: 20,
                      label: _volumeLevel.round().toString(),
                      onChanged: (val) {
                        setState(() {
                          _volumeLevel = val;
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Enable Notifications (Bool)'),
                      value: _notificationsEnabled,
                      onChanged: (val) {
                        setState(() {
                          _notificationsEnabled = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveProfileSettings,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Profile to SharedPreferences'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
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
