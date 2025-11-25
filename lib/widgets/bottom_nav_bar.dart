import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color purple = Color(0xFF7B2CBF);
    final Color inactive = Colors.grey.shade500;

    return SafeArea(
      top: false,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_icons.length, (index) {
              final bool isActive = index == currentIndex;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(index),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _icons[index],
                      size: 24,
                      color: isActive ? purple : inactive,
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isActive ? purple : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// Icons in order – must match your PageView order in HomeScreen:
/// 0: Home, 1: Notifications, 2: Profile, 3: Messages, 4: Announcements
const List<IconData> _icons = [
  Icons.home_outlined,             // Home
  Icons.notifications_none_outlined, // Notifications
  Icons.person_outline,            // Profile
  Icons.chat_bubble_outline_rounded, // Messages
  Icons.campaign_outlined,         // Announcements
];
