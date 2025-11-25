import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/event_card.dart';
import '../widgets/bottom_nav_bar.dart';

// alias imports to avoid name clash
import 'notification_screen.dart' as notif;
import 'announcement_screen.dart' as ann;

import 'settings_Screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';

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
        physics: const BouncingScrollPhysics(),
        onPageChanged: (i) {
          setState(() => _currentIndex = i);
        },
        children: [
          _HomePageContent(
            onOpenAnnouncements: () => _onNavTap(4),
          ),
          notif.NotificationScreen(
            goHome: () => _onNavTap(0),
          ),
          ProfileScreen(
            goHome: () => _onNavTap(0),
          ),
          ChatScreen(
            goHome: () => _onNavTap(0),
          ),
          ann.AnnouncementScreen(
            goHome: () => _onNavTap(0),
          ),
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
  final VoidCallback onOpenAnnouncements;

  const _HomePageContent({
    required this.onOpenAnnouncements,
  });

  String _formatDate(Timestamp? ts) {
    if (ts == null) return '';
    final d = ts.toDate();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF660094);
    final currentUser = FirebaseAuth.instance.currentUser;
    final String? uid = currentUser?.uid;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- HEADER (avatar + name + role) ----------
            if (uid == null)
              // No logged-in user – fallback header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Color(0xFFEDE7FF),
                        child: Icon(
                          Icons.person_outline,
                          color: purple,
                          size: 28,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: purple,
                          size: 28,
                        ),
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
                  const SizedBox(height: 4),
                  const Text(
                    "Resident",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              )
            else
              // Logged-in user – read everything from users/{uid}
              StreamBuilder<
                  DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  String fullName = 'User';
                  String position = 'Resident';
                  String? photoUrl;

                  if (snapshot.hasData && snapshot.data!.data() != null) {
                    final data = snapshot.data!.data()!;
                    fullName = (data['fullname'] ?? 'User').toString();
                    position = (data['position'] ?? 'Resident').toString();
                    photoUrl =
                        (data['profilePictureUrl'] ?? '').toString();
                  }

                  final hasPhoto =
                      photoUrl != null && photoUrl.isNotEmpty;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: const Color(0xFFEDE7FF),
                            backgroundImage: hasPhoto
                                ? NetworkImage(photoUrl!)
                                : null,
                            child: !hasPhoto
                                ? const Icon(
                                    Icons.person_outline,
                                    color: purple,
                                    size: 28,
                                  )
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.settings_outlined,
                              color: purple,
                              size: 28,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const SettingsScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Hello, $fullName!',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        position.isEmpty ? 'Resident' : position,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),

            // ---------- LATEST ANNOUNCEMENT ----------
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('announcements')
                  .orderBy('createdAt', descending: true)
                  .limit(1)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F6FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Loading latest announcement...',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F6FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Text(
                            'No announcements yet.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }

                final data = snapshot.data!.docs.first.data();
                final title =
                    (data['title'] ?? 'Announcement').toString();
                final body =
                    (data['content'] ?? data['body'] ?? 'Tap to see details.')
                        .toString();

                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F6FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              body,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: purple,
                          borderRadius:
                              BorderRadius.circular(999),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_forward,
                            size: 18,
                            color: Colors.white,
                          ),
                          onPressed: onOpenAnnouncements,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // ---------- EVENTS TITLE ----------
            const Text(
              "Event",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // ---------- EVENTS LIST ----------
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('events')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No events posted yet.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return Column(
                  children: docs.map((doc) {
                    final data = doc.data();

                    final posterName =
                        (data['createdByName'] ??
                                'Barangay Council')
                            .toString();
                    final subtitle =
                        (data['createdByRole'] ?? 'Event')
                            .toString();
                    final Timestamp? dateTs =
                        data['date'] is Timestamp
                            ? data['date'] as Timestamp
                            : null;
                    final timeLabel = _formatDate(dateTs);
                    final caption =
                        (data['description'] ?? data['title'] ?? '')
                            .toString();
                    final profileImageUrl =
                        (data['createdByPhotoUrl'] ?? '')
                            .toString();
                    final postImageUrl =
                        (data['imageUrl'] ?? '').toString();

                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: 16),
                      child: EventCard(
                        posterName: posterName,
                        subtitle: subtitle,
                        timeLabel: timeLabel,
                        caption: caption,
                        profileImageUrl:
                            profileImageUrl.isEmpty
                                ? null
                                : profileImageUrl,
                        postImageUrl: postImageUrl.isEmpty
                            ? null
                            : postImageUrl,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
