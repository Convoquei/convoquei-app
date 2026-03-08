import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/action_button.dart';
import 'package:convoquei_app/features/organizations/events/pages/org_events_page.dart' show OrgEventsTab;
import 'package:flutter/material.dart';

enum EmptyEventsContext { single, range }

class EmptyEventsState extends StatelessWidget {
  final EmptyEventsContext eventsContext;
  final OrgEventsTab tab;
  final DateTime startDate;
  final DateTime? endDate;

  const EmptyEventsState({
    super.key,
    required this.eventsContext,
    required this.tab,
    required this.startDate,
    this.endDate,
  });

  String get _dateLabel {
    if (eventsContext == EmptyEventsContext.single) {
      return _formatFull(startDate);
    }
    return '${_formatShort(startDate)} até ${endDate != null ? _formatShort(endDate!) : '...'}';
  }

  String get _tabLabel => switch (tab) {
    OrgEventsTab.all => null,
    OrgEventsTab.mySchedules => 'que você está escalado',
    OrgEventsTab.pending => 'que estão pendentes de resposta',
  } ??
      '';

  String get _message {
    if (tab == OrgEventsTab.all) {
      return eventsContext == EmptyEventsContext.single
          ? 'Nenhum evento em $_dateLabel'
          : 'Nenhum evento entre $_dateLabel';
    }
    return eventsContext == EmptyEventsContext.single
        ? 'Nenhum evento em $_dateLabel\n$_tabLabel'
        : 'Nenhum evento entre $_dateLabel\n$_tabLabel';
  }

  String _formatFull(DateTime date) {
    const weekdays = [
      'Segunda-feira', 'Terça-feira', 'Quarta-feira',
      'Quinta-feira', 'Sexta-feira', 'Sábado', 'Domingo',
    ];
    const months = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
    ];
    return '${weekdays[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  String _formatShort(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_busy_rounded,
                size: 36,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Nenhum evento encontrado',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28)
          ],
        ),
      ),
    );
  }
}