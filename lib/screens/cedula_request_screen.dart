import 'package:flutter/material.dart';
import 'dart:io';


class CedulaRequestScreen extends StatefulWidget {
  const CedulaRequestScreen({super.key});

  @override
  State<CedulaRequestScreen> createState() => _CedulaRequestScreenState();
}

class _CedulaRequestScreenState extends State<CedulaRequestScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();





  @override
  Widget build(BuildContext context) {
    const Color accent = Color(0xFF7B2CBF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top decorative purple curve
              

              const SizedBox(height: 10),

              // Title
              const Text(
                "Request",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Text(
                "Cedula",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 40),

              // Form Fields
              _buildTextField("Full Name", fullNameController),
              const SizedBox(height: 16),
              _buildTextField("Address", addressController),
              const SizedBox(height: 16),
              _buildTextField("Cellphone No.", phoneController),
              const SizedBox(height: 16),
              _buildTextField("Email", emailController),
              const SizedBox(height: 16),
              _buildTextField("Birthday", birthdayController),
              const SizedBox(height: 16),

              // Verified ID field
              GestureDetector(

                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F2F9),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      
                      const Icon(Icons.upload_rounded,
                          color: Colors.black45, size: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Handle submit logic later
                  },
                  child: const Text(
                    "Submit",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Cancel
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
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
}
