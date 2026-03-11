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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD1FAE5)),
      ),
      child: const Text(
        'Em andamento',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFF059669),
        ),
      ),
    );
  }
}
