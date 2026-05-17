import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_assignment_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_call_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_status.dart';
import 'package:convoquei_app/features/organizations/events/models/organization_event_details_model.dart';
import 'package:flutter/material.dart';

class EventDetailRulesView extends StatelessWidget {
  const EventDetailRulesView({super.key, required this.details});

  final OrganizationEventDetailsModel details;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ExplanatoryCard(),
        const SizedBox(height: 24),
        _ApprovalRuleSection(details: details),
        const SizedBox(height: 24),
        _CallModeSection(details: details),
        if (details.calledFunctions.isNotEmpty) ...[
          const SizedBox(height: 24),
          _FunctionRulesSection(details: details),
        ],
      ],
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: context.textStyles.labelSmall.copyWith(
          color: context.colors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─── Icon container ───────────────────────────────────────────────────────────

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.color, required this.tint});

  final IconData icon;
  final Color color;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: DSRadius.allMd,
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}

// ─── 1. Explanatory card ──────────────────────────────────────────────────────

class _ExplanatoryCard extends StatelessWidget {
  const _ExplanatoryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.infoTint,
        borderRadius: DSRadius.all(24),
        border: Border.all(color: context.colors.info.withValues(alpha: 0.2)),
        boxShadow: DSElevation.sm,
      ),
      padding: const EdgeInsets.all(DSSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: context.colors.primary,
              ),
              const SizedBox(width: DSSpacing.sm),
              Text(
                'Como funciona a Escala?'.toUpperCase(),
                style: context.textStyles.labelSmall.copyWith(
                  color: context.colors.primary,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          Text.rich(
            TextSpan(
              text:
                  'Abaixo você visualiza a regra padrão do evento e as suas exceções por função. No Convoquei, ',
              style: context.textStyles.bodySmall.copyWith(
                color: context.colors.textSecondary,
                height: 1.6,
              ),
              children: [
                TextSpan(
                  text: 'a regra da função sempre sobrescreve',
                  style: context.textStyles.bodySmall.copyWith(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    height: 1.6,
                  ),
                ),
                TextSpan(
                  text:
                      ' a regra padrão do evento para garantir flexibilidade máxima.',
                  style: context.textStyles.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 2. Approval rule section ─────────────────────────────────────────────────

class _ApprovalRuleSection extends StatelessWidget {
  const _ApprovalRuleSection({required this.details});
  final OrganizationEventDetailsModel details;

  @override
  Widget build(BuildContext context) {
    final isManual =
        details.assignmentMode == OrganizationEventAssignmentMode.manual;

    final name = isManual ? 'Aprovação Manual' : 'Aprovação Automática';
    final subtitle = isManual
        ? 'O gestor aprova cada candidato individualmente.'
        : 'Membros são escalados assim que confirmam disponibilidade.';
    final iconData = isManual
        ? Icons.verified_user_rounded
        : Icons.auto_awesome_rounded;
    final iconColor = isManual
        ? context.colors.warning
        : context.colors.success;
    final iconTint = isManual
        ? context.colors.warningTint
        : context.colors.successTint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Regra de Aprovação Padrão'),
        DSCard(
          padding: const EdgeInsets.all(DSSpacing.xl),
          child: Row(
            children: [
              _IconBox(icon: iconData, color: iconColor, tint: iconTint),
              const SizedBox(width: DSSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DSText(name, variant: DSTextVariant.labelMedium),
                    const SizedBox(height: 2),
                    DSText(
                      subtitle,
                      variant: DSTextVariant.bodySmall,
                      color: context.colors.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              DSBadge(
                label: 'Ativa',
                color: iconColor,
                variant: DSBadgeVariant.soft,
                size: DSBadgeSize.sm,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── 3. Call mode section ─────────────────────────────────────────────────────

class _CallModeSection extends StatelessWidget {
  const _CallModeSection({required this.details});
  final OrganizationEventDetailsModel details;

  @override
  Widget build(BuildContext context) {
    final isSpecific =
        details.callMode == OrganizationEventCallMode.onlySpecifiedGroupMembers;

    final title = isSpecific
        ? 'Apenas Grupos Específicos'
        : 'Todos os Membros da Organização';
    final subtitle = isSpecific
        ? 'Convocação limitada aos grupos abaixo:'
        : 'Qualquer membro da organização pode ser convocado.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Quem será convocado?'),
        DSCard(
          padding: const EdgeInsets.all(DSSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _IconBox(
                    icon: isSpecific
                        ? Icons.group_rounded
                        : Icons.groups_rounded,
                    color: context.colors.primary,
                    tint: context.colors.primaryTint,
                  ),
                  const SizedBox(width: DSSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DSText(title, variant: DSTextVariant.labelMedium),
                        const SizedBox(height: 2),
                        DSText(
                          subtitle,
                          variant: DSTextVariant.bodySmall,
                          color: context.colors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isSpecific && details.calledGroups.isNotEmpty) ...[
                const SizedBox(height: DSSpacing.md),
                const DSDivider(),
                const SizedBox(height: DSSpacing.md),
                Wrap(
                  spacing: DSSpacing.sm,
                  runSpacing: DSSpacing.sm,
                  children: details.calledGroups
                      .map(
                        (g) => DSBadge(
                          label: '${g.icon} ${g.name}',
                          color: context.colors.primary,
                          variant: DSBadgeVariant.soft,
                          size: DSBadgeSize.sm,
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─── 4. Function rules section ────────────────────────────────────────────────

class _FunctionRulesSection extends StatelessWidget {
  const _FunctionRulesSection({required this.details});
  final OrganizationEventDetailsModel details;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Regras e Vagas por Função'),
        ...details.calledFunctions.asMap().entries.map((entry) {
          final fn = entry.value;
          final idx = entry.key;
          final assignedToFn = details.participants
              .where(
                (p) =>
                    p.function == fn.functionName &&
                    p.status == OrganizationEventMembershipStatus.assigned,
              )
              .toList();
          final overrides = fn.assignmentMode != details.assignmentMode;

          return Padding(
            padding: EdgeInsets.only(top: idx == 0 ? 0 : 12),
            child: _FunctionCard(
              fn: fn,
              assignedParticipants: assignedToFn,
              overrides: overrides,
            ),
          );
        }),
      ],
    );
  }
}

class _FunctionCard extends StatelessWidget {
  const _FunctionCard({
    required this.fn,
    required this.assignedParticipants,
    required this.overrides,
  });

  final OrganizationEventCalledFunctionDetailsModel fn;
  final List<OrganizationEventParticipantModel> assignedParticipants;
  final bool overrides;

  bool get _isManual =>
      fn.assignmentMode == OrganizationEventAssignmentMode.manual;

  String get _modeName =>
      _isManual ? 'Aprovação Manual' : 'Aprovação Automática';

  String get _modeDesc => _isManual
      ? 'O gestor aprova ou rejeita cada candidato desta função individualmente.'
      : 'Membros são escalados automaticamente ao confirmar disponibilidade nesta função.';

  String get _vacancyLabel {
    final min = fn.minMembers;
    final max = fn.maxMembers;
    if (max == null) return 'mín. $min';
    if (min == max) return '$min vaga${min == 1 ? '' : 's'}';
    return '$min–$max vagas';
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _isManual
        ? context.colors.warning
        : context.colors.success;
    final iconTint = _isManual
        ? context.colors.warningTint
        : context.colors.successTint;
    final iconData = _isManual
        ? Icons.verified_user_rounded
        : Icons.auto_awesome_rounded;
    final overrideColor = overrides
        ? context.colors.info
        : context.colors.textSecondary;
    final overrideLabel = overrides ? 'Sobrescreve' : 'Padrão';

    return DSCard(
      padding: const EdgeInsets.all(DSSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ────────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconTint,
                  borderRadius: DSRadius.allMd,
                  border: Border.all(color: iconColor.withValues(alpha: 0.15)),
                ),
                child: Center(
                  child: Text(fn.icon, style: context.textStyles.titleLarge),
                ),
              ),
              const SizedBox(width: DSSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DSText(
                      fn.functionName,
                      variant: DSTextVariant.labelMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(iconData, size: 11, color: iconColor),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${_modeName.toUpperCase()} · $_vacancyLabel',
                            style: context.textStyles.labelSmall.copyWith(
                              color: iconColor,
                              letterSpacing: 0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              DSBadge(
                label: overrideLabel,
                color: overrideColor,
                variant: DSBadgeVariant.soft,
                size: DSBadgeSize.sm,
              ),
            ],
          ),

          // ── Description ───────────────────────────────────────────────────
          const SizedBox(height: DSSpacing.md),
          Text.rich(
            TextSpan(
              text: 'Como funciona: ',
              style: context.textStyles.bodySmall.copyWith(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w600,
                height: 1.6,
              ),
              children: [
                TextSpan(
                  text: _modeDesc,
                  style: context.textStyles.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),

          // ── Footer: facepile ──────────────────────────────────────────────
          if (assignedParticipants.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            Divider(height: 1, color: context.colors.border),
            const SizedBox(height: DSSpacing.md),
            Row(
              children: [
                Text(
                  'Membros escalados',
                  style: context.textStyles.labelSmall.copyWith(
                    color: context.colors.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: DSSpacing.sm),
                DSFacepile(
                  items: assignedParticipants
                      .map((p) => (name: p.name, avatarUrl: p.avatarUrl))
                      .toList(),
                  max: 4,
                  size: 26,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
