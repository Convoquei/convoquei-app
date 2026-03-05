import 'package:convoquei_app/core/services/toast_feedback_service.dart';
import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/action_button.dart';
import 'package:convoquei_app/core/widgets/base_modal_stateful_widget.dart';
import 'package:convoquei_app/features/organizations/members/models/organization_group_model.dart';
import 'package:convoquei_app/features/organizations/members/models/requests/find_all_organization_groups_request.dart';
import 'package:convoquei_app/features/organizations/members/providers/update_member_groups_provider.dart';
import 'package:convoquei_app/features/organizations/members/repositories/organization_groups_repository.dart';
import 'package:convoquei_app/features/organizations/members/widgets/create_group_modal.dart';
import 'package:convoquei_app/features/organizations/members/widgets/header_member_modal.dart';
import 'package:convoquei_app/features/organizations/members/widgets/no_groups_empty_state.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_member_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider isolado para listar grupos dentro do modal — não compartilha estado
/// com o [groupsPagedProvider] usado na aba de grupos.
final _modalGroupsProvider = FutureProvider.autoDispose
    .family<List<OrganizationGroupModel>, String>((ref, organizationId) async {
  final repo = ref.read(organizationGroupsRepositoryProvider);
  final result = await repo.findAllGroups(
    organizationId,
    FindAllOrganizationGroupsRequest(page: 0, size: 100),
  );
  return result.items;
});

class ManageGroupsMemberModal extends BaseModalStatefulWidget {
  final OrganizationMemberModel member;
  final String organizationId;

  const ManageGroupsMemberModal({super.key, required this.member, required this.organizationId});

  static Future<void> show(
      BuildContext context,
      OrganizationMemberModel member,
      String organizationId,
      ) => BaseModalStatefulWidget.show(
    context,
    ManageGroupsMemberModal(member: member, organizationId: organizationId),
  );

  @override
  State<StatefulWidget> createState() => _ManageGroupsMemberModalState();
}

class _ManageGroupsMemberModalState
    extends BaseModalState<ManageGroupsMemberModal> {
  final Set<String> _selectedGroupIds = {};
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _selectedGroupIds.addAll(widget.member.groups.map((g) => g.id));
  }

  @override
  Widget? get titleWidget => HeaderMemberModal(
    title: "Gerenciar grupos",
    userName: widget.member.name,
  );

  void _toggleGroup(String groupId) {
    setState(() {
      if (_selectedGroupIds.contains(groupId)) {
        _selectedGroupIds.remove(groupId);
      } else {
        _selectedGroupIds.add(groupId);
      }
      _isDirty = true;
    });
  }

  Future<void> _save(WidgetRef ref) async {
    try {
      await ref.read(updateMemberGroupsProvider.notifier).execute(
        organizationId: widget.organizationId,
        memberId: widget.member.id,
        groupIds: _selectedGroupIds.toList(),
      );

      if (!mounted) return;

      ToastFeedbackService.showToast(
        context,
        'Grupos atualizados com sucesso!',
        ToastType.success,
      );

      BaseModalStatefulWidget.hide(context, true);
    } catch (e) {
      if (!mounted) return;
      ToastFeedbackService.showToast(
        context,
        'Erro ao atualizar grupos.',
        ToastType.error,
      );
    }
  }

  @override
  List<Widget> buildBody(BuildContext context) {
    final theme = Theme.of(context);

    return [
      Flexible(
        child: Consumer(
          builder: (context, ref, _) {
            final asyncGroups =
                ref.watch(_modalGroupsProvider(widget.organizationId));

            return asyncGroups.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: CupertinoActivityIndicator(),
                ),
              ),
              error: (_, __) => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Text(
                    "Erro ao carregar grupos",
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.red),
                  ),
                ),
              ),
              data: (groups) {
                if (groups.isEmpty) {
                  return SingleChildScrollView(
                    child: NoGroupsEmptyState(
                      onCreateGroup: () async {
                        final created = await CreateGroupModal.show(
                          context,
                          widget.organizationId,
                        );
                        if (created == true) {
                          ref.invalidate(
                            _modalGroupsProvider(widget.organizationId),
                          );
                        }
                      },
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12, top: 8),
                        child: Text(
                          "Selecione os grupos do membro",
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF94A3B8),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      ...groups.map(
                        (group) => _GroupTile(
                          group: group,
                          isSelected: _selectedGroupIds.contains(group.id),
                          onTap: () => _toggleGroup(group.id),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),

      const Divider(height: 1),

      // FOOTER
      Consumer(
        builder: (context, ref, _) {
          final isLoading = ref.watch(updateMemberGroupsProvider).isLoading;
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: ActionButton(
              label: 'Salvar alterações',
              onPressed: _isDirty && !isLoading ? () => _save(ref) : null,
              isLoading: isLoading,
            ),
          );
        },
      ),
    ];
  }
}

class _GroupTile extends StatelessWidget {
  final OrganizationGroupModel group;
  final bool isSelected;
  final VoidCallback onTap;

  const _GroupTile({
    required this.group,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              // Emoji / ícone do grupo
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  group.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 14),
              // Nome
              Expanded(
                child: Text(
                  group.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              // Checkbox
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