import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/modals/multi_select_modal.dart';
import 'package:convoquei_app/core/widgets/header_modal_title_subtitle.dart';
import 'package:convoquei_app/features/organizations/members/providers/update_member_roles_provider.dart';
import 'package:convoquei_app/features/organizations/settings/providers/list_roles_organization_provider.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_member_model.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_role_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManageRolesMemberModal {
  ManageRolesMemberModal._();

  static Future<void> show(
    BuildContext context,
    OrganizationMemberModel member,
    String organizationId, {
    VoidCallback? onNavigateToSettings,
  }) {
    return MultiSelectModal.show<OrganizationRoleModel>(
      context,
      titleWidget: HeaderModalTitleSubtitle(
        title: 'Gerenciar papéis',
        subtitle: member.name,
      ),
      title: 'Gerenciar papéis',
      subtitle: 'Selecione os papéis do membro',
      fetcher: (ref) async {
        final notifier = ref.read(listRolesOrganizationProvider.notifier);
        await notifier.loadFirstPage(organizationId);

        var current = ref.read(listRolesOrganizationProvider).value;
        while (current?.hasNextPage == true) {
          await notifier.loadNextPage(organizationId);
          current = ref.read(listRolesOrganizationProvider).value;
        }

        return ref.read(listRolesOrganizationProvider).value?.items ?? [];
      },
      idExtractor: (role) => role.id,
      initialSelectedIds: const {},
      settingsWidget: Builder(
        builder: (ctx) => Center(
          child: TextButton.icon(
            onPressed: onNavigateToSettings == null
                ? null
                : () {
                    Navigator.of(ctx).pop();
                    onNavigateToSettings();
                  },
            icon: const Icon(Icons.settings_outlined, size: 14),
            label: const Text('Configurar papéis'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
              textStyle: const TextStyle(fontSize: 13),
            ),
          ),
        ),
      ),
      itemBuilder: (role, isSelected, onTap) => _RoleTile(
        role: role,
        isSelected: isSelected,
        onTap: onTap,
      ),
      onSave: (selectedIds) async {
        final container = ProviderScope.containerOf(context);

        await container.read(updateMemberRolesProvider.notifier).execute(
              organizationId: organizationId,
              memberId: member.id,
              newRoleIds: selectedIds,
            );
      },
    );
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  final OrganizationRoleModel role;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withValues(alpha: 0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryColor.withValues(alpha: 0.4)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withValues(alpha: 0.1)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.verified_user_rounded,
                  size: 22,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                    ),
                    if (role.permissionCount > 0)
                      Text(
                        '${role.permissionCount} permissão(ões)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF94A3B8),
                            ),
                      ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : const Color(0xFFCBD5E1),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
