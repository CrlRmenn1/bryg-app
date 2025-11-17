import 'package:flutter/material.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7B2CBF);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // Title
            const Text(
              "Reports",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Report Cards
            _reportCard(
              title: "Noise Complaint",
              name: "Juan Dela Cruz",
              date: "Feb 24, 2025",
              color: purple,
              onTap: () {},
            ),

            const SizedBox(height: 14),

            _reportCard(
              title: "Road Obstruction",
              name: "Maria Santos",
              date: "Feb 23, 2025",
              color: purple,
              onTap: () {},
            ),

            const SizedBox(height: 14),

            _reportCard(
              title: "Unauthorized Construction",
              name: "Peter Ramos",
              date: "Feb 20, 2025",
              color: purple,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _reportCard({
    required String title,
    required String name,
    required String date,
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
            // Icon circle
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 12,
                    color: Colors.black12.withOpacity(0.1),
                  )
                ],
              ),
              child: Icon(Icons.report_problem_outlined,
                  color: color, size: 28),
            ),

            const SizedBox(width: 16),

            // Text info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black38,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            const Icon(Icons.arrow_forward_ios,
                size: 18, color: Colors.purple),
          ],
        ),
      ),
    );
  }
}
