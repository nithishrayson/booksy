import 'package:flutter/material.dart';
import 'package:thisuxnew/service/firesstore_service.dart';
import '../models/bookmark_model.dart';

class BookmarkScreen extends StatefulWidget {
  final Bookmark? bookmark;

  BookmarkScreen({this.bookmark});

  @override
  State<BookmarkScreen> createState() => _AddEditBookmarkScreenState();
}

class _AddEditBookmarkScreenState extends State<BookmarkScreen> {
  final _formKey = GlobalKey<FormState>();
  final firestore = FirestoreService();

  late TextEditingController titleController;
  late TextEditingController urlController;
  late TextEditingController noteController;
  late TextEditingController tagsController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.bookmark?.title ?? '');
    urlController = TextEditingController(text: widget.bookmark?.url ?? '');
    noteController = TextEditingController(text: widget.bookmark?.note ?? '');
    tagsController = TextEditingController(
      text: widget.bookmark?.tags.join(', ') ?? '',
    );
  }

  void save() async {
    if (_formKey.currentState!.validate()) {
      final newBookmark = Bookmark(
        id: widget.bookmark?.id ?? '',
        title: titleController.text.trim(),
        url: urlController.text.trim(),
        note: noteController.text.trim(),
        tags: tagsController.text.split(',').map((e) => e.trim()).toList(),
        isFavourite: widget.bookmark?.isFavourite ?? false,
      );

      try {
        if (widget.bookmark == null) {
          await firestore.addBookmark(newBookmark);
        } else {
          await firestore.updateBookmark(widget.bookmark!.id, newBookmark);
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Bookmark already exists")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.bookmark == null ? "Add Bookmark" : "Edit Bookmark"),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildField(
                controller: titleController,
                label: "Title",
                hint: "Enter bookmark title",
                validator:
                    (val) =>
                        val == null || val.isEmpty ? 'Title is required' : null,
              ),
              SizedBox(height: 16),
              buildField(
                controller: urlController,
                label: "URL",
                hint: "https://example.com",
                validator: (val) {
                  if (val == null || val.isEmpty) return 'URL is required';

                  final pattern =
                      r'^https:\/\/[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(:\d+)?(\/\S*)?$';
                  final regex = RegExp(pattern);

                  if (!regex.hasMatch(val.trim())) {
                    return 'Enter a valid URL (e.g. https://example.com)';
                  }

                  return null;
                },
              ),

              SizedBox(height: 16),
              buildField(
                controller: noteController,
                label: "Note",
                hint: "Optional note about this bookmark",
                maxLines: 3,
              ),
              SizedBox(height: 16),
              buildField(
                controller: tagsController,
                label: "Tags",
                hint: "e.g. tech, flutter, design",
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Save Bookmark",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
