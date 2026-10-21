import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _officerName = '';
  String _badgeId = '';
  String _station = '';
  bool _darkMode = false;
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _officerName = prefs.getString('officerName') ?? 'Not Set';
      _badgeId = prefs.getString('badgeId') ?? 'Not Set';
      _station = prefs.getString('station') ?? 'Not Set';
      _darkMode = prefs.getBool('darkMode') ?? false;
      _notifications = prefs.getBool('notifications') ?? true;
    });
  }

  Future<void> _toggleDarkMode(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', val);
    setState(() => _darkMode = val);
  }

  Future<void> _toggleNotifications(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', val);
    setState(() => _notifications = val);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session & Preferences'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.security, color: Colors.indigo),
                      SizedBox(width: 8),
                      Text(
                        'Active Session (SharedPreferences)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildSessionRow('Officer Name', _officerName),
                  const SizedBox(height: 8),
                  _buildSessionRow('Badge ID', _badgeId),
                  const SizedBox(height: 8),
                  _buildSessionRow('Station Hub', _station),
                  const SizedBox(height: 8),
                  _buildSessionRow('Status', 'Authenticated Session'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark Mode Preference'),
                  subtitle: const Text('Persisted locally in SharedPreferences'),
                  value: _darkMode,
                  onChanged: _toggleDarkMode,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_outlined),
                  title: const Text('Dispatch Notifications'),
                  subtitle: const Text('Persisted locally in SharedPreferences'),
                  value: _notifications,
                  onChanged: _toggleNotifications,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('LOGOUT & CLEAR SESSION'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
