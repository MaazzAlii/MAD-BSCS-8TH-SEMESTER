import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/content_item.dart';

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
