
import 'package:convoquei_app/features/auth/models/user_model.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final UserModel user;
  final double radius;

  const UserAvatar({super.key, required this.user, this.radius = 18});

  @override
  Widget build(BuildContext context) {
    final hasAvatar = user.avatarUrl != null && user.avatarUrl!.isNotEmpty;
    return CircleAvatar(
      radius: radius,
      backgroundImage: hasAvatar ? NetworkImage(user.avatarUrl!) : null,
      backgroundColor: Colors.white.withValues(alpha: 0.3),
      child: !hasAvatar
          ? Text(
        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.85,
          fontWeight: FontWeight.w600,
        ),
      )
          : null,
    );
  }
}
