import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestFirebaseScreen extends StatelessWidget {
  const TestFirebaseScreen({super.key});

  Future<void> testWrite() async {
    try {
      await FirebaseFirestore.instance
          .collection("test_collection")
          .add({"status": "connected", "timestamp": DateTime.now()});

      print("🔥 FIREBASE WRITE SUCCESS");
    } catch (e) {
      print("❌ FIREBASE WRITE ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    testWrite(); // Automatically runs the test

    return Scaffold(
      backgroundColor: Colors.white,
      body: const Center(
        child: Text(
          "🔥 Testing Firebase...\nCheck console for results.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
