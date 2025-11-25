import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/auth_service.dart';
import '../widgets/user_avatar.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? goHome;

  const ProfileScreen({super.key, this.goHome});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _positionController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;

  String? _photoUrl;
  File? _newPhotoFile;

  User? get _firebaseUser => AuthService.currentUser;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = _firebaseUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();
      if (data != null) {
        _nameController.text = (data['fullname'] ?? '').toString();
        _emailController.text = (data['email'] ?? '').toString();
        _addressController.text = (data['address'] ?? '').toString();
        _phoneController.text = (data['cellphone'] ?? '').toString();
        _birthdayController.text = (data['birthday'] ?? '').toString();
        _positionController.text = (data['position'] ?? '').toString();
        _photoUrl = (data['profilePictureUrl'] ?? '').toString();
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickNewPhoto() async {
    if (!_isEditing) return;

    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() => _newPhotoFile = File(picked.path));
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _firebaseUser;
    if (user == null) return;

    setState(() => _isSaving = true);

    String? newUrl = _photoUrl;

    // upload new photo
    if (_newPhotoFile != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures/${user.uid}.jpg');

      await ref.putFile(_newPhotoFile!);
      newUrl = await ref.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'fullname': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'address': _addressController.text.trim(),
      'cellphone': _phoneController.text.trim(),
      'birthday': _birthdayController.text.trim(),
      'position': _positionController.text.trim(),
      'profilePictureUrl': newUrl,
    });

    setState(() {
      _photoUrl = newUrl;
      _isEditing = false;
      _isSaving = false;
      _newPhotoFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF660094);
    const fieldBg = Color(0xFFF5F5F5);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87, size: 20),
          onPressed: () {
            if (widget.goHome != null) {
              widget.goHome!();
            } else if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            TextButton(
              onPressed: () {
                if (_isEditing) {
                  _saveProfile();
                } else {
                  setState(() => _isEditing = true);
                }
              },
              child: Text(
                _isEditing ? "Done" : "Edit",
                style: const TextStyle(color: accent),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 12),

            /// FIXED AVATAR (editable, shows uploaded image)
            GestureDetector(
              onTap: _pickNewPhoto,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: UserAvatar(
                      photoUrl: _photoUrl,
                      fileImage:
                          _newPhotoFile != null ? FileImage(_newPhotoFile!) : null,
                      radius: 48,
                    ),
                  ),

                  if (_isEditing)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 16),
                    )
                ],
              ),
            ),

            const SizedBox(height: 16),

            Text(
              _nameController.text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              _positionController.text,
              style: const TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 18),

            Divider(color: Colors.grey.shade300),

            const SizedBox(height: 16),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildField("Address", _addressController, fieldBg,
                      enabled: _isEditing, maxLines: 2),
                  _buildField("Cellphone No.", _phoneController, fieldBg,
                      enabled: _isEditing),
                  _buildField("Email", _emailController, fieldBg,
                      enabled: _isEditing),
                  _buildField("Birthday", _birthdayController, fieldBg,
                      enabled: _isEditing),
                  _buildField("Position", _positionController, fieldBg,
                      enabled: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    Color fieldBg, {
    bool enabled = true,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        validator: (value) =>
            enabled && (value ?? "").isEmpty ? "$label is required" : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: enabled ? fieldBg : fieldBg.withOpacity(.7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
