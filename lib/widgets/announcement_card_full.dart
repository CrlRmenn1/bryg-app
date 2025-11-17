import 'package:flutter/material.dart';

class AnnouncementCardFull extends StatelessWidget {
  const AnnouncementCardFull({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Profile + Name + Timestamp)
          ListTile(
            leading: const CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey,
              
            ),
            title: const Text(
              "Admin - Barangay Council",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            subtitle: const Text(
              "3 hours ago",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),

          // Temporary Image Placeholder
          Container(
            height: 160,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.image_outlined,
                size: 50,
                color: Colors.grey,
              ),
            ),
          ),

          // Message or Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Barangay Assembly Notice",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Please be informed that there will be a general assembly this coming Sunday, November 10, at 9:00 AM in the Barangay Hall.",
                  style: TextStyle(
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
