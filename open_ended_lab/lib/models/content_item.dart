// Data model for content posts (id, title, platform, views count)

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
