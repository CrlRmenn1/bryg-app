import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/auth_service.dart';
import 'login_email_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullnameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cellController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _passwordController = TextEditingController();

  // Only Resident is allowed
  final List<String> _positions = const ['Resident'];
  String _selectedPosition = 'Resident';

  File? _selectedImage;
  bool _isLoading = false;

  // 👇 NEW: password visibility state
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullnameController.dispose();
    _addressController.dispose();
    _cellController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Take Photo'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  title: const Text('Choose from Gallery'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          );
        },
      );

      if (source == null) return;

      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (_) {
      // ignore, just don’t crash UI
    }
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Clean email (remove spaces, newlines, etc.)
    final sanitizedEmail =
        _emailController.text.trim().replaceAll(RegExp(r'\s+'), '');

    final password = _passwordController.text.trim();

    // 1) Create account + user doc using your AuthService
    final error = await AuthService.signup(
      fullname: _fullnameController.text.trim(),
      address: _addressController.text.trim(),
      cellphone: _cellController.text.trim(),
      email: sanitizedEmail,
      birthday: _birthdayController.text.trim(),
      password: password,
      position: _selectedPosition,
    );

    if (error != null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    // 2) Make sure we are actually logged in so we can upload to Storage
    User? user = FirebaseAuth.instance.currentUser;

    // If AuthService.signup signed the user out, log them back in
    if (user == null) {
      try {
        final cred = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: sanitizedEmail, password: password);
        user = cred.user;
      } catch (e) {
        // If even this fails, we can’t upload the picture; continue but inform user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Account created, but failed to attach profile picture (auth error).',
              ),
            ),
          );
        }
      }
    }

    // 3) Upload profile picture & save URL in Firestore if we have both user + image
    if (user != null && _selectedImage != null) {
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_pictures/${user.uid}.jpg');

        await ref.putFile(_selectedImage!);
        final url = await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'profilePictureUrl': url});
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Account created, but failed to save profile picture.',
              ),
            ),
          );
        }
      }
    }

    if (!mounted) return;

    setState(() => _isLoading = false);

    // 4) Go back to login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginEmailScreen()),
      (route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account created successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color accent = Color(0xFF660094);
    const Color fieldBg = Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Purple blob on top-right
            Positioned(
              right: -80,
              top: -80,
              child: Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.all(Radius.circular(120)),
                ),
              ),
            ),

            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Create\nAccount',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Profile picture picker
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: accent, width: 2),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_selectedImage != null)
                              ClipOval(
                                child: Image.file(
                                  _selectedImage!,
                                  width: 92,
                                  height: 92,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              const Icon(
                                Icons.person_outline,
                                size: 40,
                                color: Colors.grey,
                              ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: accent,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // FORM
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildField('FullName', _fullnameController, fieldBg),
                        _buildField('Address', _addressController, fieldBg),
                        _buildField('Cellphone No.', _cellController, fieldBg,
                            keyboardType: TextInputType.phone),
                        _buildField('Email', _emailController, fieldBg,
                            keyboardType: TextInputType.emailAddress),
                        _buildField('Birthday', _birthdayController, fieldBg),
                        _buildField('Password', _passwordController, fieldBg,
                            isPassword: true),

                        // Position (Resident only)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: DropdownButtonFormField<String>(
                            value: _selectedPosition,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: fieldBg,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: _positions
                                .map(
                                  (pos) => DropdownMenuItem(
                                    value: pos,
                                    child: Text(pos),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedPosition = value);
                              }
                            },
                          ),
                        ),

                        // Done button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _isLoading ? null : _handleSignup,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Done',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        TextButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginEmailScreen(),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String hint,
    TextEditingController controller,
    Color bg, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        keyboardType: keyboardType,
        validator: (value) =>
            value!.trim().isEmpty ? '$hint is required' : null,
        decoration: InputDecoration(
          filled: true,
          fillColor: bg,
          hintText: hint,
          // 👇 NEW: show/hide icon only for password field
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
