import 'package:flutter/material.dart';

import '../../../core/constants/app_breakpoints.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_logo.dart';
import '../../auth/models/user_model.dart';

class PerfilHeader extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onNotificationTap;

  const PerfilHeader({
    super.key,
    required this.user,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBreakpoints.isWide(context)
        ? _WideHeader(user: user, onNotificationTap: onNotificationTap)
        : _NarrowHeader(user: user, onNotificationTap: onNotificationTap);
  }
}

class _WideHeader extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onNotificationTap;

  const _WideHeader({required this.user, this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          // Logo
          const AppLogo.icon(size: 32),
          const SizedBox(width: 24),

          // Search field
          Expanded(
            child: Padding(
              padding: const EdgeInsetsGeometry.fromLTRB(50, 0, 50, 0),
              child: SizedBox(
                height: 38,
                child: TextField(
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                  decoration: InputDecoration(
                    hintText: 'Procurar organizações ou eventos...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 18,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.15),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Notification bell
          _NotificationBell(onTap: onNotificationTap),
          const SizedBox(width: 16),

          // Greeting + avatar
          Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Bem-vindo,',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),
                  Text(
                    user.nameAbbreviation,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              _UserAvatar(user: user, radius: 18),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white.withValues(alpha: 0.8),
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Narrow header (< 600 px)
// ─────────────────────────────────────────────
class _NarrowHeader extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onNotificationTap;

  const _NarrowHeader({required this.user, this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _UserAvatar(user: user, radius: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bem-vindo,',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  user.nameAbbreviation,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          _NotificationBell(onTap: onNotificationTap),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Shared sub-widgets
// ─────────────────────────────────────────────

class _UserAvatar extends StatelessWidget {
  final UserModel user;
  final double radius;

  const _UserAvatar({required this.user, this.radius = 18});

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

class _NotificationBell extends StatelessWidget {
  final VoidCallback? onTap;

  const _NotificationBell({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: onTap,
          visualDensity: VisualDensity.compact,
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: AppTheme.secondaryColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}