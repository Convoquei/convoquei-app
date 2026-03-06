import 'package:convoquei_app/core/widgets/user_avatar.dart';
import 'package:flutter/material.dart';

class MemberRoleCard extends StatelessWidget {
  const MemberRoleCard({
    super.key,
    required this.userName,
    this.avatarUrl,
    this.badge,
    this.actionIcon,
    this.onActionTap,
  });

  final String userName;

  final String? avatarUrl;

  final Widget? badge;

  final IconData? actionIcon;

  final VoidCallback? onActionTap;

  String get _initials {
    final parts = userName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.first.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Avatar ──────────────────────────────────────────────────────
          UserAvatar(
            avatarUrl: avatarUrl ?? '',
            name: userName,
            radius: 16,
          ),

          //_Avatar(avatarUrl: avatarUrl, initials: _initials),
          const SizedBox(width: 12),

          // ── Nome + badge ─────────────────────────────────────────────────
          Expanded(
            child: Row(
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(width: 6),
                  badge!,
                ],
              ],
            ),
          ),

          // ── Botão de ação ────────────────────────────────────────────────
          if (actionIcon != null)
            IconButton(
              icon: Icon(actionIcon, size: 18),
              style: IconButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: onActionTap,
            ),
        ],
      ),
    );
  }
}
