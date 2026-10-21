import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _officerNameController = TextEditingController(text: 'Maaz Ali');
  final _badgeIdController = TextEditingController(text: 'FLEET-770');
  final _stationController = TextEditingController(text: 'Central Logistics Hub');
  bool _isLoading = false;

  @override
  void dispose() {
    _officerNameController.dispose();
    _badgeIdController.dispose();
    _stationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('officerName', _officerNameController.text.trim());
    await prefs.setString('badgeId', _badgeIdController.text.trim());
    await prefs.setString('station', _stationController.text.trim());

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.local_shipping,
                      size: 64,
                      color: Colors.indigo,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'AeroFleet Dispatcher',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Logistics & Maintenance Portal',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _officerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Fleet Officer Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _badgeIdController,
                      decoration: const InputDecoration(
                        labelText: 'Officer Badge ID',
                        prefixIcon: Icon(Icons.badge),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Please enter badge ID' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _stationController,
                      decoration: const InputDecoration(
                        labelText: 'Assigned Station / Hub',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Please enter station' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'AUTHORIZE & ENTER',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
