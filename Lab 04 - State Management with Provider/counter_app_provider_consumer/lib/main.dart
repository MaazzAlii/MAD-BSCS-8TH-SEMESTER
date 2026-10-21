import 'package:counter_app_provider_consumer/counter_provider.dart';
import 'package:counter_app_provider_consumer/counter_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main()
{
  runApp(
    ChangeNotifierProvider(
      create: (context) => CounterProvider(),
      child: const MyApp()
    ), // ChangeNotifierProvider
  );
}

class MyApp extends StatelessWidget
{
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Counter Application",
      home: const CounterScreen(),
    ); // MaterialApp
  }
}