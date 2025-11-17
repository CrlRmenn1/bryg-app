import 'package:flutter/material.dart';

class ResidencyRequestScreen extends StatelessWidget {
  const ResidencyRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF7B2CBF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 120,
                  height: 120,
                 
                ),
              ),
              const SizedBox(height: 10),

              const Text("Request",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const Text("Residency",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),

              const SizedBox(height: 40),
              _field("Full Name"),
              const SizedBox(height: 16),
              _field("Address"),
              const SizedBox(height: 16),
              _field("Years of Stay"),
              const SizedBox(height: 16),
              _field("Purpose"),
              const SizedBox(height: 16),
              _field("Cellphone No."),
              const SizedBox(height: 40),

              _submitButtons(context, accent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
        filled: true,
        fillColor: const Color(0xFFF5F2F9),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _submitButtons(BuildContext context, Color accent) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text("Submit",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16)),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text("Cancel",
                style: TextStyle(color: Colors.black54, fontSize: 15)),
          ),
        ),
      ],
    );
  }
}
