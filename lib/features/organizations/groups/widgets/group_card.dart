import 'package:convoquei_app/core/network/exceptions/api_exception.dart';
import 'package:convoquei_app/core/services/toast_feedback_service.dart';
import 'package:convoquei_app/core/services/user_feedback_service.dart';
import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/groups/models/organization_group_model.dart';
import 'package:convoquei_app/features/organizations/groups/models/organization_group_participant_model.dart';
import 'package:convoquei_app/features/organizations/groups/providers/clear_group_participants_provider.dart';
import 'package:convoquei_app/features/organizations/groups/providers/delete_group_participant_provider.dart';
import 'package:convoquei_app/features/organizations/groups/providers/delete_group_provider.dart';
import 'package:convoquei_app/features/organizations/groups/providers/group_participants_paged_provider.dart';
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
    final memberLabel = group.participantCount == 1 ? '1 MEMBRO' : '${group.participantCount} MEMBROS';
    return DSExpandableCard(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: context.colors.surfaceSubtle,
          borderRadius: DSRadius.allMd,
        ),
        alignment: Alignment.center,
        child: Text(group.emoji, style: const TextStyle(fontSize: 24)),
      ),
      title: group.name,
      descriptionWidget: DSBadge(
        label: memberLabel,
        color: context.colors.textSecondary,
        variant: DSBadgeVariant.elevated,
      ),
      onExpand: () => ref.read(groupParticipantsPagedProvider(group.id).notifier).loadNextPage(),
      actions: [
        Expanded(
          child: DSButton(
            label: 'Limpar grupo',
            icon: Icons.cleaning_services_rounded,
            schema: DSButtonSchema.secondary,
            size: DSButtonSize.sm,
            outlined: true,
            onPressed: () => _confirmClear(context, ref),
          ),
        ),
        const SizedBox(width: DSSpacing.sm),
        DSButton(
          label: 'Excluir',
          icon: Icons.delete_outline_rounded,
          schema: DSButtonSchema.danger,
          size: DSButtonSize.sm,
          onPressed: () => _confirmDelete(context, ref),
        ),
      ],
      children: [
        _ParticipantsSection(groupId: group.id, organizationId: organizationId),
      ],
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await UserFeedbackService.confirm(
      context,
      title: 'Limpar grupo',
      message: 'Remover todos os membros de "${group.name}"? Esta ação não pode ser desfeita.',
      confirmLabel: 'Limpar',
      destructive: true,
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(clearGroupParticipantsProvider.notifier).clear(
        organizationId: organizationId, groupId: group.id,
      );
      if (!context.mounted) return;
      ToastFeedbackService.showToast(context, 'Grupo limpo com sucesso!', ToastType.success);
    } on ApiException catch (e) {
      if (!context.mounted) return;
      UserFeedbackService.error(context, message: e.message);
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await UserFeedbackService.confirm(
      context,
      title: 'Excluir grupo',
      message: 'Excluir o grupo "${group.name}"? Esta ação não pode ser desfeita.',
      confirmLabel: 'Excluir',
      destructive: true,
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(deleteGroupProvider.notifier).delete(
        organizationId: organizationId, groupId: group.id,
      );
      if (!context.mounted) return;
      ToastFeedbackService.showToast(context, 'Grupo excluído com sucesso!', ToastType.success);
    } on ApiException catch (e) {
      if (!context.mounted) return;
      UserFeedbackService.error(context, message: e.message);
    }
  }
}

class _ParticipantsSection extends ConsumerWidget {
  const _ParticipantsSection({required this.groupId, required this.organizationId});

  final String groupId;
  final String organizationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(groupParticipantsPagedProvider(groupId));

    if (state.isInitialLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: DSSpacing.lg),
        child: Center(child: DSSpinner(size: 32)),
      );
    }

    if (state.hasError && state.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
        child: DSButton(
          label: 'Tentar novamente',
          schema: DSButtonSchema.ghost,
          size: DSButtonSize.sm,
          fullWidth: false,
          onPressed: () => ref.read(groupParticipantsPagedProvider(groupId).notifier).loadNextPage(),
        ),
      );
    }

    if (state.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
        child: Center(
          child: DSText(
            'Nenhum membro neste grupo',
            variant: DSTextVariant.bodySmall,
            color: context.colors.textSecondary,
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...state.items.map((p) => _ParticipantTile(
              participant: p,
              organizationId: organizationId,
              groupId: groupId,
            )),
        if (state.isLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: DSSpacing.sm),
            child: Center(child: DSSpinner(size: 24)),
          ),
        if (state.hasNextPage && !state.isLoadingMore)
          DSButton(
            label: 'Carregar mais',
            schema: DSButtonSchema.ghost,
            size: DSButtonSize.sm,
            fullWidth: false,
            onPressed: () => ref.read(groupParticipantsPagedProvider(groupId).notifier).loadNextPage(),
          ),
      ],
    );
  }
}

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
      child: Row(
        children: [
          DSAvatar(name: participant.memberName, avatarUrl: participant.memberAvatarUrl, radius: 16),
          const SizedBox(width: DSSpacing.sm + 2),
          Expanded(
            child: DSText(
              participant.memberName,
              variant: DSTextVariant.labelMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          DSIconButton(
            icon: Icons.person_remove_outlined,
            iconColor: context.colors.danger,
            backgroundColor: context.colors.dangerTint,
            size: 32,
            onPressed: () => _confirmRemove(context, ref),
          ),
        ],
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
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(deleteGroupParticipantProvider.notifier).remove(
        organizationId: organizationId,
        groupId: groupId,
        participantId: participant.id,
      );
    } on ApiException catch (e) {
      if (!context.mounted) return;
      UserFeedbackService.error(context, message: e.message);
    }
  }
}
