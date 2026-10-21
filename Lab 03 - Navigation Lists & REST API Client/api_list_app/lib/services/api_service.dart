import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  static Future<List<Post>> fetchPosts() async {
    final uri = Uri.parse('$_baseUrl/posts');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Failed to load posts. Status: ${response.statusCode}');
  }
}
