import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';
import 'admin_main_screen.dart';
import 'login_email_screen.dart';
import 'forgot_password_screen.dart'; // 👈 NEW

class LoginPasswordScreen extends StatefulWidget {
  final String email;
  final String? fullName;
  final String? profilePictureUrl;

  const LoginPasswordScreen({
    super.key,
    required this.email,
    this.fullName,
    this.profilePictureUrl,
  });

  @override
  State<LoginPasswordScreen> createState() => _LoginPasswordScreenState();
}

class _LoginPasswordScreenState extends State<LoginPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final err = await AuthService.login(widget.email, _passwordController.text);
    if (err != null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    final isAdmin = await AuthService.isCurrentUserAdmin();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => isAdmin
            ? const AdminMainScreen()
            : const HomeScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF7B2CF7);
    const fieldBg = Color(0xFFF5F5F5);

    final displayName = (widget.fullName ?? '').isEmpty
        ? "User"
        : widget.fullName!.split(" ").first;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Avatar
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white,
                backgroundImage: (widget.profilePictureUrl != null &&
                        widget.profilePictureUrl!.isNotEmpty)
                    ? NetworkImage(widget.profilePictureUrl!)
                    : null,
                child: (widget.profilePictureUrl == null ||
                        widget.profilePictureUrl!.isEmpty)
                    ? const Icon(
                        Icons.person_outline,
                        size: 48,
                        color: Colors.grey,
                      )
                    : null,
              ),

              const SizedBox(height: 20),

              Text(
                "Hello, $displayName!!",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),
              const Text(
                "Type your password",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 36),

              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  validator: (value) {
                    final text = value?.trim() ?? "";
                    if (text.isEmpty) return "Password is required";
                    if (text.length < 6) return "Password must be 6+ characters";
                    return null;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: fieldBg,
                    hintText: "Password",
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() => _obscure = !_obscure);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              GestureDetector(
                onTap: _isLoading ? null : _handleLogin,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.arrow_forward,
                            size: 28,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 👇 Forgot password link
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ForgotPasswordScreen(
                        email: widget.email,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Forgot password?",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginEmailScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Not you?",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
