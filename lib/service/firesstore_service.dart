import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/bookmark_model.dart';

class FirestoreService {
  final CollectionReference bookmarks = FirebaseFirestore.instance.collection(
    'bookmarks',
  );

  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  Stream<List<Bookmark>> getBookmarks() {
    return bookmarks
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => Bookmark.fromMap(
                      doc.id,
                      doc.data() as Map<String, dynamic>,
                    ),
                  )
                  .toList(),
        );
  }

  Future<void> addBookmark(Bookmark bookmark) async {
    final existing =
        await bookmarks
            .where('userId', isEqualTo: userId)
            .where('url', isEqualTo: bookmark.url.trim())
            .get();

    if (existing.docs.isEmpty) {
      await bookmarks.add({...bookmark.toMap(), 'userId': userId});
    } else {
      throw Exception('Bookmark with this URL already exists.');
    }
  }

  Future<void> updateBookmark(String id, Bookmark bookmark) {
    return bookmarks.doc(id).update(bookmark.toMap());
  }

  Future<void> deleteBookmark(String id) {
    return bookmarks.doc(id).delete();
  }

  Future<void> toggleFavourite(String id, bool isFav) {
    return bookmarks.doc(id).update({'isFavourite': isFav});
  }
}
