import 'package:flutter/material.dart';
import 'admin_post_announcement_form.dart'; // <-- Your form screen

class AdminAnnouncementScreen extends StatelessWidget {
  const AdminAnnouncementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Announcements",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              AnnouncementCard(
                title: "Barangay Assembly",
                date: "Feb 20",
                content:
                    "All residents are invited for the general assembly this Friday.",
              ),
              const SizedBox(height: 16),

              AnnouncementCard(
                title: "Road Maintenance",
                date: "Feb 17",
                content:
                    "Portions of Purok 2 will undergo road work. Expect minor delays.",
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7B2CBF),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AdminPostAnnouncementForm(),
            ),
          );
        },
        child: const Icon(
          Icons.campaign_rounded, // MEGAPHONE ICON
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }
}

//
// ------------------------------------------------------------
// ANNOUNCEMENT CARD WIDGET
// ------------------------------------------------------------
//
class AnnouncementCard extends StatelessWidget {
  final String title;
  final String content;
  final String date;

  const AnnouncementCard({
    super.key,
    required this.title,
    required this.content,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F6FF),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF7B2CBF),
            ),
          ),

          const SizedBox(height: 10),

          // Content
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          // Date
          Text(
            date,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
