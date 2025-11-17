import 'package:flutter/material.dart';

class AdminNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AdminNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7B2CBF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_icons.length, (index) {
          final isActive = currentIndex == index;

          return GestureDetector(
            onTap: () => onTap(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _icons[index],
                  size: 28,
                  color: isActive ? purple : Colors.grey,
                ),

                const SizedBox(height: 6),

                // Active indicator dot
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? purple : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ICONS IN ORDER
const List<IconData> _icons = [
  Icons.grid_view_rounded,             // Dashboard
  Icons.article_outlined,              // Requests
  Icons.report_gmailerrorred_outlined, // Reports
  Icons.chat_bubble_outline_rounded,   // Messages
  Icons.group_outlined,                // Users

];
