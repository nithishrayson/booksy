class Bookmark {
  final String id;
  final String title;
  final String url;
  final String? note;
  final List<String> tags;
  final bool isFavourite;

  Bookmark({
    required this.id,
    required this.title,
    required this.url,
    this.note,
    required this.tags,
    this.isFavourite = false,
  });

  factory Bookmark.fromMap(String id, Map<String, dynamic> data) {
    return Bookmark(
      id: id,
      title: data['title'],
      url: data['url'],
      note: data['note'],
      tags: List<String>.from(data['tags']),
      isFavourite: data['isFavourite'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'url': url,
      'note': note,
      'tags': tags,
      'isFavourite': isFavourite,
    };
  }
}
