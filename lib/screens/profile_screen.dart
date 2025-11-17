import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color accent = Color(0xFF7B2CBF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              // TODO: connect to edit function
            },
            child: const Text(
              "Edit",
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Profile Image
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/profile.jpg'), // replace with actual image
            ),
            const SizedBox(height: 10),

            // User Name
            const Text(
              "User User",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            // Resident Label
            const Text(
              "Resident",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            // Divider line
            const Divider(thickness: 1, height: 1, color: Colors.black12),
            const SizedBox(height: 20),

            // Info Fields
            _infoField("Address",
                "Purok 00, Brgy. —, Panabo City, Davao del Norte"),
            const SizedBox(height: 16),
            _infoField("Cellphone No.", "0991------334"),
            const SizedBox(height: 16),
            _infoField("Email", "User@gmail.com"),
            const SizedBox(height: 16),
            _infoField("Password", "************"),

            const SizedBox(height: 40),
          ],
        ),
      ),


    );
  }

  Widget _infoField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F2F9),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
