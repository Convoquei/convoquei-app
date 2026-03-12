import 'package:convoquei_app/core/theme/app_theme.dart';
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
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: locked ? const Color(0xFFF8FAFC) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: !locked && selected
                ? AppTheme.primaryColor
                : const Color(0xFFE2E8F0),
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
                      color: const Color(0xFFCBD5E1),
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
                          ? AppTheme.primaryColor
                          : const Color(0xFFCBD5E1),
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryColor,
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
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        if (locked)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock_outline_rounded,
                                    size: 9,
                                    color: AppTheme.textSecondary),
                                SizedBox(width: 3),
                                Text(
                                  'Não disponível',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textSecondary,
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
                      style: Theme.of(context).textTheme.bodySmall,
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
