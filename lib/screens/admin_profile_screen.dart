import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullnameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cellController = TextEditingController();
  final _birthdayController = TextEditingController();

  String _email = '';
  String _position = 'Secretary';
  String? _profilePictureUrl;

  bool _loading = true;
  bool _saving = false;

  File? _newImageFile;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadAdminProfile();
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _addressController.dispose();
    _cellController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminProfile() async {
    final user = _currentUser;
    if (user == null) {
      setState(() {
        _loading = false;
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();
      if (data != null && mounted) {
        _fullnameController.text = (data['fullname'] ?? '').toString();
        _addressController.text = (data['address'] ?? '').toString();
        _cellController.text = (data['cellphone'] ?? '').toString();
        _birthdayController.text = (data['birthday'] ?? '').toString();
        _email = (data['email'] ?? user.email ?? '').toString();
        _position = (data['position'] ?? 'Secretary').toString();
        _profilePictureUrl =
            (data['profilePictureUrl'] ?? '').toString().isNotEmpty
                ? (data['profilePictureUrl'] as String)
                : null;
      }
    } catch (_) {
      // you can show a snackbar if needed
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (picked == null) return;
    setState(() {
      _newImageFile = File(picked.path);
    });
  }

  Future<String?> _uploadProfileImage(String uid) async {
    if (_newImageFile == null) return _profilePictureUrl;

    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_pictures')
        .child('$uid.jpg');

    await ref.putFile(_newImageFile!);
    return await ref.getDownloadURL();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _currentUser;
    if (user == null) return;

    setState(() => _saving = true);

    try {
      final imageUrl = await _uploadProfileImage(user.uid);

      final docRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      await docRef.update({
        'fullname': _fullnameController.text.trim(),
        'address': _addressController.text.trim(),
        'cellphone': _cellController.text.trim(),
        'birthday': _birthdayController.text.trim(),
        'position': _position, // keep admin's position
        'profilePictureUrl': imageUrl ?? '',
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF7B2CF7);
    const fieldBg = Color(0xFFF5F5F5);

    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text('No admin logged in'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Admin Profile',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Avatar + camera button
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _newImageFile != null
                            ? FileImage(_newImageFile!)
                            : (_profilePictureUrl != null
                                ? NetworkImage(_profilePictureUrl!)
                                    as ImageProvider
                                : null),
                        child: (_newImageFile == null &&
                                _profilePictureUrl == null)
                            ? const Icon(
                                Icons.person_outline,
                                size: 46,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _pickImage,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Position label (readonly)
                Text(
                  _position,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),

                // Full name
                _buildField(
                  hint: 'Full name',
                  controller: _fullnameController,
                  bg: fieldBg,
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Full name is required' : null,
                ),
                const SizedBox(height: 12),

                // Email (readonly)
                TextFormField(
                  enabled: false,
                  initialValue: _email,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: fieldBg,
                    labelText: 'Email',
                    helperText: 'Email cannot be changed here',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Address
                _buildField(
                  hint: 'Address',
                  controller: _addressController,
                  bg: fieldBg,
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Address is required' : null,
                ),
                const SizedBox(height: 12),

                // Cellphone
                _buildField(
                  hint: 'Cellphone No.',
                  controller: _cellController,
                  bg: fieldBg,
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Cellphone is required' : null,
                ),
                const SizedBox(height: 12),

                // Birthday (simple text, you can make it a date picker later)
                _buildField(
                  hint: 'Birthday',
                  controller: _birthdayController,
                  bg: fieldBg,
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Birthday is required' : null,
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: _saving ? null : _saveProfile,
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String hint,
    required TextEditingController controller,
    required Color bg,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: bg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}
