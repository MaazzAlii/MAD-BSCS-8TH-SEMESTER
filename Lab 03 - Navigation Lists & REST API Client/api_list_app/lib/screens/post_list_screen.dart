import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../widgets/post_card.dart';
import '../widgets/shimmer_loader.dart';
import 'post_detail_screen.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  late Future<List<Post>> _futurePosts;
  List<Post> _allPosts = [];
  List<Post> _filtered = [];
  final _searchController = TextEditingController();
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _loadPosts() {
    _futurePosts = ApiService.fetchPosts();
    _futurePosts.then((posts) {
      _allPosts = posts;
      _applyFilter(_searchController.text);
    });
  }

  void _applyFilter(String query) {
    setState(() {
      _filtered = query.trim().isEmpty
          ? _allPosts
          : _allPosts
              .where((p) =>
                  p.title.toLowerCase().contains(query.toLowerCase()) ||
                  p.body.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _searchController.clear();
      _allPosts = [];
      _filtered = [];
      _loadPosts();
    });
    await _futurePosts;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF6C63FF),
        title: _searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  hintText: 'Search posts…',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                ),
                onChanged: _applyFilter,
              )
            : const Text(
                'API Posts',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: 0.5,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _searching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _searching = !_searching;
                if (!_searching) {
                  _searchController.clear();
                  _applyFilter('');
                }
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Post>>(
        future: _futurePosts,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ShimmerLoader();
          }

          // Error state
          if (snapshot.hasError) {
            return _ErrorView(onRetry: () => setState(_loadPosts));
          }

          // Empty search
          if (_filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'No posts match your search.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // Stats bar
          return Column(
            children: [
              Container(
                color: const Color(0xFF6C63FF),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.article_outlined,
                        color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${_filtered.length} posts',
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  color: const Color(0xFF6C63FF),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final post = _filtered[index];

                      // Section header: show user label when userId changes
                      final showHeader = index == 0 ||
                          _filtered[index - 1].userId != post.userId;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showHeader)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
                              child: Text(
                                'USER ${post.userId}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.4,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                          PostCard(
                            post: post,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PostDetailScreen(post: post),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Error widget ──────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Could not load posts',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
