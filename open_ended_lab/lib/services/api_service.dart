import 'dart:convert';
import 'package:http/http.dart' as http;

class SafetyBulletin {
  final int id;
  final String title;
  final String body;

  SafetyBulletin({
    required this.id,
    required this.title,
    required this.body,
  });

  factory SafetyBulletin.fromJson(Map<String, dynamic> json) {
    return SafetyBulletin(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}

class ApiService {
  static const String endpoint = 'https://jsonplaceholder.typicode.com/posts';

  Future<List<SafetyBulletin>> fetchSafetyBulletins() async {
    final response = await http.get(Uri.parse(endpoint));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.take(15).map((item) => SafetyBulletin.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load safety advisories: ${response.statusCode}');
    }
  }
}
