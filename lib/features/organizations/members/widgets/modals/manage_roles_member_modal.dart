import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/members/providers/update_member_roles_provider.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_member_model.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_role_model.dart';
import 'package:convoquei_app/features/organizations/shared/repositories/organization_role_repository.dart';
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
    return DSMultiSelectModal.show<OrganizationRoleModel>(
      context,
      title: 'Gerenciar papéis',
      titleWidget: DSModalHeader(title: 'Gerenciar papéis', subtitle: member.name),
      fetcher: (ref) async {
        final paged = await ref
            .read(organizationRoleRepositoryProvider)
            .getOrganizationRoles(organizationId: organizationId, page: 0, pageSize: 100);
        return paged.items;
      },
      idExtractor: (role) => role.id,
      initialSelectedIds: const {},
      itemBuilder: (role, isSelected, onTap) => DSSelectableTile(
        title: role.name,
        description: role.permissionCount > 0
            ? '${role.permissionCount} permissão(ões)'
            : null,
        isSelected: isSelected,
        onTap: onTap,
      ),
      settingsWidget: onNavigateToSettings != null
          ? Builder(
              builder: (ctx) => Center(
                child: DSButton(
                  label: 'Configurar papéis',
                  schema: DSButtonSchema.ghost,
                  size: DSButtonSize.sm,
                  icon: Icons.settings_outlined,
                  fullWidth: false,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    onNavigateToSettings();
                  },
                ),
              ),
            )
          : null,
      onSave: (selectedIds) async {
        final container = ProviderScope.containerOf(context);
        await container.read(updateMemberRolesProvider.notifier).execute(
          organizationId: organizationId,
          memberId: member.id,
          newRoleIds: selectedIds,
        );
      },
      saveLabel: 'Atribuir papéis',
    );
  }
}
