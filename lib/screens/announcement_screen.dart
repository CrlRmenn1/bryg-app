import 'package:flutter/material.dart';
import '../widgets/announcement_card_full.dart';
import 'settings_screen.dart';

class AnnouncementScreen extends StatelessWidget {
  const AnnouncementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color accent = Color(0xFF7B2CBF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Announcement",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: accent,
              size: 28,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: const Column(
          children: [
            AnnouncementCardFull(),
            SizedBox(height: 12),
            AnnouncementCardFull(),
            SizedBox(height: 12),
            AnnouncementCardFull(),
          ],
        ),
      ),
    );
  }
}
