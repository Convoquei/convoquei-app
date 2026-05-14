import 'package:convoquei_app/core/network/exceptions/api_exception.dart';
import 'package:convoquei_app/core/services/toast_feedback_service.dart';
import 'package:convoquei_app/core/services/user_feedback_service.dart';
import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/tag_label.dart';
import 'package:convoquei_app/core/widgets/user_avatar.dart';
import 'package:convoquei_app/features/organizations/members/models/organization_group_model.dart';
import 'package:convoquei_app/features/organizations/members/models/organization_group_participant_model.dart';
import 'package:convoquei_app/features/organizations/members/providers/clear_group_participants_provider.dart';
import 'package:convoquei_app/features/organizations/members/providers/delete_group_participant_provider.dart';
import 'package:convoquei_app/features/organizations/members/providers/delete_group_provider.dart';
import 'package:convoquei_app/features/organizations/members/providers/group_participants_paged_provider.dart';
import 'package:convoquei_app/design_system/ds.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupCard extends ConsumerWidget {
  const GroupCard({
    super.key,
    required this.group,
    required this.organizationId,
  });

  final OrganizationGroupModel group;
  final String organizationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DSExpandableCard(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.surfaceSubtle,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(group.emoji, style: const TextStyle(fontSize: 24)),
      ),
      title: group.name,
      descriptionWidget: TagLabel(
        label:
            '${group.participantCount} ${group.participantCount == 1 ? 'MEMBRO' : 'MEMBROS'}',
        color: AppTheme.textSecondary,
        variant: TagLabelVariant.elevated,
      ),
      onExpand: () {
        ref
            .read(groupParticipantsPagedProvider(group.id).notifier)
            .loadNextPage();
      },
      actions: [
        _ActionButton(
          label: 'Limpar grupo',
          icon: Icons.cleaning_services_rounded,
          color: AppTheme.secondaryColor,
          onTap: () => _confirmClear(context, ref),
        ),
        const SizedBox(width: 8),
        _IconActionButton(
          icon: Icons.delete_outline_rounded,
          color: AppTheme.errorColor,
          tooltip: 'Excluir grupo',
          onTap: () => _confirmDelete(context, ref),
        ),
      ],
      children: [
        _ParticipantsSection(
          groupId: group.id,
          organizationId: organizationId,
        ),
      ],
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await UserFeedbackService.confirm(
      context,
      title: 'Limpar grupo',
      message:
          'Tem certeza que deseja remover todos os membros de "${group.name}"? Esta ação não pode ser desfeita.',
      confirmLabel: 'Limpar',
      destructive: true,
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
    final confirmed = await UserFeedbackService.confirm(
      context,
      title: 'Excluir grupo',
      message:
          'Tem certeza que deseja excluir o grupo "${group.name}"? Esta ação não pode ser desfeita.',
      confirmLabel: 'Excluir',
      destructive: true,
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

class _ParticipantsSection extends ConsumerWidget {
  const _ParticipantsSection({
    required this.groupId,
    required this.organizationId,
  });

  final String groupId;
  final String organizationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(groupParticipantsPagedProvider(groupId));

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
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Text(
            'Nenhum membro neste grupo',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary.withValues(alpha: 0.7),
            ),
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
  });

  final OrganizationGroupParticipantModel participant;
  final String organizationId;
  final String groupId;

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
                UserAvatar(
                  name: participant.memberName,
                  avatarUrl: participant.memberAvatarUrl,
                  radius: 16,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    participant.memberName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.person_remove_outlined,
                    size: 18,
                    color: AppTheme.errorColor,
                  ),
                  tooltip: 'Remover do grupo',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _confirmRemove(context, ref),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref) async {
    final confirmed = await UserFeedbackService.confirm(
      context,
      title: 'Remover membro',
      message: 'Remover "${participant.memberName}" do grupo?',
      confirmLabel: 'Remover',
      destructive: true,
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
