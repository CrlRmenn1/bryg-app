import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminChatScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String? userPhotoUrl;

  const AdminChatScreen({
    super.key,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
  });

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  User? get _currentAdmin => FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final admin = _currentAdmin;
    if (admin == null) return;

    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    try {
      await FirebaseFirestore.instance.collection('messages').add({
        'senderId': admin.uid,
        'recipientId': widget.userId,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
        'participants': [admin.uid, widget.userId],
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  String _formatTime(Timestamp? ts) {
    if (ts == null) return '';
    final d = ts.toDate();
    int hour = d.hour;
    final minute = d.minute.toString().padLeft(2, '0');
    final isPm = hour >= 12;
    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }
    final suffix = isPm ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  @override
  Widget build(BuildContext context) {
    const Color accent = Color(0xFF660094);
    final admin = _currentAdmin;

    if (admin == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text('No admin logged in')),
      );
    }

    final adminId = admin.uid;

    final messagesStream = FirebaseFirestore.instance
        .collection('messages')
        .where('participants', arrayContains: adminId)
        .orderBy('createdAt', descending: false)
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: accent,
            size: 20,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: accent,
              backgroundImage: widget.userPhotoUrl != null
                  ? NetworkImage(widget.userPhotoUrl!)
                  : null,
              child: widget.userPhotoUrl == null
                  ? const Icon(Icons.person_outline, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const Text(
                  'Resident',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
        ),
      ),
      body: Column(
        children: [
          // -------- MESSAGES LIST --------
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet.\nStart the conversation!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  );
                }

                // Filter to only messages between this admin and this user
                final filteredDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data();

                  final participantsRaw = data['participants'];
                  if (participantsRaw is List) {
                    final participants = List<String>.from(
                      participantsRaw.map((e) => e.toString()),
                    );
                    return participants.contains(adminId) &&
                        participants.contains(widget.userId);
                  }

                  final senderId = (data['senderId'] ?? '').toString();
                  final recipientId = (data['recipientId'] ?? '').toString();
                  return (senderId == adminId &&
                          recipientId == widget.userId) ||
                      (senderId == widget.userId &&
                          recipientId == adminId);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet.\nStart the conversation!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  );
                }

                final width = MediaQuery.of(context).size.width;

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data();
                    final text = (data['text'] ?? '').toString();
                    final senderId = (data['senderId'] ?? '').toString();
                    final createdAt = data['createdAt'] as Timestamp?;
                    final timeLabel = _formatTime(createdAt);

                    // STANDARD: from admin POV
                    // admin (me) -> right, user -> left
                    final isMe = senderId == adminId;

                    final bubbleColor =
                        isMe ? accent : Colors.grey.shade200;
                    final textColor =
                        isMe ? Colors.white : Colors.black87;

                    final alignment = isMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft;

                    final crossAxis = isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start;

                    return Align(
                      alignment: alignment,
                      child: Column(
                        crossAxisAlignment: crossAxis,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            constraints: BoxConstraints(
                              maxWidth: width * 0.7,
                            ),
                            decoration: BoxDecoration(
                              color: bubbleColor,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft:
                                    Radius.circular(isMe ? 16 : 4),
                                bottomRight:
                                    Radius.circular(isMe ? 4 : 16),
                              ),
                            ),
                            child: Text(
                              text,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 13,
                                height: 1.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            timeLabel,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black45,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // -------- INPUT BAR --------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type a message…',
                        hintStyle: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(14),
                    elevation: 2,
                  ),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
