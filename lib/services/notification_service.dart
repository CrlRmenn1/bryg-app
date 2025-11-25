import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  /// Creates a notification document for a specific user.
  static Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    String? type,      // "request", "report", etc.
    String? relatedId, // id of request/report document
  }) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'relatedId': relatedId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
