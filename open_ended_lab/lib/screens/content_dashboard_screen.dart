import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/content_item.dart';
import '../providers/content_provider.dart';

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
