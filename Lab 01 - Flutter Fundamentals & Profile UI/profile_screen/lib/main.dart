import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meri Piyari Application',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C5CE7)),
        scaffoldBackgroundColor: const Color(0xFFF3F2FA),
        fontFamily: 'Roboto',
      ),
      home: const ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile picture — top center
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 52,
                  backgroundColor: Color(0xFFE4E1F7),
                  backgroundImage: AssetImage('assets/images/sami.jpeg'),
                ),
              ),

              const SizedBox(height: 18),

              // Name + role — center
              const Text(
                'Maaz Ali',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Flutter Developer • Roll # 3143',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 22),
              SizedBox(
                width: 220,
                child: Divider(height: 1, color: Colors.grey.shade300),
              ),
              const SizedBox(height: 22),

              // Everything else — center, below the picture, icon inline
              const ProfileInfoRow(
                icon: Icons.person_outline,
                label: 'Name',
                value: 'Maaz Ali',
              ),
              const ProfileInfoRow(
                icon: Icons.badge_outlined,
                label: 'Roll No',
                value: '3143',
              ),
              const ProfileInfoRow(
                icon: Icons.school_outlined,
                label: 'Semester',
                value: 'BSCS 8th Semester',
              ),
              const ProfileInfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: 'maazali.dev@gmail.com',
              ),
              const ProfileInfoRow(
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: 'Islamabad, Pakistan',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  const ProfileInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: primary),
          ),
          const SizedBox(width: 10),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}