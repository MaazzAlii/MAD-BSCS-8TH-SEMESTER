// REST API screen fetching trend ideas from jsonplaceholder api using http.get
// Uses FutureBuilder with circular progress indicator and ListView.builder for data
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiTrendsScreen extends StatefulWidget {
  const ApiTrendsScreen({super.key});

  @override
  State<ApiTrendsScreen> createState() => _ApiTrendsScreenState();
}

class _ApiTrendsScreenState extends State<ApiTrendsScreen> {
  late Future<List<dynamic>> _futureTrends;

  @override
  void initState() {
    super.initState();
    _futureTrends = _fetchTrends();
  }

  Future<List<dynamic>> _fetchTrends() async {
    final response = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/posts'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.take(15).toList();
    } else {
      throw Exception('Failed to load trends');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trending Topic Ideas (API)'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureTrends,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final trends = snapshot.data ?? [];
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: trends.length,
            itemBuilder: (context, index) {
              final item = trends[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.amber.shade100,
                    child: const Icon(Icons.bolt, color: Colors.orange),
                  ),
                  title: Text(
                    item['title'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    item['body'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
