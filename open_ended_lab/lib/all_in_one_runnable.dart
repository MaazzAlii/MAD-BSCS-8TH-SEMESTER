import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

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

class ContentItem {
  final int? id;
  final String title;
  final String platform;
  final int views;

  ContentItem({
    this.id,
    required this.title,
    required this.platform,
    required this.views,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'platform': platform,
      'views': views,
    };
  }

  factory ContentItem.fromMap(Map<String, dynamic> map) {
    return ContentItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      platform: map['platform'] as String,
      views: map['views'] as int,
    );
  }

  ContentItem copyWith({
    int? id,
    String? title,
    String? platform,
    int? views,
  }) {
    return ContentItem(
      id: id ?? this.id,
      title: title ?? this.title,
      platform: platform ?? this.platform,
      views: views ?? this.views,
    );
  }
}

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  final List<ContentItem> _webStore = [
    ContentItem(id: 1, title: 'Flutter 3.0 Full Roadmap', platform: 'YouTube', views: 15400),
    ContentItem(id: 2, title: 'Top 5 VS Code Shortcuts', platform: 'TikTok', views: 8200),
    ContentItem(id: 3, title: 'UI Design Tips for Devs', platform: 'Instagram', views: 4300),
  ];
  int _webId = 4;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('content_creator.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE contents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        platform TEXT NOT NULL,
        views INTEGER NOT NULL
      )
    ''');

    for (var item in _webStore) {
      await db.insert('contents', item.toMap());
    }
  }

  Future<int> insertContent(ContentItem item) async {
    if (kIsWeb) {
      final newItem = item.copyWith(id: _webId++);
      _webStore.insert(0, newItem);
      return newItem.id!;
    }
    final db = await database;
    return await db.insert('contents', item.toMap());
  }

  Future<List<ContentItem>> getContents() async {
    if (kIsWeb) {
      return List<ContentItem>.from(_webStore);
    }
    final db = await database;
    final result = await db.query('contents', orderBy: 'id DESC');
    return result.map((map) => ContentItem.fromMap(map)).toList();
  }

  Future<int> deleteContent(int id) async {
    if (kIsWeb) {
      _webStore.removeWhere((item) => item.id == id);
      return 1;
    }
    final db = await database;
    return await db.delete(
      'contents',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

class ContentProvider extends ChangeNotifier {
  final DBHelper _dbHelper = DBHelper.instance;

  List<ContentItem> _contents = [];
  bool _isLoading = false;

  List<ContentItem> get contents => _contents;
  bool get isLoading => _isLoading;
  int get totalVideos => _contents.length;
  int get totalViews => _contents.fold(0, (sum, item) => sum + item.views);

  Future<void> loadContents() async {
    _isLoading = true;
    notifyListeners();

    _contents = await _dbHelper.getContents();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addContent(ContentItem item) async {
    await _dbHelper.insertContent(item);
    await loadContents();
  }

  Future<void> deleteContent(int id) async {
    await _dbHelper.deleteContent(id);
    await loadContents();
  }
}

class ContentDashboardScreen extends StatefulWidget {
  const ContentDashboardScreen({super.key});

  @override
  State<ContentDashboardScreen> createState() => _ContentDashboardScreenState();
}

class _ContentDashboardScreenState extends State<ContentDashboardScreen> {
  String _creatorName = 'Maaz Creator';

  @override
  void initState() {
    super.initState();
    _loadCreatorName();
    Future.microtask(() => context.read<ContentProvider>().loadContents());
  }

  Future<void> _loadCreatorName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _creatorName = prefs.getString('creatorName') ?? 'Maaz Creator';
    });
  }

  Future<void> _updateCreatorName(String newName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('creatorName', newName);
    setState(() {
      _creatorName = newName;
    });
  }

  void _showEditNameDialog() {
    final controller = TextEditingController(text: _creatorName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Channel Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Channel / Creator Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _updateCreatorName(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save to SharedPrefs'),
          ),
        ],
      ),
    );
  }

  void _showAddContentDialog() {
    final titleController = TextEditingController();
    final viewsController = TextEditingController();
    String selectedPlatform = 'YouTube';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Content Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Video / Post Title'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedPlatform,
                decoration: const InputDecoration(labelText: 'Platform'),
                items: ['YouTube', 'TikTok', 'Instagram']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => selectedPlatform = val);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: viewsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'View Count'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                final views = int.tryParse(viewsController.text.trim()) ?? 0;

                if (title.isNotEmpty) {
                  final item = ContentItem(
                    title: title,
                    platform: selectedPlatform,
                    views: views,
                  );
                  context.read<ContentProvider>().addContent(item);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save to SQLite'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform) {
      case 'YouTube':
        return Icons.play_circle_fill;
      case 'TikTok':
        return Icons.music_note;
      case 'Instagram':
        return Icons.camera_alt;
      default:
        return Icons.video_library;
    }
  }

  Color _getPlatformColor(String platform) {
    switch (platform) {
      case 'YouTube':
        return Colors.red;
      case 'TikTok':
        return Colors.black87;
      case 'Instagram':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ContentProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_creatorName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Creator Name',
            onPressed: _showEditNameDialog,
          ),
          IconButton(
            icon: const Icon(Icons.trending_up),
            tooltip: 'Trending API Ideas',
            onPressed: () => Navigator.pushNamed(context, '/trends'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${provider.totalVideos}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const Text('Total Uploads', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                Container(height: 30, width: 1, color: Colors.grey.shade300),
                Column(
                  children: [
                    Text(
                      '${provider.totalViews}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const Text('Total Views', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.contents.isEmpty
                    ? const Center(child: Text('No content created yet.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: provider.contents.length,
                        itemBuilder: (context, index) {
                          final item = provider.contents[index];
                          final color = _getPlatformColor(item.platform);

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: color.withOpacity(0.15),
                                child: Icon(_getPlatformIcon(item.platform), color: color),
                              ),
                              title: Text(
                                item.title,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('${item.platform} • ${item.views} views'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  if (item.id != null) {
                                    context.read<ContentProvider>().deleteContent(item.id!);
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContentDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

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
