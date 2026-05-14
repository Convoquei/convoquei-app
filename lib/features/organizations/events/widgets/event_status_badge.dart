import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_status.dart';
import 'package:flutter/material.dart';

/// Badge "Em andamento" exibido quando o evento está em progresso.
/// Retorna [SizedBox.shrink] para qualquer outro status.
class EventStatusBadge extends StatelessWidget {
  final OrganizationEventStatus status;

  const EventStatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    if (status != OrganizationEventStatus.inProgress) {
      return const SizedBox.shrink();
    }

    return DSBadge(
      label: 'Em andamento',
      color: context.colors.success,
      variant: DSBadgeVariant.soft,
      size: DSBadgeSize.sm,
    );
  }
}
