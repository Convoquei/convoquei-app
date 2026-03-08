import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/modals/multi_select_modal.dart';
import 'package:convoquei_app/features/organizations/members/models/organization_function_model.dart';
import 'package:convoquei_app/features/organizations/members/models/requests/find_all_organization_functions_request.dart';
import 'package:convoquei_app/features/organizations/members/providers/list_all_members_query_provider.dart';
import 'package:convoquei_app/features/organizations/members/providers/update_member_functions_provider.dart';
import 'package:convoquei_app/features/organizations/members/repositories/organization_functions_repository.dart';
import 'package:convoquei_app/core/widgets/header_modal_title_subtitle.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_member_function_model.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_member_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManageFunctionsMemberModal {
  ManageFunctionsMemberModal._();

  static Future<void> show(
    BuildContext context,
    OrganizationMemberModel member,
    String organizationId, {
    VoidCallback? onNavigateToSettings,
  }) {
    return MultiSelectModal.show<OrganizationFunctionModel>(
      context,
      titleWidget: HeaderModalTitleSubtitle(
        title: 'Gerenciar funções',
        subtitle: member.name,
      ),
      title: 'Gerenciar funções',
      subtitle: 'Selecione as funções do membro',
      fetcher: (ref) async {
        final repo = ref.read(organizationFunctionsRepositoryProvider);
        final result = await repo.findAllFunctions(
          organizationId,
          FindAllOrganizationFunctionsRequest(page: 0, size: 100),
        );
        return result.items;
      },
      idExtractor: (fn) => fn.id,
      initialSelectedIds: member.functions.map((f) => f.id).toSet(),
      itemBuilder: (fn, isSelected, onTap) => _FunctionTile(
        function: fn,
        isSelected: isSelected,
        onTap: onTap,
      ),
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
            label: const Text('Configurar funções'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
              textStyle: const TextStyle(fontSize: 13),
            ),
          ),
        ),
      ),
      onSave: (selectedIds) async {
        final container = ProviderScope.containerOf(context);

        await container
            .read(updateMemberFunctionsProvider.notifier)
            .execute(
          organizationId: organizationId,
          memberId: member.id,
          functionIds: selectedIds.toList(),
        );

        final allFunctions = await container
            .read(organizationFunctionsRepositoryProvider)
            .findAllFunctions(
          organizationId,
          FindAllOrganizationFunctionsRequest(page: 0, size: 100),
        );

        final selectedFunctions = allFunctions.items
            .where((f) => selectedIds.contains(f.id))
            .map((f) =>
                OrganizationMemberFunctionModel(id: f.id, name: f.name))
            .toList();

        container
            .read(membersPagedProvider.notifier)
            .updateMemberFunctions(member.id, selectedFunctions);
      },
    );
  }
}

class _FunctionTile extends StatelessWidget {
  const _FunctionTile({
    required this.function,
    required this.isSelected,
    required this.onTap,
  });

  final OrganizationFunctionModel function;
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
                ? AppTheme.primaryColor.withOpacity(0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryColor.withOpacity(0.4)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child:
                    Text(function.emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  function.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
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


