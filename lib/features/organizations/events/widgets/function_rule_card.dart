import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_assignment_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/event_form_step3_data.dart';
import 'package:flutter/material.dart';

class FunctionRuleCard extends StatelessWidget {
  final FunctionRuleData rule;
  final bool canUseAutoSchedule;
  final ValueChanged<FunctionRuleData> onChanged;
  final VoidCallback onRemove;

  const FunctionRuleCard({
    super.key,
    required this.rule,
    required this.canUseAutoSchedule,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final maxLabel = rule.max == null ? '∞' : '${rule.max}';

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: DSRadius.allLg,
        border: Border.all(color: context.colors.border),
        boxShadow: DSElevation.sm,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Header da função ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            child: Row(
              children: [
                Text(rule.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(rule.name,
                      style: context.textStyles.titleSmall),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: Icon(Icons.delete_outline_rounded,
                      color: context.colors.danger, size: 20),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: context.colors.surfaceSubtle),

          // ── Mín / Máx ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: _MinMaxControl(
                    label: 'Mínimo necessário',
                    value: rule.min,
                    displayValue: '${rule.min}',
                    onDecrement: rule.min > 0
                        ? () => onChanged(rule.copyWith(min: rule.min - 1))
                        : null,
                    onIncrement: () =>
                        onChanged(rule.copyWith(min: rule.min + 1)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MinMaxControl(
                    label: 'Máximo permitido',
                    value: rule.max ?? 0,
                    displayValue: maxLabel,
                    onDecrement: rule.max != null && rule.max! > 0
                        ? () => onChanged(rule.max == 1
                            ? rule.copyWith(clearMax: true)
                            : rule.copyWith(max: rule.max! - 1))
                        : null,
                    onIncrement: () => onChanged(
                      rule.max == null
                          ? rule.copyWith(max: 1)
                          : rule.copyWith(max: rule.max! + 1),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Modo de escalação da função ─────────────────────────────────────
          Container(
            color: context.colors.surfaceSubtle,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ESCALAÇÃO DESTA FUNÇÃO',
                  style: context.textStyles.labelSmall?.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                _FunctionAssignmentOption(
                  selected: rule.assignmentMode ==
                      OrganizationEventAssignmentMode.manual,
                  icon: Icons.shield_rounded,
                  iconColor: context.colors.primary,
                  title: 'Aprovação manual',
                  description:
                      'O líder decide quem entra nesta função, mesmo que o evento use escala automática para os demais.',
                  onTap: () => onChanged(rule.copyWith(
                      assignmentMode: OrganizationEventAssignmentMode.manual)),
                ),
                const SizedBox(height: 6),
                _FunctionAssignmentOption(
                  selected: rule.assignmentMode ==
                      OrganizationEventAssignmentMode.automatic,
                  locked: !canUseAutoSchedule,
                  icon: Icons.rocket_launch_rounded,
                  iconColor: context.colors.success,
                  title: 'Escala automática',
                  description: rule.max != null
                      ? 'No fecho da escala, os primeiros ${rule.max} disponíveis desta função serão escalados automaticamente.'
                      : 'No fecho da escala, todos os disponíveis desta função serão escalados automaticamente.',
                  onTap: () => onChanged(rule.copyWith(
                      assignmentMode:
                          OrganizationEventAssignmentMode.automatic)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRIVATE HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _FunctionAssignmentOption extends StatelessWidget {
  final bool selected;
  final bool locked;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _FunctionAssignmentOption({
    required this.selected,
    this.locked = false,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: locked ? null : onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: locked ? 0.55 : 1.0,
        child: AnimatedContainer(
          duration: DSMotion.fast,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: !locked && selected ? context.colors.surface : Colors.transparent,
            borderRadius: DSRadius.allMd,
            border: Border.all(
              color: !locked && selected
                  ? context.colors.primary
                  : context.colors.border,
              width: !locked && selected ? 1.5 : 1,
            ),
            boxShadow: !locked && selected ? DSElevation.sm : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 18,
                height: 18,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: !locked && selected
                        ? context.colors.primary
                        : context.colors.border,
                    width: 2,
                  ),
                ),
                child: !locked && selected
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
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: 14, color: iconColor),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            title,
                            style: context.textStyles.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: !locked && selected
                                  ? context.colors.textPrimary
                                  : context.colors.textSecondary,
                            ),
                          ),
                        ),
                        if (locked)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: context.colors.border,
                              borderRadius: DSRadius.all(5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock_outline_rounded,
                                    size: 9, color: context.colors.textSecondary),
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
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: context.textStyles.bodySmall?.copyWith(
                        fontSize: 10,
                        height: 1.4,
                        color: context.colors.textSecondary,
                      ),
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

class _MinMaxControl extends StatelessWidget {
  final String label;
  final int value;
  final String displayValue;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;

  const _MinMaxControl({
    required this.label,
    required this.value,
    required this.displayValue,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: context.textStyles.labelSmall?.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: context.colors.textSecondary,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: context.colors.surfaceSubtle,
            borderRadius: DSRadius.allMd,
            border: Border.all(color: context.colors.border),
          ),
          child: Row(
            children: [
              _CounterBtn(icon: Icons.remove_rounded, onTap: onDecrement),
              Expanded(
                child: Text(
                  displayValue,
                  textAlign: TextAlign.center,
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
              _CounterBtn(icon: Icons.add_rounded, onTap: onIncrement),
            ],
          ),
        ),
      ],
    );
  }
}

class _CounterBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CounterBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: onTap != null ? context.colors.surface : context.colors.surfaceSubtle,
          borderRadius: DSRadius.all(9),
          boxShadow: onTap != null ? DSElevation.sm : null,
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap != null
              ? context.colors.textSecondary
              : context.colors.border,
        ),
      ),
    );
  }
}
