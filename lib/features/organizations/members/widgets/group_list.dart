import 'package:convoquei_app/core/models/state_list_paged.dart';
import 'package:convoquei_app/core/services/toast_feedback_service.dart';
import 'package:convoquei_app/core/services/user_feedback_service.dart';
import 'package:convoquei_app/core/network/exceptions/api_exception.dart';
import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/features/organizations/members/models/organization_group_model.dart';
import 'package:convoquei_app/features/organizations/members/models/organization_group_participant_model.dart';
import 'package:convoquei_app/features/organizations/members/providers/clear_group_participants_provider.dart';
import 'package:convoquei_app/features/organizations/members/providers/delete_group_participant_provider.dart';
import 'package:convoquei_app/features/organizations/members/providers/delete_group_provider.dart';
import 'package:convoquei_app/features/organizations/members/providers/group_participants_paged_provider.dart';
import 'package:convoquei_app/features/organizations/members/providers/list_all_groups_query_provider.dart';
import 'package:convoquei_app/features/organizations/members/widgets/modals/create_group_modal.dart';
import 'package:convoquei_app/features/organizations/members/widgets/no_groups_empty_state.dart';
import 'package:convoquei_app/features/organizations/shared/widgets/expanded_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupsList extends ConsumerStatefulWidget {
  const GroupsList({
    super.key,
    required this.organizationId,
    required this.canManageGroups,
  });

  final String organizationId;
  final bool canManageGroups;

  @override
  ConsumerState<GroupsList> createState() => _GroupsListState();
}

