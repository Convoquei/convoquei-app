import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/features/organizations/models/organization_invite_model.dart';
import 'package:flutter/material.dart';

class InviteCard extends StatelessWidget {
  final OrganizationInviteModel invite;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const InviteCard({
    super.key,
    required this.invite,
    this.onAccept,
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(
          color: AppTheme.textSecondary.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          // Ícone de envelope
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.drafts_outlined,
              color: AppTheme.secondaryColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          // Textos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  invite.organization,
                  style: theme.textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodySmall,
                    children: [
                      const TextSpan(text: 'por '),
                      TextSpan(
                        text: invite.invitedBy,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Botões de ação
          _IconAction(
            icon: Icons.check_rounded,
            color: AppTheme.secondaryColor,
            onPressed: onAccept,
          ),
          const SizedBox(width: 6),
          _IconAction(
            icon: Icons.close_rounded,
            color: AppTheme.textSecondary,
            onPressed: onDecline,
          ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const _IconAction({
    required this.icon,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}