import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminUserEditScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> initialData;

  const AdminUserEditScreen({
    super.key,
    required this.userId,
    required this.initialData,
  });

  @override
  State<AdminUserEditScreen> createState() => _AdminUserEditScreenState();
}

class _AdminUserEditScreenState extends State<AdminUserEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late String _position;

  bool _saving = false;

  final List<String> _positions = const [
    'Resident',
    'Barangay Captain',
    'Secretary',
    'Purok Leader',
    'Kagawad',
    'Treasurer',
    'Clerk',
  ];

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _nameController =
        TextEditingController(text: (data['fullname'] ?? '').toString());
    _emailController =
        TextEditingController(text: (data['email'] ?? '').toString());
    final pos = (data['position'] ?? 'Resident').toString();
    _position = _positions.contains(pos) ? pos : 'Resident';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final doc = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId);

      // auto role logic: anything except Resident is admin
      final newRole = _position == 'Resident' ? 'user' : 'admin';

      await doc.update({
        'fullname': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'position': _position,
        'role': newRole,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User updated')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const fieldBg = Color(0xFFF5F5F5);
    const accent = Color(0xFF7B2CF7);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Edit User',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Name
                TextFormField(
                  controller: _nameController,
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'Name is required' : null,
                  decoration: _inputDeco('Full name', fieldBg),
                ),
                const SizedBox(height: 12),

                // Email (read-only most of the time, but can edit if you want)
                TextFormField(
                  controller: _emailController,
                  readOnly: true,
                  decoration: _inputDeco('Email', fieldBg)
                      .copyWith(helperText: 'Email cannot be changed here'),
                ),
                const SizedBox(height: 12),

                // Position dropdown
                DropdownButtonFormField<String>(
                  value: _position,
                  items: _positions
                      .map(
                        (p) => DropdownMenuItem(
                          value: p,
                          child: Text(p),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    setState(() => _position = val);
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: fieldBg,
                    labelText: 'Position / Role',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _position == 'Resident'
                        ? 'This user will be a normal user.'
                        : 'This user will be treated as ADMIN.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: _saving ? null : _save,
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

  InputDecoration _inputDeco(String hint, Color bg) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: bg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }
}
