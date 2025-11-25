import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class AdminRequestsScreen extends StatelessWidget {
  const AdminRequestsScreen({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF7B2CF7);

    final stream = FirebaseFirestore.instance
        .collection('requests')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Document Requests',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No requests yet.',
                style: TextStyle(color: Colors.black54),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              final documentType =
                  (data['documentType'] ?? 'Document').toString();
              final fullname = (data['fullname'] ?? 'Unknown').toString();
              final status = (data['status'] ?? 'pending').toString();
              final createdAt = data['createdAt'] as Timestamp?;
              final dt = createdAt?.toDate();
              final dateLabel =
                  dt == null ? '' : '${dt.month}/${dt.day}/${dt.year}';

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  title: Text(
                    '$documentType – $fullname',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (dateLabel.isNotEmpty)
                        Text(
                          'Requested: $dateLabel',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _statusColor(status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _capitalize(status),
                              style: TextStyle(
                                fontSize: 11,
                                color: _statusColor(status),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    _openRequestDetails(context, doc.id, data);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openRequestDetails(
      BuildContext context, String requestId, Map<String, dynamic> data) {
    final documentType = (data['documentType'] ?? 'Document').toString();
    final fullname = (data['fullname'] ?? '').toString();
    final address = (data['address'] ?? '').toString();
    final cellphone = (data['cellphone'] ?? '').toString();
    final email = (data['email'] ?? '').toString();
    final birthday = (data['birthday'] ?? '').toString();
    final idNumber = (data['idNumber'] ?? '').toString();
    final purpose = (data['purpose'] ?? '').toString();
    final yearsOfResidency = (data['yearsOfResidency'] ?? '').toString();
    final reason = (data['reason'] ?? '').toString();
    final status = (data['status'] ?? 'pending').toString();
    final userId = (data['userId'] ?? '').toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 12),

              Text(
                '$documentType Request',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              _infoRow('Name', fullname),
              _infoRow('Address', address),
              _infoRow('Phone', cellphone),
              _infoRow('Email', email),
              _infoRow('Birthday', birthday),
              if (idNumber.isNotEmpty) _infoRow('ID Number', idNumber),
              if (purpose.isNotEmpty) _infoRow('Purpose', purpose),
              if (yearsOfResidency.isNotEmpty)
                _infoRow('Residency', yearsOfResidency),
              if (reason.isNotEmpty) _infoRow('Reason', reason),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: status == 'approved'
                          ? null
                          : () => _handleDecision(
                                context,
                                requestId,
                                userId,
                                documentType,
                                'approved',
                              ),
                      child: const Text('Approve'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      onPressed: status == 'rejected'
                          ? null
                          : () => _handleDecision(
                                context,
                                requestId,
                                userId,
                                documentType,
                                'rejected',
                              ),
                      child: const Text('Reject'),
                    ),
                  ),
                ],
              ),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDecision(
    BuildContext context,
    String requestId,
    String userId,
    String documentType,
    String newStatus,
  ) async {
    final currentAdmin = FirebaseAuth.instance.currentUser;

    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update({
        'status': newStatus,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': currentAdmin?.uid,
      });

      // Send notification
      await NotificationService.createNotification(
        userId: userId,
        title: "$documentType request ${_capitalize(newStatus)}",
        body:
            "Your $documentType request was ${newStatus.toLowerCase()}.",
        type: 'request',
        relatedId: requestId,
      );

      // SAFE closing of sheet → avoids black screen
      Future.microtask(() {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Marked as ${_capitalize(newStatus)}"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}
