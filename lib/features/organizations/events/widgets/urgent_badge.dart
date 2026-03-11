import 'package:convoquei_app/features/organizations/events/models/orgnaization_event_membership_model.dart';
import 'package:flutter/material.dart';

/// Badge de urgência exibido quando o prazo de disponibilidade está próximo.
class UrgentBadge extends StatelessWidget {
  final OrganizationEventMembershipModel event;

  const UrgentBadge({super.key, required this.event});

  String _formatRemaining(Duration d) {
    if (d.inHours >= 1) {
      final h = d.inHours;
      final m = d.inMinutes.remainder(60);
      return m > 0 ? '${h}h ${m}min' : '${h}h';
    }
    return '${d.inMinutes}min';
  }

  @override
  Widget build(BuildContext context) {
    final remaining = Duration(seconds: event.availabilityLockEpochSeconds);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded,
              size: 11, color: Color(0xFFDC2626)),
          const SizedBox(width: 4),
          Text(
            'Fecha em ${_formatRemaining(remaining)}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }
}
