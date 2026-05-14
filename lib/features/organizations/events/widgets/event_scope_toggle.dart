import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_call_mode.dart';
import 'package:flutter/material.dart';

class EventScopeToggle extends StatelessWidget {
  final OrganizationEventCallMode callMode;
  final ValueChanged<OrganizationEventCallMode> onChanged;

  const EventScopeToggle({
    super.key,
    required this.callMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.colors.surfaceSubtle,
        borderRadius: DSRadius.all(14),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          _ToggleOption(
            label: 'Todos',
            active: callMode == OrganizationEventCallMode.allOrganizationMembers,
            onTap: () => onChanged(OrganizationEventCallMode.allOrganizationMembers),
          ),
          _ToggleOption(
            label: 'Grupos Específicos',
            active:
                callMode == OrganizationEventCallMode.onlySpecifiedGroupMembers,
            onTap: () =>
                onChanged(OrganizationEventCallMode.onlySpecifiedGroupMembers),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: DSMotion.fast,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? context.colors.surface : Colors.transparent,
            borderRadius: DSRadius.all(11),
            border: Border.all(
              color: active ? context.colors.border : Colors.transparent,
            ),
            boxShadow: active ? DSElevation.sm : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: context.textStyles.bodySmall?.copyWith(
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? context.colors.textPrimary : context.colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
