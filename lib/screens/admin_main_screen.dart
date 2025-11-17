import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';
import 'admin_requests_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_chat_screen.dart';
import 'admin_user_screen.dart';
import '../widgets/admin_nav_bar.dart';
import 'admin_chat_list_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _index = 0;
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
  }

  void _onNavTap(int i) {
    setState(() => _index = i);
    _controller.animateToPage(
      i,
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
        onPageChanged: (i) => setState(() => _index = i),
        children: const [
          AdminDashboardScreen(),
          AdminRequestsScreen(),
          AdminReportsScreen(),
          AdminChatListScreen(),
          AdminUsersScreen(),
        ],
      ),
      bottomNavigationBar: AdminNavBar(
        currentIndex: _index,
        onTap: _onNavTap,
      ),
    );
  }
}
