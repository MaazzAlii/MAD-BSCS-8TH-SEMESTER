import 'package:flutter/material.dart';
import '../models/post.dart';

const List<Color> _avatarColors = [
  Color(0xFF6C63FF), Color(0xFF43AA8B), Color(0xFFFF6B6B),
  Color(0xFFFFD93D), Color(0xFF4D96FF), Color(0xFFFF9F1C),
  Color(0xFF2EC4B6), Color(0xFFE71D36), Color(0xFF8338EC), Color(0xFF3A86FF),
];

class PostDetailScreen extends StatelessWidget {
  final Post post;
  const PostDetailScreen({super.key, required this.post});

  Color get _color => _avatarColors[(post.userId - 1) % _avatarColors.length];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: _color,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'Post #${post.id}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_color, _color.withValues(alpha: 0.7)],
                  ),
                ),
                child: Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    child: Text(
                      'U${post.userId}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _Chip(label: 'User ${post.userId}', color: _color),
                      const SizedBox(width: 8),
                      _Chip(label: 'Post ID ${post.id}', color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Title',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _color,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Divider(color: Colors.grey.shade200),
                  const SizedBox(height: 16),
                  Text(
                    'Content',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _color,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.body,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.7,
                      color: Color(0xFF444444),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
