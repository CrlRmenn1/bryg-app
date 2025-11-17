import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            offset: const Offset(0, -8),
            color: Colors.black12.withOpacity(0.08),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_outlined, 0),
          _navItem(Icons.notifications_none, 1),
          _navItem(Icons.person_outline, 2),
          _navItem(Icons.chat_bubble_outline, 3),
          _navItem(Icons.campaign_outlined, 4),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    final bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 28,
            color: isActive ? Colors.purple : Colors.grey,
          ),

          const SizedBox(height: 4),

          // 🔥 Active indicator dot
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: isActive ? 8 : 0,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.circular(50),
            ),
          )
        ],
      ),
    );
  }
}
