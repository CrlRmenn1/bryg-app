import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final double radius;
  final FileImage? fileImage;

  const UserAvatar({
    super.key,
    required this.photoUrl,
    this.radius = 40,
    this.fileImage,
  });

  @override
  Widget build(BuildContext context) {
    final hasNetwork = photoUrl != null && photoUrl!.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: fileImage != null
          ? fileImage
          : (hasNetwork ? NetworkImage(photoUrl!) : null),
      child: fileImage == null && !hasNetwork
          ? const Icon(Icons.person_outline, color: Colors.grey, size: 42)
          : null,
    );
  }
}
