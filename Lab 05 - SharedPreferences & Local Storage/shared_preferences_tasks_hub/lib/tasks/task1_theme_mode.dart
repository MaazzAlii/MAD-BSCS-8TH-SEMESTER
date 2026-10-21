import 'package:flutter/material.dart';

/// Task 1: Light & Dark Mode Persistence using SharedPreferences
class Task1ThemeScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const Task1ThemeScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<Task1ThemeScreen> createState() => _Task1ThemeScreenState();
}

class _Task1ThemeScreenState extends State<Task1ThemeScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task 1: Theme Switcher'),
        actions: [
          Switch(
            value: isDark,
            onChanged: widget.onThemeChanged,
            activeColor: Colors.amber,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon showing Current Mode
              Icon(
                isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                size: 80,
                color: isDark ? Colors.amber : Colors.orange,
              ),
              const SizedBox(height: 20),

              // Title Text
              Text(
                isDark ? 'Dark Mode is Active' : 'Light Mode is Active',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle Text
              Text(
                'Theme choice is saved in SharedPreferences key: "is_dark_mode"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 30),

              // Card with an interactive toggle tile
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: SwitchListTile(
                  title: const Text(
                    'Dark Theme Toggle',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Save and persist theme across app restarts'),
                  secondary: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                  ),
                  value: isDark,
                  onChanged: widget.onThemeChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
