import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_assignment_mode.dart';
import 'package:flutter/material.dart';

/// Cartão de seleção/exibição do modo de aprovação de um evento.
///
/// Quando [onTap] é nulo, o card é exibido em modo somente-leitura
/// (sem interação, mas ainda reflete o estado [selected] visualmente).
class AssignmentModeCard extends StatelessWidget {
  final OrganizationEventAssignmentMode mode;
  final bool selected;
  final bool locked;
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;

  /// Quando nulo, o card é somente-leitura (sem efeito de toque).
  final VoidCallback? onTap;

  const AssignmentModeCard({
    super.key,
    required this.mode,
    required this.selected,
    this.locked = false,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (locked || onTap == null) ? null : onTap,
      child: AnimatedContainer(
        duration: DSMotion.fast,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: locked ? context.colors.surfaceSubtle : context.colors.surface,
          borderRadius: DSRadius.allLg,
          border: Border.all(
            color: !locked && selected
                ? context.colors.primary
                : context.colors.border,
            width: !locked && selected ? 2 : 1,
          ),
        ),
        child: Opacity(
          opacity: locked ? 0.55 : 1.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (locked)
                Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.colors.border,
                      width: 2,
                    ),
                  ),
                )
              else
                Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? context.colors.primary
                          : context.colors.border,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: context.colors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: iconColor, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            title,
                            style: context.textStyles.titleSmall,
                          ),
                        ),
                        if (locked)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: context.colors.border,
                              borderRadius: DSRadius.all(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock_outline_rounded,
                                    size: 9,
                                    color: context.colors.textSecondary),
                                const SizedBox(width: 3),
                                Text(
                                  'Não disponível',
                                  style: context.textStyles.labelSmall?.copyWith(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: context.colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: context.textStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
