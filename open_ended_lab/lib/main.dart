// Main app entry point, sets up Provider state management and screen navigations routes
// Initial route opens content dashboard screen and /trends route for api screen
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/content_provider.dart';
import 'screens/content_dashboard_screen.dart';
import 'screens/api_trends_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ContentProvider(),
      child: const CreatorApp(),
    ),
  );
}

class CreatorApp extends StatelessWidget {
  const CreatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Creator Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const ContentDashboardScreen(),
        '/trends': (context) => const ApiTrendsScreen(),
      },
    );
  }
}
