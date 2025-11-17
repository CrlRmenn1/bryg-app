import 'package:flutter/material.dart';
import 'admin_announcement_screen.dart';
import 'admin_event_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7B2CBF);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // PAGE TITLE
            const Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // ------------ STAT CARDS ------------ //
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    title: "Requests",
                    value: "14",
                    icon: Icons.article_outlined,
                    color: purple,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _statCard(
                    title: "Reports",
                    value: "8",
                    icon: Icons.report_gmailerrorred_outlined,
                    color: purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    title: "Users",
                    value: "227",
                    icon: Icons.group_outlined,
                    color: purple,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _statCard(
                    title: "Messages",
                    value: "32",
                    icon: Icons.chat_bubble_outline_rounded,
                    color: purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ------------ ACTION BUTTONS ------------ //
            adminActionButton(
              label: "Post Announcement",
              icon: Icons.campaign_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminAnnouncementScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 14),

            adminActionButton(
              label: "Post Event",
              icon: Icons.event_available_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminEventScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // -------------------
  // 🔥 STAT CARD WIDGET
  // -------------------
  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5FF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black12.withOpacity(0.05),
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(icon, size: 34, color: color),

          const SizedBox(height: 14),

          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------
// 🔥 REUSABLE ADMIN BUTTON
// ---------------------------
Widget adminActionButton({
  required String label,
  required IconData icon,
  required VoidCallback onTap,
}) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7B2CBF),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 4,
        shadowColor: Colors.black12,
      ),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
