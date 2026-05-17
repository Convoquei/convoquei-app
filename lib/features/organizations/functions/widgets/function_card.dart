import 'package:convoquei_app/core/network/exceptions/api_exception.dart';
import 'package:convoquei_app/core/services/toast_feedback_service.dart';
import 'package:convoquei_app/core/services/user_feedback_service.dart';
import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/functions/models/organization_function_member_model.dart';
import 'package:convoquei_app/features/organizations/functions/models/organization_function_model.dart';
import 'package:convoquei_app/features/organizations/functions/providers/clear_function_members_provider.dart';
import 'package:convoquei_app/features/organizations/functions/providers/delete_function_member_provider.dart';
import 'package:convoquei_app/features/organizations/functions/providers/delete_function_provider.dart';
import 'package:convoquei_app/features/organizations/functions/providers/function_members_paged_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FunctionCard extends ConsumerWidget {
  const FunctionCard({
    super.key,
    required this.function,
    required this.organizationId,
  });

  final OrganizationFunctionModel function;
  final String organizationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberLabel = function.memberCount == 1 ? '1 MEMBRO' : '${function.memberCount} MEMBROS';
    return DSExpandableCard(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: context.colors.surfaceSubtle,
          borderRadius: DSRadius.allMd,
        ),
        alignment: Alignment.center,
        child: Text(function.emoji, style: const TextStyle(fontSize: 24)),
      ),
      title: function.name,
      descriptionWidget: DSBadge(
        label: memberLabel,
        color: context.colors.textSecondary,
        variant: DSBadgeVariant.elevated,
      ),
      actions: [
        Expanded(
          child: DSButton(
            label: 'Limpar função',
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
          fullWidth: false,
          onPressed: () => _confirmDelete(context, ref),
        ),
      ],
      children: [
        _MembersSection(functionId: function.id, organizationId: organizationId),
      ],
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await UserFeedbackService.confirm(
      context,
      title: 'Limpar função',
      message: 'Remover todos os membros de "${function.name}"? Esta ação não pode ser desfeita.',
      confirmLabel: 'Limpar',
      destructive: true,
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(clearFunctionMembersProvider.notifier).clear(
        organizationId: organizationId, functionId: function.id,
      );
      if (!context.mounted) return;
      ToastFeedbackService.showToast(context, 'Função limpa com sucesso!', ToastType.success);
    } on ApiException catch (e) {
      if (!context.mounted) return;
      UserFeedbackService.error(context, message: e.message);
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await UserFeedbackService.confirm(
      context,
      title: 'Excluir função',
      message: 'Excluir a função "${function.name}"? Esta ação não pode ser desfeita.',
      confirmLabel: 'Excluir',
      destructive: true,
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(deleteFunctionProvider.notifier).delete(
        organizationId: organizationId, functionId: function.id,
      );
      if (!context.mounted) return;
      ToastFeedbackService.showToast(context, 'Função excluída com sucesso!', ToastType.success);
    } on ApiException catch (e) {
      if (!context.mounted) return;
      UserFeedbackService.error(context, message: e.message);
    }
  }
}

class _MembersSection extends ConsumerWidget {
  const _MembersSection({required this.functionId, required this.organizationId});

  final String functionId;
  final String organizationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(functionMembersProvider(functionId)).when(
      loading: () => const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MemberTileSkeleton(nameWidth: 140),
          _MemberTileSkeleton(nameWidth: 100),
          _MemberTileSkeleton(nameWidth: 120),
        ],
      ),
      error: (_, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
        child: DSButton(
          label: 'Tentar novamente',
          schema: DSButtonSchema.ghost,
          size: DSButtonSize.sm,
          fullWidth: false,
          onPressed: () => ref.invalidate(functionMembersProvider(functionId)),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
            child: Center(
              child: DSText(
                'Nenhum membro nesta função',
                variant: DSTextVariant.bodySmall,
                color: context.colors.textSecondary,
              ),
            ),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: items
              .map((m) => _MemberTile(
                    member: m,
                    organizationId: organizationId,
                    functionId: functionId,
                  ))
              .toList(),
        );
      },
    );
  }
}

class _MemberTile extends ConsumerWidget {
  const _MemberTile({
    required this.member,
    required this.organizationId,
    required this.functionId,
  });

  final OrganizationFunctionMemberModel member;
  final String organizationId;
  final String functionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          DSAvatar(name: member.memberName, avatarUrl: member.memberAvatarUrl, radius: 16),
          const SizedBox(width: DSSpacing.sm + 2),
          Expanded(
            child: DSText(
              member.memberName,
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
      message: 'Remover "${member.memberName}" da função?',
      confirmLabel: 'Remover',
      destructive: true,
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(deleteFunctionMemberProvider.notifier).remove(
        organizationId: organizationId,
        functionId: functionId,
        memberId: member.id,
      );
    } on ApiException catch (e) {
      if (!context.mounted) return;
      UserFeedbackService.error(context, message: e.message);
    }
  }
}

class _MemberTileSkeleton extends StatelessWidget {
  const _MemberTileSkeleton({this.nameWidth = 120});

  final double nameWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          const DSSkeleton(width: 32, height: 32, borderRadius: 16),
          const SizedBox(width: DSSpacing.sm + 2),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: DSSkeleton(width: nameWidth, height: 13, borderRadius: 6),
            ),
          ),
          const SizedBox(width: DSSpacing.sm),
          const DSSkeleton(width: 32, height: 32, borderRadius: 16),
        ],
      ),
    );
  }
}
