import 'package:flutter/material.dart';
import 'admin_chat_screen.dart';

class AdminChatListScreen extends StatelessWidget {
  const AdminChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "Messages",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _chatItem(
              name: "Juan Dela Cruz",
              msg: "Good evening po...",
              time: "10m ago",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminChatScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            _chatItem(
              name: "Maria Santos",
              msg: "Kailan po makukuha?",
              time: "1h ago",
              onTap: () {},
            ),

            const SizedBox(height: 16),

            _chatItem(
              name: "Peter Ramos",
              msg: "Paki-assist naman po...",
              time: "3h ago",
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatItem({
    required String name,
    required String msg,
    required String time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F5FF),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              color: Colors.black12.withOpacity(0.05),
              offset: const Offset(0, 4),
            )
          ],
        ),

        child: Row(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 32, color: Colors.purple),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    msg,
                    style: const TextStyle(
                        fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),

            Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
