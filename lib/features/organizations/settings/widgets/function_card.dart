import 'package:convoquei_app/core/network/exceptions/api_exception.dart';
import 'package:convoquei_app/core/services/toast_feedback_service.dart';
import 'package:convoquei_app/core/services/user_feedback_service.dart';
import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/tag_label.dart';
import 'package:convoquei_app/core/widgets/user_avatar.dart';
import 'package:convoquei_app/features/organizations/members/models/organization_function_member_model.dart';
import 'package:convoquei_app/features/organizations/members/models/organization_function_model.dart';
import 'package:convoquei_app/features/organizations/members/providers/clear_function_members_provider.dart';
import 'package:convoquei_app/features/organizations/members/providers/delete_function_member_provider.dart';
import 'package:convoquei_app/features/organizations/members/providers/delete_function_provider.dart';
import 'package:convoquei_app/features/organizations/members/providers/function_members_paged_provider.dart';
import 'package:convoquei_app/features/organizations/settings/widgets/function_card_skeleton.dart';
import 'package:convoquei_app/design_system/ds.dart';
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
    return DSExpandableCard(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.surfaceSubtle,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(function.emoji, style: const TextStyle(fontSize: 24)),
      ),
      title: function.name,
      descriptionWidget: TagLabel(
        label:
            '${function.memberCount} ${function.memberCount == 1 ? 'MEMBRO' : 'MEMBROS'}',
        color: AppTheme.textSecondary,
        variant: TagLabelVariant.elevated,
      ),
      actions: [
        _ActionButton(
          label: 'Limpar função',
          icon: Icons.cleaning_services_rounded,
          color: AppTheme.secondaryColor,
          onTap: () => _confirmClear(context, ref),
        ),
        const SizedBox(width: 8),
        _IconActionButton(
          icon: Icons.delete_outline_rounded,
          color: AppTheme.errorColor,
          tooltip: 'Excluir função',
          onTap: () => _confirmDelete(context, ref),
        ),
      ],
      children: [
        _MembersSection(
          functionId: function.id,
          organizationId: organizationId,
        ),
      ],
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await UserFeedbackService.confirm(
      context,
      title: 'Limpar função',
      message:
          'Tem certeza que deseja remover todos os membros de "${function.name}"? Esta ação não pode ser desfeita.',
      confirmLabel: 'Limpar',
      destructive: true,
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    try {
      await ref
          .read(clearFunctionMembersProvider.notifier)
          .clear(organizationId: organizationId, functionId: function.id);

      if (!context.mounted) return;
      ToastFeedbackService.showToast(
        context,
        'Função "${function.name}" limpa com sucesso!',
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
      title: 'Excluir função',
      message:
          'Tem certeza que deseja excluir a função "${function.name}"? Esta ação não pode ser desfeita.',
      confirmLabel: 'Excluir',
      destructive: true,
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    try {
      await ref
          .read(deleteFunctionProvider.notifier)
          .delete(organizationId: organizationId, functionId: function.id);

      if (!context.mounted) return;
      ToastFeedbackService.showToast(
        context,
        'Função "${function.name}" excluída com sucesso!',
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

class _MembersSection extends ConsumerWidget {
  const _MembersSection({
    required this.functionId,
    required this.organizationId,
  });

  final String functionId;
  final String organizationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(functionMembersProvider(functionId));

    return async.when(
      loading: () => const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MemberTileSkeleton(nameWidth: 140),
          _MemberTileSkeleton(nameWidth: 100),
          _MemberTileSkeleton(nameWidth: 120),
        ],
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: TextButton(
            onPressed: () => ref.invalidate(functionMembersProvider(functionId)),
            child: const Text('Erro ao carregar. Tentar novamente'),
          ),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Text(
                'Nenhum membro nesta função',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary.withValues(alpha: 0.7),
                ),
              ),
            ),
          );
        }
        return _MembersList(
          functionId: functionId,
          organizationId: organizationId,
          items: items,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------

class _MembersList extends StatelessWidget {
  const _MembersList({
    required this.functionId,
    required this.organizationId,
    required this.items,
  });

  final String functionId;
  final String organizationId;
  final List<OrganizationFunctionMemberModel> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: items
          .map(
            (m) => _MemberTile(
              member: m,
              organizationId: organizationId,
              functionId: functionId,
            ),
          )
          .toList(),
    );
  }
}

// ---------------------------------------------------------------------------

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
                  name: member.memberName,
                  avatarUrl: member.memberAvatarUrl,
                  radius: 16,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    member.memberName,
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
                  tooltip: 'Remover da função',
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
      message: 'Remover "${member.memberName}" da função?',
      confirmLabel: 'Remover',
      destructive: true,
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    try {
      await ref
          .read(deleteFunctionMemberProvider.notifier)
          .remove(
            organizationId: organizationId,
            functionId: functionId,
            memberId: member.id,
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

class _MemberTileSkeleton extends StatelessWidget {
  const _MemberTileSkeleton({this.nameWidth = 120});

  final double nameWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            const ShimmerBox(width: 32, height: 32, borderRadius: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: ShimmerBox(
                  width: nameWidth,
                  height: 13,
                  borderRadius: 6,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const ShimmerBox(width: 18, height: 18, borderRadius: 4),
          ],
        ),
      ),
    );
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
