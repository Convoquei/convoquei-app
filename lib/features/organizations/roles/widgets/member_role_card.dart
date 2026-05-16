import 'package:convoquei_app/design_system/ds.dart';
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

  @override
  Widget build(BuildContext context) {
    return DSCard(
      child: Row(
        children: [
          DSAvatar(name: userName, avatarUrl: avatarUrl ?? '', radius: 16),
          const SizedBox(width: DSSpacing.md),
          Expanded(
            child: Row(
              children: [
                DSText(userName, variant: DSTextVariant.labelMedium),
                if (badge != null) ...[
                  const SizedBox(width: DSSpacing.sm),
                  badge!,
                ],
              ],
            ),
          ),
          if (actionIcon != null)
            DSIconButton(
              icon: actionIcon!,
              iconColor: context.colors.textSecondary,
              size: 32,
              onPressed: onActionTap,
            ),
        ],
      ),
    );
  }
}
