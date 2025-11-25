import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Central place for all Firestore reads/writes used by the app.
/// You can call these methods from your screens instead of
/// writing Firestore code everywhere.
class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? get currentUserId => _auth.currentUser?.uid;

  // ===================== USERS =====================

  static CollectionReference<Map<String, dynamic>> get _usersCol =>
      _db.collection('users');

  static Future<DocumentSnapshot<Map<String, dynamic>>> getUserById(
    String uid,
  ) {
    return _usersCol.doc(uid).get();
  }

  static Future<void> updateUserProfile(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _usersCol.doc(uid).set(data, SetOptions(merge: true));
  }

  /// Stream of all users (for admin user list)
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamAllUsers() {
    return _usersCol.orderBy('fullname', descending: false).snapshots();
  }

  /// Stream of users filtered by role (e.g., 'resident', 'admin')
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamUsersByRole(
    String role,
  ) {
    return _usersCol.where('role', isEqualTo: role).snapshots();
  }

  // ===================== EVENTS =====================

  static CollectionReference<Map<String, dynamic>> get _eventsCol =>
      _db.collection('events');

  /// Create a new event (admin only in UI)
  static Future<void> createEvent({
    required String title,
    required String eventType,
    required String location,
    required DateTime dateTime,
    String? imageUrl,
  }) async {
    final creatorId = currentUserId;

    await _eventsCol.add({
      'title': title,
      'eventType': eventType,
      'location': location,
      'date': Timestamp.fromDate(dateTime),
      'imageUrl': imageUrl,
      'createdBy': creatorId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream events ordered by date (homepage)
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamEvents() {
    return _eventsCol.orderBy('date', descending: false).snapshots();
  }

  // ===================== ANNOUNCEMENTS =====================

  static CollectionReference<Map<String, dynamic>> get _announcementsCol =>
      _db.collection('announcements');

  /// Post a new announcement (admin)
  static Future<void> createAnnouncement({
    required String title,
    required String content,
  }) async {
    final creatorId = currentUserId;

    await _announcementsCol.add({
      'title': title,
      'content': content,
      'createdBy': creatorId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream announcements ordered by newest
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamAnnouncements() {
    return _announcementsCol
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ===================== REPORTS (COMPLAINTS) =====================

  static CollectionReference<Map<String, dynamic>> get _reportsCol =>
      _db.collection('reports');

  /// User submits report / complaint
  static Future<void> submitReport({
    required String reportType,
    required String description,
  }) async {
    final uid = currentUserId;
    if (uid == null) {
      throw Exception('User not logged in');
    }

    await _reportsCol.add({
      'userId': uid,
      'reportType': reportType,
      'description': description,
      'status': 'pending', // pending, seen, resolved
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream all reports (admin side)
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamAllReports() {
    return _reportsCol
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Stream reports for a specific user (user side, optional)
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamUserReports(
    String uid,
  ) {
    return _reportsCol
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Update report status (admin)
  static Future<void> updateReportStatus(
    String reportId,
    String status,
  ) async {
    await _reportsCol.doc(reportId).update({'status': status});
  }

  // ===================== REQUESTS (DOCUMENTS) =====================

  static CollectionReference<Map<String, dynamic>> get _requestsCol =>
      _db.collection('requests');

  /// Create a document request (barangay clearance, residency, etc.)
  static Future<void> createRequest({
    required String requestType,
    String? details,
  }) async {
    final uid = currentUserId;
    if (uid == null) {
      throw Exception('User not logged in');
    }

    await _requestsCol.add({
      'userId': uid,
      'requestType': requestType,
      'details': details,
      'status': 'pending', // pending, approved, rejected
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream all requests (admin side)
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamAllRequests() {
    return _requestsCol
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Stream requests for a specific user (user side)
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamUserRequests(
    String uid,
  ) {
    return _requestsCol
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Update request status (admin approves / rejects)
  static Future<void> updateRequestStatus({
    required String requestId,
    required String status,
    String? adminNote,
  }) async {
    final Map<String, dynamic> updateData = {
      'status': status,
    };

    if (adminNote != null && adminNote.isNotEmpty) {
      updateData['adminNote'] = adminNote;
    }

    await _requestsCol.doc(requestId).update(updateData);
  }

  // ===================== MESSAGES (CHAT) =====================

  static CollectionReference<Map<String, dynamic>> get _messagesCol =>
      _db.collection('messages');

  /// Send a message from one user to another.
  ///
  /// In your UI rules:
  /// - resident: senderId = resident, recipientId = admin
  /// - admin: can send to any user
  static Future<void> sendMessage({
    required String senderId,
    required String recipientId,
    required String text,
  }) async {
    await _messagesCol.add({
      'senderId': senderId,
      'recipientId': recipientId,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  /// Stream a conversation between 2 users (for chat screen)
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamConversation({
    required String userA,
    required String userB,
  }) {
    return _messagesCol
        .where('participants', arrayContainsAny: [userA, userB])
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  /// NOTE:
  /// To support the `participants` field above, you should save each message like:
  /// {
  ///   senderId: ...,
  ///   recipientId: ...,
  ///   participants: [senderId, recipientId],
  ///   ...
  /// }
  /// So you can adjust sendMessage() accordingly if you want to use this.

  /// Simpler alternative for a 1:1 chat if you don't use `participants`:
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamConversationSimple({
    required String userA,
    required String userB,
  }) {
    return _messagesCol
        .where('senderId', whereIn: [userA, userB])
        .where('recipientId', whereIn: [userA, userB])
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  /// Stream all messages where admin is involved (for admin chat list).
  /// You can use this and then group by the "other user" in UI.
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamAdminMessages(
    String adminId,
  ) {
    return _messagesCol
        .where('recipientId', isEqualTo: adminId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Mark a message as read
  static Future<void> markMessageAsRead(String messageId) async {
    await _messagesCol.doc(messageId).update({'isRead': true});
  }

  // ===================== NOTIFICATIONS =====================

  static CollectionReference<Map<String, dynamic>> get _notificationsCol =>
      _db.collection('notifications');

  /// Create a notification for a user (you can call this in admin screens).
  static Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    String? type, // e.g. 'event', 'announcement', 'request', 'report', 'message'
    String? relatedId,
  }) async {
    await _notificationsCol.add({
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'relatedId': relatedId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream notifications for the current user
  static Stream<QuerySnapshot<Map<String, dynamic>>>
      streamNotificationsForCurrentUser() {
    final uid = currentUserId;
    if (uid == null) {
      // Return an empty stream if not logged in
      return const Stream.empty();
    }

    return _notificationsCol
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    await _notificationsCol.doc(notificationId).update({'isRead': true});
  }
}
