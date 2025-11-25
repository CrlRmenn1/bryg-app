import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_settings_screen.dart';
import 'admin_event_screen.dart';
import 'admin_announcement_screen.dart';
import 'admin_requests_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_user_screen.dart';
import 'admin_chat_list_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7B2CF7);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminSettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Overview',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 480;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(
                        width: isWide
                            ? (constraints.maxWidth - 12) / 2
                            : constraints.maxWidth,
                        child: const _ResidentsCard(),
                      ),
                      SizedBox(
                        width: isWide
                            ? (constraints.maxWidth - 12) / 2
                            : constraints.maxWidth,
                        child: const _OfficialsCard(),
                      ),
                      SizedBox(
                        width: isWide
                            ? (constraints.maxWidth - 12) / 2
                            : constraints.maxWidth,
                        child: const _PendingRequestsCard(),
                      ),
                      SizedBox(
                        width: isWide
                            ? (constraints.maxWidth - 12) / 2
                            : constraints.maxWidth,
                        child: const _OpenReportsCard(),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 28),

              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _QuickActionChip(
                    icon: Icons.campaign_rounded,
                    label: 'Announcements',
                    color: purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminAnnouncementScreen(),
                        ),
                      );
                    },
                  ),
                  _QuickActionChip(
                    icon: Icons.event,
                    label: 'Events',
                    color: Colors.deepPurple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminEventScreen(),
                        ),
                      );
                    },
                  ),
                  _QuickActionChip(
                    icon: Icons.assignment_outlined,
                    label: 'Requests',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminRequestsScreen(),
                        ),
                      );
                    },
                  ),
                  _QuickActionChip(
                    icon: Icons.report_problem_outlined,
                    label: 'Reports',
                    color: Colors.redAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminReportsScreen(),
                        ),
                      );
                    },
                  ),
                  _QuickActionChip(
                    icon: Icons.people_alt_outlined,
                    label: 'Users',
                    color: Colors.teal,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminUserScreen(),
                        ),
                      );
                    },
                  ),
                  _QuickActionChip(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Messages',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminChatListScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
/// REALTIME STAT CARDS BELOW…

class _ResidentsCard extends StatelessWidget {
  const _ResidentsCard();

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('users')
        .where('position', isEqualTo: 'Resident')
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return _StatCard(
          title: 'Residents',
          value: count.toString(),
          icon: Icons.home_rounded,
          color: const Color(0xFF22A6B3),
        );
      },
    );
  }
}

class _OfficialsCard extends StatelessWidget {
  const _OfficialsCard();

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('users')
        .where('position', isNotEqualTo: 'Resident')
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return _StatCard(
          title: 'Officials',
          value: count.toString(),
          icon: Icons.badge_rounded,
          color: const Color(0xFF6C5CE7),
        );
      },
    );
  }
}

class _PendingRequestsCard extends StatelessWidget {
  const _PendingRequestsCard();

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('requests')
        .where('status', isEqualTo: 'pending')
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return _StatCard(
          title: 'Pending Requests',
          value: count.toString(),
          icon: Icons.assignment_outlined,
          color: const Color(0xFFF39C12),
        );
      },
    );
  }
}

class _OpenReportsCard extends StatelessWidget {
  const _OpenReportsCard();

  bool _isOpen(String status) =>
      status == 'pending' || status == 'in_review';

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('reports')
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        int count = 0;
        if (snapshot.hasData) {
          for (final doc in snapshot.data!.docs) {
            final status = (doc.data()['status'] ?? 'pending').toString();
            if (_isOpen(status)) count++;
          }
        }
        return _StatCard(
          title: 'Open Reports',
          value: count.toString(),
          icon: Icons.report_problem_outlined,
          color: const Color(0xFFE74C3C),
        );
      },
    );
  }
}

// ------------------ REUSABLE CARDS ------------------

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 26, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
