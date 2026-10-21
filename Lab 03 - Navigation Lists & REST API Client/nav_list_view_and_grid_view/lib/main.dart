import 'package:flutter/material.dart';
import 'list_view_widget.dart';
import 'grid_view_widget.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Nav and Collection Example App",
      initialRoute: '/',
      routes: {
        '/': (context) => const ListViewWidget(),
        '/gridview': (context) => const GridViewWidget(),
      },
    );
  }
}