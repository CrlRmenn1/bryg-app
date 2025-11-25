import 'package:flutter/material.dart';

import 'barangay_clearance_screen.dart';
import 'residency_request_screen.dart';
import 'cedula_request_screen.dart';
import 'indigency_request_screen.dart';

class RequestScreen extends StatelessWidget {
  const RequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const pillBg = Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Settings',
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              _RequestButton(
                label: 'Request Barangay Clearance',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BarangayClearanceScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _RequestButton(
                label: 'Request Residency',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ResidencyRequestScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _RequestButton(
                label: 'Request Cedula',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CedulaRequestScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _RequestButton(
                label: 'Request Indigency',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const IndigencyRequestScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _RequestButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const pillBg = Color(0xFFF5F5F5);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: pillBg,
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
