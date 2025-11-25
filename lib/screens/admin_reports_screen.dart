import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/notification_service.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'resolved':
        return Colors.green;
      case 'in_review':
        return Colors.orange;
      case 'dismissed':
        return Colors.red;
      case 'pending':
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'resolved':
        return 'Resolved';
      case 'in_review':
        return 'In review';
      case 'dismissed':
        return 'Dismissed';
      case 'pending':
      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('reports')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Reports / Complaints',
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
                'No reports yet.',
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

              final title = (data['title'] ?? 'Report').toString();
              final type = (data['reportType'] ?? 'Complaint').toString();
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
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87),
                      ),
                      if (dateLabel.isNotEmpty)
                        Text(
                          'Filed: $dateLabel',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54),
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
                              _statusLabel(status),
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
                    _openReportDetails(context, doc.id, data);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openReportDetails(
      BuildContext context, String reportId, Map<String, dynamic> data) {
    final title = (data['title'] ?? '').toString();
    final description = (data['description'] ?? '').toString();
    final type = (data['reportType'] ?? 'Complaint').toString();
    final status = (data['status'] ?? 'pending').toString();
    final userId = (data['userId'] ?? '').toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SafeArea(
            top: false,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Text(
                    type,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        'Status: ',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      Text(
                        _statusLabel(status),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _statusColor(status),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: status == 'in_review'
                              ? null
                              : () async {
                                  await _updateReportStatus(
                                    context,
                                    reportId,
                                    userId,
                                    title,
                                    'in_review',
                                  );
                                },
                          child: const Text('In review'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: status == 'resolved'
                              ? null
                              : () async {
                                  await _updateReportStatus(
                                    context,
                                    reportId,
                                    userId,
                                    title,
                                    'resolved',
                                  );
                                },
                          child: const Text('Resolve'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      onPressed: status == 'dismissed'
                          ? null
                          : () async {
                              await _updateReportStatus(
                                context,
                                reportId,
                                userId,
                                title,
                                'dismissed',
                              );
                            },
                      child: const Text('Dismiss'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Close',
                        style:
                            TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateReportStatus(
    BuildContext context,
    String reportId,
    String userId,
    String title,
    String newStatus,
  ) async {
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No userId on this report')),
      );
      return;
    }

    try {
      final currentAdmin = FirebaseAuth.instance.currentUser;
      final ref =
          FirebaseFirestore.instance.collection('reports').doc(reportId);

      await ref.update({
        'status': newStatus,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': currentAdmin?.uid,
      });

      final label = _statusLabel(newStatus);

      // 🔔 Notify user
      await NotificationService.createNotification(
        userId: userId,
        title: 'Your report: $label',
        body: 'Your report "$title" status is now: $label.',
        type: 'report',
        relatedId: reportId,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report marked as $label')),
        );
        Navigator.pop(context); // close bottom sheet
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update report: $e')),
      );
    }
  }
}
