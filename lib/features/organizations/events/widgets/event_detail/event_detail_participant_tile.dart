import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/events/models/organization_event_details_model.dart';
import 'package:flutter/material.dart';

enum EventDetailParticipantVariant { candidate, assigned, pending, dismissed }

class EventDetailParticipantTile extends StatelessWidget {
  const EventDetailParticipantTile({
    super.key,
    required this.participant,
    required this.variant,
    this.onApprove,
    this.onReject,
    this.onRemove,
    this.onRequest,
    this.requestCooldown = false,
  });

  final OrganizationEventParticipantModel participant;
  final EventDetailParticipantVariant variant;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onRemove;
  final VoidCallback? onRequest;
  final bool requestCooldown;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          DSAvatar(
            name: participant.name,
            avatarUrl: participant.avatarUrl,
            radius: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.name,
                  style: context.textStyles.labelMedium.copyWith(
                    color: variant == EventDetailParticipantVariant.dismissed
                        ? context.colors.textSecondary
                        : context.colors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                _subtitle(context),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _trailing(context),
        ],
      ),
    );
  }

  Widget _subtitle(BuildContext context) {
    return switch (variant) {
      EventDetailParticipantVariant.dismissed => Text(
          'Informou indisponibilidade',
          style: context.textStyles.labelSmall.copyWith(
            color: context.colors.danger,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      EventDetailParticipantVariant.assigned => Text(
          participant.function ?? 'Escalado',
          style: context.textStyles.labelSmall.copyWith(
            color: context.colors.success,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      _ => participant.function != null
          ? Text(
              participant.function!,
              style: context.textStyles.labelSmall.copyWith(
                color: context.colors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            )
          : const SizedBox.shrink(),
    };
  }

  Widget _trailing(BuildContext context) => switch (variant) {
        EventDetailParticipantVariant.candidate when onApprove != null ||
            onReject != null =>
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionIcon(
                icon: Icons.check_rounded,
                color: context.colors.success,
                bgColor: context.colors.successTint,
                onTap: onApprove,
              ),
              const SizedBox(width: 6),
              _ActionIcon(
                icon: Icons.close_rounded,
                color: context.colors.danger,
                bgColor: context.colors.dangerTint,
                onTap: onReject,
              ),
            ],
          ),
        EventDetailParticipantVariant.assigned when onRemove != null =>
          _ActionIcon(
            icon: Icons.remove_rounded,
            color: context.colors.textSecondary,
            bgColor: context.colors.surfaceSubtle,
            onTap: onRemove,
          ),
        EventDetailParticipantVariant.pending when onRequest != null =>
          _RequestButton(
            onTap: onRequest,
            cooldown: requestCooldown,
          ),
        _ => const SizedBox.shrink(),
      };
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.bgColor,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: DSRadius.allSm,
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

class _RequestButton extends StatelessWidget {
  const _RequestButton({this.onTap, required this.cooldown});

  final VoidCallback? onTap;
  final bool cooldown;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: cooldown ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: cooldown
              ? context.colors.surfaceSubtle
              : context.colors.primaryTint,
          borderRadius: DSRadius.allSm,
          border: Border.all(
            color: cooldown
                ? context.colors.border
                : context.colors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          cooldown ? 'Enviado' : 'Solicitar',
          style: context.textStyles.labelSmall.copyWith(
            color: cooldown
                ? context.colors.textSecondary
                : context.colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
