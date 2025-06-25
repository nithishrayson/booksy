import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thisuxnew/screens/bookmark_screen.dart';
import 'package:thisuxnew/screens/login_screen.dart';
import 'package:thisuxnew/service/firesstore_service.dart';
import '../models/bookmark_model.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<HomeScreen> {
  final firestore = FirestoreService();
  bool showFavouritesOnly = false;
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.purple[300],
        elevation: 1,
        centerTitle: true,
        title: Text("Booksy", style: TextStyle(color: Colors.black87),),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: PopupMenuButton<String>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              icon: CircleAvatar(
                backgroundColor: Colors.purple.shade100,
                child: Icon(Icons.person, color: Colors.purple),
              ),
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      enabled: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Signed in as",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            FirebaseAuth.instance.currentUser?.email ??
                                'Unknown',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 8),
                          Text("Logout"),
                        ],
                      ),
                    ),
                  ],
              onSelected: (value) async {
                if (value == 'logout') {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                }
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Checkbox(
                  value: showFavouritesOnly,
                  onChanged: (val) => setState(() => showFavouritesOnly = val!),
                ),
                Text("Show Favourites Only", style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),

            child: TextField(
              onChanged:
                  (val) => setState(() {
                    searchText = val.toLowerCase();
                  }),
              decoration: InputDecoration(
                hintText: 'Search by tags...',
                prefixIcon: Icon(Icons.search),
                suffixIcon:
                    searchText.isNotEmpty
                        ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed:
                              () => setState(() {
                                searchText = '';
                              }),
                        )
                        : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<List<Bookmark>>(
              stream: firestore.getBookmarks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator());

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "No bookmarks found",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  );
                }

                List<Bookmark> bookmarks = snapshot.data!;
                if (showFavouritesOnly) {
                  bookmarks = bookmarks.where((b) => b.isFavourite).toList();
                }

                if (searchText.isNotEmpty) {
                  bookmarks =
                      bookmarks
                          .where(
                            (b) => b.tags.any(
                              (tag) => tag.toLowerCase().contains(searchText),
                            ),
                          )
                          .toList();
                }

                if (bookmarks.isEmpty) {
                  return Center(
                    child: Text(
                      searchText.isNotEmpty
                          ? 'No bookmarks match your tag search'
                          : showFavouritesOnly
                          ? 'No favourite bookmarks yet'
                          : 'No bookmarks found',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: bookmarks.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final b = bookmarks[index];
                    return Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: Text(
                          b.title,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.url, style: TextStyle(color: Colors.purple)),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 2,
                              children:
                                  b.tags.map((tag) {
                                    return Chip(
                                      backgroundColor: Colors.white,
                                      label: Text(tag),
                                      labelStyle: TextStyle(color: Colors.grey),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 5,
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            b.isFavourite ? Icons.star : Icons.star_border,
                            color: b.isFavourite ? Colors.amber : Colors.grey,
                          ),
                          onPressed:
                              () => firestore.toggleFavourite(
                                b.id,
                                !b.isFavourite,
                              ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookmarkScreen(bookmark: b),
                            ),
                          );
                        },
                        onLongPress: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: Text('Delete Bookmark?'),
                                  content: Text(
                                    'Are you sure you want to delete "${b.title}"?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                          );
                          if (confirmed == true) {
                            firestore.deleteBookmark(b.id);
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BookmarkScreen()),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
