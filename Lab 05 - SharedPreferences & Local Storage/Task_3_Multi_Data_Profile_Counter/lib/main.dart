import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Task3ProfileCounterApp(),
  ));
}

class Task3ProfileCounterApp extends StatefulWidget {
  const Task3ProfileCounterApp({super.key});

  @override
  State<Task3ProfileCounterApp> createState() => _Task3ProfileCounterAppState();
}

class _Task3ProfileCounterAppState extends State<Task3ProfileCounterApp> {
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

  Future<void> _incrementCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter++;
    });
    await prefs.setInt('persistent_counter', _counter);
  }

  Future<void> _resetCounter() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = 0;
    });
    await prefs.setInt('persistent_counter', 0);
  }

  Future<void> _saveProfileSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameController.text.trim());
    await prefs.setString('user_email', _emailController.text.trim());
    await prefs.setDouble('volume_level', _volumeLevel);
    await prefs.setBool('notifications_enabled', _notificationsEnabled);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile settings saved to SharedPreferences!')),
      );
    }
  }

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
        title: const Text('Task 3: Profile & Counter Persistence'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
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
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Persistent Counter (int)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('$_counter', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.indigo)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(onPressed: _incrementCounter, icon: const Icon(Icons.add), label: const Text('Increment')),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(onPressed: _resetCounter, icon: const Icon(Icons.refresh), label: const Text('Reset')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('User Settings (String, Double, Bool)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person), border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email), border: OutlineInputBorder())),
                    const SizedBox(height: 16),
                    Text('Volume Level: ${_volumeLevel.toStringAsFixed(0)}%'),
                    Slider(
                      value: _volumeLevel,
                      min: 0,
                      max: 100,
                      divisions: 20,
                      label: _volumeLevel.round().toString(),
                      onChanged: (val) => setState(() => _volumeLevel = val),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Notifications'),
                      value: _notificationsEnabled,
                      onChanged: (val) => setState(() => _notificationsEnabled = val),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveProfileSettings,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Settings'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
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
