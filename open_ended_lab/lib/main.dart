import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/fleet_provider.dart';
import 'screens/auth_gate.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/vehicle_list_screen.dart';
import 'screens/add_edit_vehicle_screen.dart';
import 'screens/api_bulletin_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FleetProvider()),
      ],
      child: const FleetApp(),
    ),
  );
}

class FleetApp extends StatelessWidget {
  const FleetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AeroFleet Dispatcher',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/vehicles': (context) => const VehicleListScreen(),
        '/add_vehicle': (context) => const AddEditVehicleScreen(),
        '/api_advisories': (context) => const ApiBulletinScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
