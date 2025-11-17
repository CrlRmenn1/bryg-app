import 'package:flutter/material.dart';
import 'admin_user_edit_screen.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7B2CBF);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "Citizens",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _userCard(
              name: "Juan Dela Cruz",
              role: "Resident",
              color: purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminUserEditScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 14),

            _userCard(
              name: "Maria Santos",
              role: "Resident",
              color: purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminUserEditScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 14),

            _userCard(
              name: "Peter Ramos",
              role: "Resident",
              color: purple,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminUserEditScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _userCard({
    required String name,
    required String role,
    required Color color,
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
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: color, size: 32),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    role,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios,
                size: 18, color: Colors.purple),
          ],
        ),
      ),
    );
  }
}
