import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/org_events_tab.dart';
import 'package:flutter/material.dart';

/// Barra de abas horizontal para navegar entre as visões de eventos.
class EventsTabs extends StatelessWidget {
  final OrgEventsTab selected;
  final ValueChanged<OrgEventsTab> onChanged;

  const EventsTabs({super.key, required this.selected, required this.onChanged});

  static const _labels = {
    OrgEventsTab.all:         'Todos',
    OrgEventsTab.pending:     'Aguardando',
    OrgEventsTab.mySchedules: 'Minhas Escalas',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: OrgEventsTab.values.map((tab) {
          final isSelected = tab == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(tab),
              child: AnimatedContainer(
                duration: DSMotion.fast,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected ? context.colors.primary : context.colors.surface,
                  borderRadius: DSRadius.all(99),
                  border: Border.all(
                    color: isSelected
                        ? context.colors.primary
                        : context.colors.border,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: context.colors.primary.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : DSElevation.sm,
                ),
                child: Text(
                  _labels[tab]!,
                  style: context.textStyles.labelMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? context.colors.onPrimary : context.colors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
