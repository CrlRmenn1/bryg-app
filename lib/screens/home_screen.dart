import 'package:flutter/material.dart';
import '../widgets/event_card.dart';
import '../widgets/bottom_nav_bar.dart';

import 'settings_screen.dart';
import 'notification_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'announcement_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PageController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);

    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        physics: const BouncingScrollPhysics(),   // 👈 allows swiping
        onPageChanged: (i) {
          setState(() => _currentIndex = i);
        },
        children: const [
          _HomePageContent(),
          NotificationScreen(),
          ProfileScreen(),
          ChatScreen(),
          AnnouncementScreen(),
        ],
      ),

      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

class _HomePageContent extends StatelessWidget {
  const _HomePageContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile + Settings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      AssetImage('assets/profile_placeholder.png'),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined,
                      color: Colors.purple, size: 28),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Text(
              "Hello, User!",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Color(0xFFF9F6FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Announcement",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const EventCard(),
            const SizedBox(height: 16),
            const EventCard(),
          ],
        ),
      ),
    );
  }
}