class _GroupsListState extends ConsumerState<GroupsList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(
      () => ref.read(groupsPagedProvider.notifier).loadNextPage(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final nearBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;
    if (!nearBottom) return;

    final s = ref.read(groupsPagedProvider);
    if (s.isLoadingMore || s.isInitialLoading || !s.hasNextPage) return;

    ref.read(groupsPagedProvider.notifier).loadNextPage();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(groupsPagedProvider);

    if (state.isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Erro ao carregar grupos'),
            TextButton(
              onPressed: () =>
                  ref.read(groupsPagedProvider.notifier).loadNextPage(),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (state.items.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: NoGroupsEmptyState(
            onCreateGroup: widget.canManageGroups
                ? () => CreateGroupModal.show(context, widget.organizationId)
                : null,
          ),
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      itemCount: state.items.length + (state.hasNextPage ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index == state.items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final group = state.items[index];
        return _GroupExpandedCard(
          group: group,
          organizationId: widget.organizationId,
          canManageGroups: widget.canManageGroups,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------

class _GroupExpandedCard extends ConsumerWidget {
  const _GroupExpandedCard({
    required this.group,
    required this.organizationId,
    required this.canManageGroups,
  });

  final OrganizationGroupModel group;
  final String organizationId;
  final bool canManageGroups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participantsState = ref.watch(
      groupParticipantsPagedProvider(group.id),
    );

    return ExpandedCard(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(group.emoji, style: const TextStyle(fontSize: 24)),
      ),
      title: group.name,
      description: _participantLabel(group.participantCount),
      onExpand: () {
        ref
            .read(groupParticipantsPagedProvider(group.id).notifier)
            .loadNextPage();
      },
      actions: canManageGroups
          ? [
              _ActionButton(
                label: 'Limpar grupo',
                icon: Icons.cleaning_services_rounded,
                color: const Color(0xFFF97316),
                onTap: () => _confirmClear(context, ref),
              ),
              const SizedBox(width: 8),
              _IconActionButton(
                icon: Icons.delete_outline_rounded,
                color: const Color(0xFFEF4444),
                tooltip: 'Excluir grupo',
                onTap: () => _confirmDelete(context, ref),
              ),
            ]
          : [],
      children: [
        _ParticipantsList(
          groupId: group.id,
          organizationId: organizationId,
          state: participantsState,
          canManageGroups: canManageGroups,
        ),
      ],
    );
  }

  String _participantLabel(int count) {
    if (count == 1) return '1 membro vinculado';
    return '$count membros vinculados';
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Limpar grupo',
        message:
            'Tem certeza que deseja remover todos os membros de "${group.name}"? Esta ação não pode ser desfeita.',
        confirmLabel: 'Limpar',
        confirmColor: const Color(0xFFF97316),
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    try {
      await ref
          .read(clearGroupParticipantsProvider.notifier)
          .clear(organizationId: organizationId, groupId: group.id);

      if (!context.mounted) return;
      ToastFeedbackService.showToast(
        context,
        'Grupo "${group.name}" limpo com sucesso!',
        ToastType.success,
      );
    } catch (e) {
      if (!context.mounted) return;
      if (e is ApiException) {
        UserFeedbackService.error(context, message: e.message);
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Excluir grupo',
        message:
            'Tem certeza que deseja excluir o grupo "${group.name}"? Esta ação não pode ser desfeita.',
        confirmLabel: 'Excluir',
        confirmColor: const Color(0xFFEF4444),
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    try {
      await ref
          .read(deleteGroupProvider.notifier)
          .delete(organizationId: organizationId, groupId: group.id);

      if (!context.mounted) return;
      ToastFeedbackService.showToast(
        context,
        'Grupo "${group.name}" excluído com sucesso!',
        ToastType.success,
      );
    } catch (e) {
      if (!context.mounted) return;
      if (e is ApiException) {
        UserFeedbackService.error(context, message: e.message);
      }
    }
  }
}

// ---------------------------------------------------------------------------

class _ParticipantsList extends ConsumerWidget {
  const _ParticipantsList({
    required this.groupId,
    required this.organizationId,
    required this.state,
    required this.canManageGroups,
  });

  final String groupId;
  final String organizationId;
  final StateListPaged<OrganizationGroupParticipantModel> state;
  final bool canManageGroups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isInitialLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null && state.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: TextButton(
            onPressed: () => ref
                .read(groupParticipantsPagedProvider(groupId).notifier)
                .loadNextPage(),
            child: const Text('Erro ao carregar. Tentar novamente'),
          ),
        ),
      );
    }

    if (state.items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Text(
            'Nenhum membro neste grupo',
            style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...state.items.map(
          (p) => _ParticipantTile(
            participant: p,
            organizationId: organizationId,
            groupId: groupId,
            canManageGroups: canManageGroups,
          ),
        ),
        if (state.isLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (state.hasNextPage && !state.isLoadingMore)
          TextButton(
            onPressed: () => ref
                .read(groupParticipantsPagedProvider(groupId).notifier)
                .loadNextPage(),
            child: const Text('Carregar mais'),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _ParticipantTile extends ConsumerWidget {
  const _ParticipantTile({
    required this.participant,
    required this.organizationId,
    required this.groupId,
    required this.canManageGroups,
  });

  final OrganizationGroupParticipantModel participant;
  final String organizationId;
  final String groupId;
  final bool canManageGroups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                _Avatar(
                  name: participant.memberName,
                  avatarUrl: participant.memberAvatarUrl,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    participant.memberName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (canManageGroups)
                  IconButton(
                    icon: const Icon(
                      Icons.person_remove_outlined,
                      size: 18,
                      color: Color(0xFFEF4444),
                    ),
                    tooltip: 'Remover do grupo',
                    visualDensity: VisualDensity.compact,
                    onPressed: () =>
                        _confirmRemove(context, ref),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Remover membro',
        message:
            'Remover "${participant.memberName}" do grupo?',
        confirmLabel: 'Remover',
        confirmColor: const Color(0xFFEF4444),
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    try {
      await ref.read(deleteGroupParticipantProvider.notifier).remove(
            organizationId: organizationId,
            groupId: groupId,
            participantId: participant.id,
          );
    } catch (e) {
      if (!context.mounted) return;
      if (e is ApiException) {
        UserFeedbackService.error(context, message: e.message);
      }
    }
  }
}

// ---------------------------------------------------------------------------

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.avatarUrl});

  final String name;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = avatarUrl.isNotEmpty;
    return CircleAvatar(
      radius: 16,
      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.12),
      child: hasPhoto
          ? ClipOval(
              child: Image.network(
                avatarUrl,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _initials,
              ),
            )
          : _initials,
    );
  }

  Widget get _initials => Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
        ),
      );
}

// ---------------------------------------------------------------------------

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.confirmColor,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
      content: Text(
        message,
        style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            confirmLabel,
            style: TextStyle(
              color: confirmColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
