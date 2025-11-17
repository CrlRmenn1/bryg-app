import 'package:flutter/material.dart';
import 'barangay_clearance_screen.dart';
import 'residency_request_screen.dart';
import 'cedula_request_screen.dart';
import 'indigency_request_screen.dart';

class RequestScreen extends StatelessWidget {
  const RequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF7B2CBF);

    final List<_RequestItem> requests = [
      _RequestItem(
        label: "Request Barangay Clearance",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BarangayClearanceScreen()),
          );
        },
      ),
      _RequestItem(
        label: "Request Residency",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ResidencyRequestScreen()),
          );
        },
      ),
      _RequestItem(
        label: "Request Cedula",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CedulaRequestScreen()),
          );
        },
      ),
      _RequestItem(
        label: "Request Indigency",
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const IndigencyRequestScreen()),
          );
        },
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.purple),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Request",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: requests.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5F2F9),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                onPressed: item.onTap,
                child: Text(
                  item.label,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _RequestItem {
  final String label;
  final VoidCallback onTap;

  const _RequestItem({required this.label, required this.onTap});
}
