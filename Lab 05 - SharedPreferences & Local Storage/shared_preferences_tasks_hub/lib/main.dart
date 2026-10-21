import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tasks/task1_theme_mode.dart';
import 'tasks/task2_login_session.dart';
import 'tasks/task3_user_profile_counter.dart';
import 'tasks/task4_todo_persistence.dart';

void main() async {
  // Ensure Flutter engine bindings are initialized before calling async code
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Variable to store whether dark mode is active
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    // Load the saved theme preference when the app starts
    _loadThemePreference();
  }

  // 1. Load saved theme from SharedPreferences
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Default to false (light mode) if no key exists
      _isDarkMode = prefs.getBool('is_dark_mode') ?? false;
    });
  }

  // 2. Toggle and save the new theme preference
  Future<void> _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = value;
    });
    // Save to SharedPreferences
    await prefs.setBool('is_dark_mode', value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Oct 7 - SharedPreferences Tasks',

      // Define your Light Theme
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

      // Define your Dark Theme
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

      // Controls whether light or dark theme is active
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,

      home: MainNavigationHub(
        isDarkMode: _isDarkMode,
        onThemeChanged: _toggleTheme,
      ),
    );
  }
}

class MainNavigationHub extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const MainNavigationHub({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<MainNavigationHub> createState() => _MainNavigationHubState();
}

class _MainNavigationHubState extends State<MainNavigationHub> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      Task1ThemeScreen(
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
      ),
      const Task2LoginScreen(),
      const Task3ProfileCounterScreen(),
      const Task4TodoPersistenceScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.brightness_medium),
            label: 'Task 1: Theme',
          ),
          NavigationDestination(
            icon: Icon(Icons.lock_person),
            label: 'Task 2: Login',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune),
            label: 'Task 3: Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist),
            label: 'Task 4: Todo',
          ),
        ],
      ),
    );
  }
}
