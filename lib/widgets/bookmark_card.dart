import 'package:flutter/material.dart';
import '../models/bookmark_model.dart';

class BookmarkCard extends StatelessWidget {
  final Bookmark bookmark;
  final VoidCallback onFavouriteToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const BookmarkCard({
    required this.bookmark,
    required this.onFavouriteToggle,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          bookmark.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(bookmark.url),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                bookmark.isFavourite ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
              onPressed: onFavouriteToggle,
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.redAccent),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
