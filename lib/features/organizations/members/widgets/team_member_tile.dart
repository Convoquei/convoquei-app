import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Badge de papel/grupo do membro
// ---------------------------------------------------------------------------

enum TeamMemberBadgeStyle { admin, leader, role, warning }

class TeamMemberBadge extends StatelessWidget {
  const TeamMemberBadge({
    super.key,
    required this.label,
    this.style = TeamMemberBadgeStyle.role,
    this.icon,
  });

  final String label;
  final TeamMemberBadgeStyle style;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (style) {
      TeamMemberBadgeStyle.admin => (
          const Color(0xFFF5F3FF),
          const Color(0xFF7C3AED),
          const Color(0xFFDDD6FE),
        ),
      TeamMemberBadgeStyle.leader => (
          const Color(0xFFEFF6FF),
          AppTheme.primaryColor,
          const Color(0xFFBFDBFE),
        ),
      TeamMemberBadgeStyle.warning => (
          const Color(0xFFFFF7ED),
          const Color(0xFFC2410C),
          const Color(0xFFFED7AA),
        ),
      TeamMemberBadgeStyle.role => (
          const Color(0xFFF8FAFC),
          AppTheme.textSecondary,
          const Color(0xFFE2E8F0),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: fg),
            const SizedBox(width: 3),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tile de membro da equipa
// ---------------------------------------------------------------------------

/// Mock data class — substituir por modelos reais ao refatorar.
class TeamMemberData {
  const TeamMemberData({
    required this.name,
    this.avatarUrl,
    this.isCurrentUser = false,
    this.badges = const [],
    this.hasNoGroup = false,
  });

  final String name;
  final String? avatarUrl;
  final bool isCurrentUser;
  final List<TeamMemberBadge> badges;
  final bool hasNoGroup;

  /// Iniciais para o avatar fallback.
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class TeamMemberTile extends StatelessWidget {
  const TeamMemberTile({
    super.key,
    required this.member,
    required this.onMenuTap,
    this.onAssignGroupTap,
  });

  final TeamMemberData member;
  final VoidCallback onMenuTap;
  final VoidCallback? onAssignGroupTap;

  @override
  Widget build(BuildContext context) {
    final isWarning = member.hasNoGroup;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: isWarning ? const Color(0xFFFFF7ED) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWarning
              ? const Color(0xFFFED7AA)
              : Colors.transparent,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // ── avatar ──────────────────────────────────────────────────
            _buildAvatar(),
            const SizedBox(width: 12),

            // ── name + badges ────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          member.name,
                          style: Theme.of(context).textTheme.titleSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (member.isCurrentUser) ...[
                        const SizedBox(width: 4),
                        Text(
                          '(Você)',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: [
                      ...member.badges,
                      if (member.hasNoGroup) ...[
                        TeamMemberBadge(
                          label: 'Sem grupo',
                          style: TeamMemberBadgeStyle.warning,
                          icon: Icons.warning_amber_rounded,
                        ),
                        if (onAssignGroupTap != null)
                          _AssignGroupButton(onTap: onAssignGroupTap!),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // ── menu button ──────────────────────────────────────────────
            _MenuButton(onTap: onMenuTap),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (member.avatarUrl != null && member.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(member.avatarUrl!),
        backgroundColor: const Color(0xFFE2E8F0),
      );
    }

    final isWarning = member.hasNoGroup;
    return CircleAvatar(
      radius: 24,
      backgroundColor: isWarning ? Colors.white : const Color(0xFFEFF6FF),
      child: Text(
        member.initials,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: isWarning
              ? const Color(0xFFEA580C)
              : AppTheme.primaryColor,
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
        ),
        child: const Icon(
          Icons.more_vert_rounded,
          size: 20,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}

class _AssignGroupButton extends StatelessWidget {
  const _AssignGroupButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Atribuir agora',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 2),
          const Icon(Icons.arrow_forward_rounded,
              size: 10, color: AppTheme.primaryColor),
        ],
      ),
    );
  }
}

