import 'package:flutter/material.dart';

class AdminUserEditScreen extends StatelessWidget {
  const AdminUserEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7B2CBF);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit User",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.purple),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Center(
              child: CircleAvatar(
                radius: 45,
                backgroundColor: purple.withOpacity(0.2),
                child: const Icon(Icons.person, size: 50, color: Colors.purple),
              ),
            ),

            const SizedBox(height: 20),

            _field("Full Name"),
            _field("Email"),
            _field("Address"),
            _field("Position"),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {},
                child: const Text("Save Changes",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54),
          filled: true,
          fillColor: const Color(0xFFF6F2FF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
