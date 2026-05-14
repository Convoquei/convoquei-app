import 'dart:async';

import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_assignment_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/orgnaization_event_membership_model.dart';
import 'package:flutter/material.dart';

/// Badge de urgência exibido quando o prazo de disponibilidade está próximo.
/// Conta regressivamente em tempo real.
class UrgentBadge extends StatefulWidget {
  final OrganizationEventMembershipModel event;

  const UrgentBadge({super.key, required this.event});

  @override
  State<UrgentBadge> createState() => _UrgentBadgeState();
}

class _UrgentBadgeState extends State<UrgentBadge> {
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.event.availabilityLockEpochSeconds;
    _startTimer();
  }

  @override
  void didUpdateWidget(UrgentBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.event.availabilityLockEpochSeconds !=
        widget.event.availabilityLockEpochSeconds) {
      _timer?.cancel();
      _remaining = widget.event.availabilityLockEpochSeconds;
      _startTimer();
    }
  }

  void _startTimer() {
    if (_remaining <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatRemaining(int seconds) {
    final d = Duration(seconds: seconds);
    if (d.inHours >= 1) {
      final h = d.inHours;
      final m = d.inMinutes.remainder(60);
      return m > 0 ? '${h}h ${m}min' : '${h}h';
    }
    return '${d.inMinutes}min';
  }

  String _buildText() {

    if (widget.event.assignmentMode == OrganizationEventAssignmentMode.automatic) {

      if (_remaining == 0) {
        return 'Processando fechamento de escala';
      }

      if (_remaining < 60) {
        return 'A escala será fechada em menos de 1 minuto';
      }

      return 'A escala será fechada em ${_formatRemaining(_remaining)}';
    }
    else {
      if (_remaining == 0) {
        return 'Processando bloqueio de disponibilidade';
      }

      if (_remaining < 60) {
        return 'Bloqueando disponibilidade em menos de 1 minuto';
      }

      return 'Bloqueando disponibilidade em ${_formatRemaining(_remaining)}';
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.dangerTint,
        borderRadius: DSRadius.allSm,
        border: Border.all(color: context.colors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 11,
            color: context.colors.danger,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              _buildText(),
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
