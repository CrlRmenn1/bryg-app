import 'package:flutter/material.dart';

class AdminRequestsScreen extends StatelessWidget {
  const AdminRequestsScreen({super.key});

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
              "Requests",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _requestCard(
              title: "Cedula Request",
              name: "Juan Dela Cruz",
              date: "Feb 24, 2025",
              color: purple,
              onTap: () {},
            ),

            const SizedBox(height: 14),

            _requestCard(
              title: "Barangay Clearance",
              name: "Maria Santos",
              date: "Feb 22, 2025",
              color: purple,
              onTap: () {},
            ),

            const SizedBox(height: 14),

            _requestCard(
              title: "Residency Certificate",
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

  Widget _requestCard({
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
              child: Icon(Icons.description_outlined, color: color, size: 28),
            ),

            const SizedBox(width: 16),

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
