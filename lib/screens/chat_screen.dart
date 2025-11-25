import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  /// When provided, this will be called when the back button is pressed.
  /// In HomeScreen you should pass: `goHome: () => _onNavTap(0)`
  final VoidCallback? goHome;

  const ChatScreen({super.key, this.goHome});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  String? _adminId;
  String _adminName = 'Barangay Admin';
  String _adminRole = 'Barangay Admin';
  String? _adminPhotoUrl;
  bool _loadingAdmin = true;

  @override
  void initState() {
    super.initState();
    _loadAdmin();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadAdmin() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        final doc = snap.docs.first;
        final data = doc.data();
        _adminId = doc.id;
        _adminName = (data['fullname'] ?? 'Barangay Admin').toString();
        _adminRole = (data['position'] ?? 'Barangay Admin').toString();
        final photo = (data['profilePictureUrl'] ?? '').toString();
        if (photo.isNotEmpty) _adminPhotoUrl = photo;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load admin: $e')),
      );
    } finally {
      if (mounted) setState(() => _loadingAdmin = false);
    }
  }

  Future<void> _sendMessage() async {
    final user = _currentUser;
    if (user == null) return;

    if (_adminId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No admin account found.')),
      );
      return;
    }

    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    try {
      await FirebaseFirestore.instance.collection('messages').add({
        'senderId': user.uid,
        'recipientId': _adminId,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
        'participants': [user.uid, _adminId],
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
    final user = _currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: Text('Not logged in')),
      );
    }

    if (_loadingAdmin) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_adminId == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            'No admin account found.\nAsk your admin to register.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final messagesStream = FirebaseFirestore.instance
        .collection('messages')
        .where('participants', arrayContains: user.uid)
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
            // Prefer going back to Home tab via callback
            if (widget.goHome != null) {
              widget.goHome!();
            } else if (Navigator.canPop(context)) {
              // Fallback if ChatScreen was opened with Navigator.push
              Navigator.pop(context);
            }
          },
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: accent,
              backgroundImage:
                  _adminPhotoUrl != null ? NetworkImage(_adminPhotoUrl!) : null,
              child: _adminPhotoUrl == null
                  ? const Icon(Icons.person_outline, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _adminName,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  _adminRole,
                  style: const TextStyle(
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
                      'No messages yet.\nSay hello to the admin!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54),
                    ),
                  );
                }

                final filteredDocs = snapshot.data!.docs.where((doc) {
                  final data = doc.data();

                  // New format: participants array
                  final participantsRaw = data['participants'];
                  if (participantsRaw is List) {
                    final participants = List<String>.from(
                      participantsRaw.map((e) => e.toString()),
                    );
                    return participants.contains(user.uid) &&
                        participants.contains(_adminId);
                  }

                  // Old format (no participants): fallback to sender/recipient
                  final senderId = (data['senderId'] ?? '').toString();
                  final recipientId = (data['recipientId'] ?? '').toString();
                  return (senderId == user.uid && recipientId == _adminId) ||
                      (senderId == _adminId && recipientId == user.uid);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet.\nSay hello to the admin!',
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

                    // Standard Messenger logic:
                    // me (user) -> right, other (admin) -> left
                    final isMe = senderId == user.uid;

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
                  child: const Icon(Icons.send,
                      color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
