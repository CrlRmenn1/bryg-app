import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/notification_service.dart';

class IndigencyRequestScreen extends StatefulWidget {
  const IndigencyRequestScreen({super.key});

  @override
  State<IndigencyRequestScreen> createState() => _IndigencyRequestScreenState();
}

class _IndigencyRequestScreenState extends State<IndigencyRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullnameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cellController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _reasonController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _prefillFromUser();
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _addressController.dispose();
    _cellController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _prefillFromUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

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
        _emailController.text = (data['email'] ?? '').toString();
        _birthdayController.text = (data['birthday'] ?? '').toString();
        setState(() {});
      }
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isSubmitting = true);

    try {
      final docRef =
          await FirebaseFirestore.instance.collection('requests').add({
        'userId': user.uid,
        'documentType': 'Indigency',
        'fullname': _fullnameController.text.trim(),
        'address': _addressController.text.trim(),
        'cellphone': _cellController.text.trim(),
        'email': _emailController.text.trim(),
        'birthday': _birthdayController.text.trim(),
        'reason': _reasonController.text.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await NotificationService.createNotification(
        userId: user.uid,
        title: 'Indigency request received',
        body:
            'Your Indigency request has been submitted and is now pending review.',
        type: 'request',
        relatedId: docRef.id,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indigency request submitted')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit request: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF7B2CF7);
    const fieldBg = Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Request Indigency',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
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
                _buildField('Reason', _reasonController, fieldBg),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
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
                            'Submit',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String hint,
    TextEditingController controller,
    Color bg, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) =>
            (value ?? '').trim().isEmpty ? '$hint is required' : null,
        decoration: InputDecoration(
          filled: true,
          fillColor: bg,
          hintText: hint,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
