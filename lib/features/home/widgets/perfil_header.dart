import 'package:convoquei_app/core/widgets/user_avatar.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_breakpoints.dart';
import '../../../core/theme/app_theme.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Row(
            children: [
              UserAvatar(name: user.name, avatarUrl: user.avatarUrl ?? "", radius: 18),
              const SizedBox(width: 12),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
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

            ],
          ),

          const SizedBox(width: 24),

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

          _NotificationBell(onTap: onNotificationTap),
          const SizedBox(width: 16),
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
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        children: [
          UserAvatar(name: user.name, avatarUrl: user.avatarUrl ?? "", radius: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bem-vindo de volta,',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  user.nameAbbreviation,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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