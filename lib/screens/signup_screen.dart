import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_email_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _fullnameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cellController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedPosition = 'Resident';

  final List<String> positions = [
    'Barangay Captain',
    'Purok Leader',
    'Resident',
  ];

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF7B2CBF);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Text("Create Account", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              _buildField("Full Name", _fullnameController),
              _buildField("Address", _addressController),
              _buildField("Cellphone No.", _cellController),
              _buildField("Email", _emailController),
              _buildField("Birthday", _birthdayController),

              _buildField("Password", _passwordController, isPassword: true),

              const SizedBox(height: 10),

              DropdownButtonFormField(
                value: _selectedPosition,
                decoration: _inputDecoration(),
                items: positions
                    .map((pos) => DropdownMenuItem(value: pos, child: Text(pos)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedPosition = value!),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                onPressed: () async {
                  String? result = await AuthService.signup(
                    fullname: _fullnameController.text.trim(),
                    address: _addressController.text.trim(),
                    cellphone: _cellController.text.trim(),
                    email: _emailController.text.trim(),
                    birthday: _birthdayController.text.trim(),
                    password: _passwordController.text.trim(),
                    position: _selectedPosition,
                  );

                  if (result == null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginEmailScreen()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result)),
                    );
                  }
                },
                child: const Text("Done", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF5F2F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildField(String hint, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: _inputDecoration().copyWith(hintText: hint),
      ),
    );
  }
}
