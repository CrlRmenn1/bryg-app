import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'admin_chat_screen.dart';

class AdminChatListScreen extends StatelessWidget {
  const AdminChatListScreen({super.key});

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    final admin = FirebaseAuth.instance.currentUser;

    if (admin == null) {
      return const Scaffold(
        body: Center(
          child: Text('No admin logged in'),
        ),
      );
    }

    final adminId = admin.uid;

    // NOTE: removed orderBy('createdAt') to avoid composite index requirement
    final messagesStream = FirebaseFirestore.instance
        .collection('messages')
        .where('participants', arrayContains: adminId)
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: messagesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // this will show you the "needs index" error clearly if you keep orderBy
            return Center(
              child: Text(
                'Error loading conversations:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No conversations yet.',
                style: TextStyle(color: Colors.black54),
              ),
            );
          }

          // copy list so we can sort it
          final docs = snapshot.data!.docs.toList();

          // sort by createdAt desc on the client
          docs.sort((a, b) {
            final da = a.data();
            final db = b.data();
            final tsa = da['createdAt'];
            final tsb = db['createdAt'];

            final ta = tsa is Timestamp
                ? tsa.toDate()
                : DateTime.fromMillisecondsSinceEpoch(0);
            final tb = tsb is Timestamp
                ? tsb.toDate()
                : DateTime.fromMillisecondsSinceEpoch(0);

            return tb.compareTo(ta); // newest first
          });

          // Build a map: otherUserId -> latest message doc
          final Map<String, QueryDocumentSnapshot<Map<String, dynamic>>>
              latestByUser = {};

          for (final doc in docs) {
            final data = doc.data();

            final participantsRaw = data['participants'];
            if (participantsRaw is! List) continue;

            final participants = List<String>.from(
              participantsRaw.map((e) => e.toString()),
            );

            if (!participants.contains(adminId)) continue;
            if (participants.length < 2) continue;

            // other participant
            final String otherId =
                participants.firstWhere((id) => id != adminId, orElse: () => '');

            if (otherId.isEmpty) continue;

            // because docs are already sorted desc, first time we see otherId is latest
            latestByUser.putIfAbsent(otherId, () => doc);
          }

          if (latestByUser.isEmpty) {
            return const Center(
              child: Text(
                'No conversations yet.',
                style: TextStyle(color: Colors.black54),
              ),
            );
          }

          final entries = latestByUser.entries.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final userId = entries[index].key;
              final lastMsgDoc = entries[index].value;
              final data = lastMsgDoc.data();

              final lastText = (data['text'] ?? '').toString();
              final createdAt = data['createdAt'] as Timestamp?;
              final dt = createdAt?.toDate();
              final timeLabel = dt == null ? '' : _timeAgo(dt);

              return _ConversationTile(
                userId: userId,
                lastMessage: lastText,
                timeLabel: timeLabel,
              );
            },
          );
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final String userId;
  final String lastMessage;
  final String timeLabel;

  const _ConversationTile({
    required this.userId,
    required this.lastMessage,
    required this.timeLabel,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF660094);

    // Fetch user info
    final userDocFuture =
        FirebaseFirestore.instance.collection('users').doc(userId).get();

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: userDocFuture,
      builder: (context, snapshot) {
        String name = 'User';
        String position = 'Resident';
        String? photoUrl;

        if (snapshot.hasData && snapshot.data!.data() != null) {
          final data = snapshot.data!.data()!;
          name = (data['fullname'] ?? 'User').toString();
          position = (data['position'] ?? 'Resident').toString();
          final p = (data['profilePictureUrl'] ?? '').toString();
          if (p.isNotEmpty) photoUrl = p;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  photoUrl != null ? NetworkImage(photoUrl!) : null,
              child: photoUrl == null
                  ? const Icon(Icons.person_outline, color: Colors.grey)
                  : null,
            ),
            title: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  position,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 2),
                Text(
                  lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
            trailing: Text(
              timeLabel,
              style: const TextStyle(fontSize: 11, color: Colors.black45),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminChatScreen(
                    userId: userId,
                    userName: name,
                    userPhotoUrl: photoUrl,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
