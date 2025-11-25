import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'screens/start_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barangay App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF7B2CF7),
        useMaterial3: false,
      ),
      home: const AuthGate(),
    );
  }
}

/// This widget decides:
/// - not logged in  -> StartScreen (login / signup)
/// - logged in user -> HomeScreen
/// - logged in admin -> AdminMainScreen
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // still checking auth
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        // not logged in -> go to start/login
        if (user == null) {
          return const StartScreen();
        }

        // logged in -> check if admin or normal user
        return _RoleRouter(userId: user.uid);
      },
    );
  }
}

class _RoleRouter extends StatelessWidget {
  final String userId;
  const _RoleRouter({required this.userId});

  @override
  Widget build(BuildContext context) {
    final docRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: docRef.get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data?.data() ?? {};

        // You can adjust this logic depending on how you mark admins
        final role = (data['role'] ?? '').toString().toLowerCase();
        final position = (data['position'] ?? '').toString();

        final bool isAdmin =
            role == 'admin' || (position.isNotEmpty && position != 'Resident');

        if (isAdmin) {
          return const AdminMainScreen();
        } else {
          return const HomeScreen();
        }
      },
    );
  }
}
