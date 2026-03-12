import 'package:convoquei_app/core/theme/app_theme.dart';
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
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: active ? const Color(0xFFE2E8F0) : Colors.transparent,
            ),
            boxShadow: active
                ? const [BoxShadow(color: Color(0x0A000000), blurRadius: 4)]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
