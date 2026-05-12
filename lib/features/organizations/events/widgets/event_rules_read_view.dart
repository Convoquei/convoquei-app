import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_assignment_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_call_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_function_call_mode.dart';
import 'package:convoquei_app/features/organizations/events/models/organization_event_details_model.dart';
import 'package:convoquei_app/features/organizations/events/widgets/assignment_mode_card.dart';
import 'package:convoquei_app/features/organizations/events/widgets/create_event_shared_widgets.dart';
import 'package:flutter/material.dart';

/// View somente-leitura das regras do evento, exibida quando o membro
/// não tem permissão [MANAGE_EVENTS].
class EventRulesReadView extends StatelessWidget {
  final OrganizationEventDetailsModel details;

  const EventRulesReadView({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Regra de aprovação ──────────────────────────────────────────────
        StepCard(
          children: [
            const FieldLabel(label: 'Regra de Aprovação Padrão'),
            AssignmentModeCard(
              mode: OrganizationEventAssignmentMode.manual,
              selected:
                  details.assignmentMode == OrganizationEventAssignmentMode.manual,
              title: 'Aprovação Manual',
              description:
                  'O membro diz que está disponível, mas você decide quem entra e aprova a escala final.',
              icon: Icons.shield_rounded,
              iconColor: AppTheme.primaryColor,
            ),
            AssignmentModeCard(
              mode: OrganizationEventAssignmentMode.automatic,
              selected:
                  details.assignmentMode == OrganizationEventAssignmentMode.automatic,
              title: 'Escala Automática',
              description:
                  'Os membros que aceitarem a convocação serão escalados automaticamente.',
              icon: Icons.rocket_launch_rounded,
              iconColor: AppTheme.successColor,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Escopo de convocação ────────────────────────────────────────────
        StepCard(
          children: [
            const FieldLabel(label: 'Quem foi convocado?'),
            _ScopeDisplay(
              callMode: details.callMode,
              calledGroups: details.calledGroups,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Bloqueio de disponibilidade ─────────────────────────────────────
        StepCard(
          children: [
            Row(
              children: [
                const Icon(Icons.hourglass_top_rounded,
                    color: AppTheme.warningColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bloqueio de Disponibilidade',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            _DeadlineDisplay(
              minutes: details.availabilityLockBeforeStartInMinutes,
            ),
          ],
        ),

        // ── Regras por função ───────────────────────────────────────────────
        if (details.calledFunctions.isNotEmpty) ...[
          const SizedBox(height: 16),
          StepCard(
            children: [
              const FieldLabel(label: 'Regras por Função'),
              if (details.functionCallMode != null)
                _FunctionCallModeInfo(mode: details.functionCallMode!),
              ...details.calledFunctions
                  .map((fn) => _FunctionRuleDisplayCard(function: fn)),
            ],
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _ScopeDisplay extends StatelessWidget {
  final OrganizationEventCallMode callMode;
  final List<OrganizationEventCalledGroupModel> calledGroups;

  const _ScopeDisplay({required this.callMode, required this.calledGroups});

  @override
  Widget build(BuildContext context) {
    if (callMode == OrganizationEventCallMode.allOrganizationMembers) {
      return _InfoChip(
        icon: Icons.groups_rounded,
        label: 'Toda a organização',
        color: AppTheme.primaryColor,
      );
    }
    if (calledGroups.isEmpty) {
      return Text('Nenhum grupo especificado.',
          style: Theme.of(context).textTheme.bodySmall);
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 3.2,
      ),
      itemCount: calledGroups.length,
      itemBuilder: (_, i) {
        final g = calledGroups[i];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Text(g.icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  g.name,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DeadlineDisplay extends StatelessWidget {
  final int minutes;

  const _DeadlineDisplay({required this.minutes});

  String get _formatted {
    if (minutes == 0) return 'Sem bloqueio configurado';
    final days = minutes ~/ (24 * 60);
    final hours = (minutes % (24 * 60)) ~/ 60;
    final mins = minutes % 60;
    final parts = <String>[];
    if (days > 0) parts.add('$days ${days == 1 ? 'dia' : 'dias'}');
    if (hours > 0) parts.add('$hours ${hours == 1 ? 'hora' : 'horas'}');
    if (mins > 0) parts.add('$mins min');
    return 'Bloqueia ${parts.join(', ')} antes do evento';
  }

  @override
  Widget build(BuildContext context) {
    return _InfoChip(
      icon: Icons.access_time_rounded,
      label: _formatted,
      color: AppTheme.warningColor,
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.labelMedium),
          ),
        ],
      ),
    );
  }
}

class _FunctionCallModeInfo extends StatelessWidget {
  final OrganizationEventFunctionCallMode mode;

  const _FunctionCallModeInfo({required this.mode});

  @override
  Widget build(BuildContext context) {
    final label =
        mode == OrganizationEventFunctionCallMode.onlyMembersWithListedFunctions
            ? 'Apenas as funções abaixo serão convocadas para o evento.'
            : 'Todos os convocados participam, com limites aplicados por função.';
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}

class _FunctionRuleDisplayCard extends StatelessWidget {
  final OrganizationEventCalledFunctionDetailsModel function;

  const _FunctionRuleDisplayCard({required this.function});

  @override
  Widget build(BuildContext context) {
    final maxLabel =
        function.maxMembers == null ? '∞' : '${function.maxMembers}';
    final modeLabel =
        function.assignmentMode == OrganizationEventAssignmentMode.manual
            ? 'Manual'
            : 'Automático';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              children: [
                Text(function.icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(function.functionName,
                      style: Theme.of(context).textTheme.titleSmall),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    modeLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: const Color(0xFFF8FAFC),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                    child: _MinMaxLabel(
                        label: 'Mínimo',
                        value: '${function.minMembers}')),
                const SizedBox(width: 12),
                Expanded(
                    child:
                        _MinMaxLabel(label: 'Máximo', value: maxLabel)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MinMaxLabel extends StatelessWidget {
  final String label;
  final String value;

  const _MinMaxLabel({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall),
        Text(value, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}
