import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ThemeTaskApp());
}

class ThemeTaskApp extends StatefulWidget {
  const ThemeTaskApp({super.key});

  @override
  State<ThemeTaskApp> createState() => _ThemeTaskAppState();
}

class _ThemeTaskAppState extends State<ThemeTaskApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('is_dark_mode') ?? false;
    });
  }

  Future<void> _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = value;
    });
    await prefs.setBool('is_dark_mode', value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task 1: Theme Preference',
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Task 1: Theme Preference'),
          actions: [
            Switch(
              value: _isDarkMode,
              onChanged: _toggleTheme,
              activeColor: Colors.amber,
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                  size: 80,
                  color: _isDarkMode ? Colors.amber : Colors.orange,
                ),
                const SizedBox(height: 20),
                Text(
                  _isDarkMode ? 'Dark Mode is ON' : 'Light Mode is ON',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Preference is saved persistently using SharedPreferences key: "is_dark_mode"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: _isDarkMode ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 30),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  child: SwitchListTile(
                    title: const Text(
                      'Dark Theme',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Toggle between Light and Dark mode'),
                    secondary: Icon(
                      _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    ),
                    value: _isDarkMode,
                    onChanged: _toggleTheme,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
