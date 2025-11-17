import 'package:flutter/material.dart';

class AdminPostAnnouncementForm extends StatefulWidget {
  const AdminPostAnnouncementForm({super.key});

  @override
  State<AdminPostAnnouncementForm> createState() =>
      _AdminPostAnnouncementFormState();
}

class _AdminPostAnnouncementFormState
    extends State<AdminPostAnnouncementForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7B2CBF);

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Create Announcement",
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Title",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "Enter announcement title",
                  filled: true,
                  fillColor: const Color(0xFFF3F0FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Title cannot be empty" : null,
              ),

              const SizedBox(height: 20),

              const Text(
                "Message",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _messageController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: "Enter announcement details...",
                  filled: true,
                  fillColor: const Color(0xFFF3F0FA),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Message cannot be empty" : null,
              ),

              const SizedBox(height: 30),

              // SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _submit(context);
                    }
                  },
                  child: const Text(
                    "Post Announcement",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // >>> This function will later be connected to Firestore
  void _submit(BuildContext context) {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();

    // For now, just show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Posted: $title"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }
}
