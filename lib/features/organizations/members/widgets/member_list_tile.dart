import 'package:convoquei_app/features/organizations/shared/models/enums/organization_permission.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_member_model.dart';
import 'package:flutter/material.dart';

class MemberListTile extends StatelessWidget {
  const MemberListTile({
    super.key,
    required this.member,
    this.isCurrentUser = false,
    this.onOptionsPressed,
  });

  final OrganizationMemberModel member;
  final bool isCurrentUser;
  final VoidCallback? onOptionsPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onOptionsPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                _Avatar(name: member.name, avatarUrl: member.avatarUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _NameRow(
                        name: member.name,
                        isCurrentUser: isCurrentUser,
                        isOwner: member.permissions.contains(
                          OrganizationPermissionEnum.owner,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _BadgesRow(member: member),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFCBD5E1),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _BadgesRow extends StatelessWidget {
  const _BadgesRow({required this.member});

  final OrganizationMemberModel member;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        _RoleBadge(permissions: member.permissions),
        if (member.groups.isNotEmpty)
          ...member.groups.map((g) => _SmallBadge(label: g.name)),
      ],
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.permissions});

  final List<OrganizationPermissionEnum> permissions;

  @override
  Widget build(BuildContext context) {
    final isOwner = permissions.contains(OrganizationPermissionEnum.owner);
    final isLider =
        !isOwner &&
        (permissions.contains(OrganizationPermissionEnum.manageGroups) ||
            permissions.contains(OrganizationPermissionEnum.inviteMembers));

    if (isOwner) return const SizedBox.shrink();

    if (isLider) {
      return _badge(
        'LÍDER',
        const Color(0xFF0369A1),
        const Color(0xFFEFF6FF),
        const Color(0xFFBAE6FD),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _badge(
    String label,
    Color textColor,
    Color bgColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _NameRow extends StatelessWidget {
  const _NameRow({
    required this.name,
    required this.isCurrentUser,
    this.isOwner = false,
  });

  final String name;
  final bool isCurrentUser;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Flexible(
          child: Text(
            name,
            style: theme.textTheme.titleSmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isOwner) ...[
          const SizedBox(width: 4),
          const Text('👑', style: TextStyle(fontSize: 13)),
        ],
        if (isCurrentUser) ...[
          const SizedBox(width: 4),
          Text(
            '(Você)',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 10,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ],
    );
  }
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Color(0xFF475569),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.avatarUrl});

  final String name;
  final String avatarUrl;

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: avatarUrl.isNotEmpty
            ? Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    _InitialsFallback(initials: _initials),
              )
            : _InitialsFallback(initials: _initials),
      ),
    );
  }
}

class _InitialsFallback extends StatelessWidget {
  const _InitialsFallback({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFF7ED),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Color(0xFFEA580C),
        ),
      ),
    );
  }
}