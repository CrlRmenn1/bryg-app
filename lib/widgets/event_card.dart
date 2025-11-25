import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  /// Name of the person / account who posted
  final String posterName;

  /// Optional subtitle under the name (e.g. role / position)
  final String subtitle;

  /// Small timestamp text (e.g. "2h ago" or "Oct 5, 2025")
  final String timeLabel;

  /// Main caption / description of the post
  final String caption;

  /// Profile picture of poster (Network URL). If null, shows default avatar.
  final String? profileImageUrl;

  /// Image of the post (Network URL). If null, shows a subtle placeholder.
  final String? postImageUrl;

  const EventCard({
    super.key,
    this.posterName = 'Cristian',
    this.subtitle = 'Barangay Council',
    this.timeLabel = 'October 5, 2025',
    this.caption = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    this.profileImageUrl,
    this.postImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    const Color purple = Color(0xFF7B2CF7);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -------- HEADER (avatar + name + time) --------
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: purple.withOpacity(0.15),
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : null,
                  child: profileImageUrl == null
                      ? const Icon(Icons.person, color: purple)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        posterName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '•',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.black45,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeLabel,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // -------- CAPTION --------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              caption,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // -------- POST IMAGE --------
          if (postImageUrl != null && postImageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              child: AspectRatio(
                aspectRatio: 3 / 2,
                child: Image.network(
                  postImageUrl!,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Icon(
                Icons.photo,
                size: 40,
                color: Colors.grey[400],
              ),
            ),
        ],
      ),
    );
  }
}
