import 'package:convoquei_app/core/models/state_list_paged.dart';
import 'package:convoquei_app/core/network/exceptions/api_exception.dart';
import 'package:convoquei_app/core/services/toast_feedback_service.dart';
import 'package:convoquei_app/core/services/user_feedback_service.dart';
import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/base_scrollable_page.dart';
import 'package:convoquei_app/core/widgets/tag_label.dart';
import 'package:convoquei_app/features/organizations/members/models/organization_function_member_model.dart';
import 'package:convoquei_app/features/organizations/members/models/organization_function_model.dart';
import 'package:convoquei_app/features/organizations/members/providers/clear_function_members_provider.dart';
import 'package:convoquei_app/features/organizations/members/providers/delete_function_member_provider.dart';
import 'package:convoquei_app/features/organizations/members/providers/delete_function_provider.dart';
import 'package:convoquei_app/features/organizations/members/providers/function_members_paged_provider.dart';
import 'package:convoquei_app/features/organizations/members/providers/list_all_functions_query_provider.dart';
import 'package:convoquei_app/features/organizations/members/widgets/modals/create_function_modal.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_model.dart';
import 'package:convoquei_app/features/organizations/shared/widgets/expanded_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManageFunctionsPage extends ConsumerStatefulWidget {
  final OrganizationModel organization;

  const ManageFunctionsPage({super.key, required this.organization});

  @override
  ConsumerState<ManageFunctionsPage> createState() =>
      _ManageFunctionsPageState();
}

class _ManageFunctionsPageState extends ConsumerState<ManageFunctionsPage> {
  Future<void> _handleRequestNextPage() async {
    await ref.read(functionsPagedProvider.notifier).loadNextPage();
  }

  Future<void> _handleCreateFunction() async {
    if (!mounted) return;
    await CreateFunctionModal.show(context, widget.organization.id);
  }

  Future<void> _handleDeleteFunction(OrganizationFunctionModel fn) async {
    final confirmed = await UserFeedbackService.confirm(
      context,
      title: 'Excluir função',
      message:
          'Tem certeza que deseja excluir a função "${fn.name}"? Esta ação não pode ser desfeita.',
      confirmLabel: 'Excluir',
      destructive: true,
    );

    if (!confirmed || !mounted) return;

    try {
      await ref.read(deleteFunctionProvider.notifier).delete(
            organizationId: widget.organization.id,
            functionId: fn.id,
          );
    } catch (_) {
      if (!mounted) return;
      await UserFeedbackService.error(
        context,
        message: 'Não foi possível excluir a função. Tente novamente.',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(functionsPagedProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final functionsState = ref.watch(functionsPagedProvider);
    final hasNextPage = functionsState.hasNextPage;

    final emptyState = functionsState.items.isEmpty &&
            !functionsState.isInitialLoading &&
            !functionsState.isLoadingMore
        ? _NoFunctionsEmptyState(onCreateFunction: _handleCreateFunction)
        : null;

    return BaseScrollablePage(
      useSafeArea: true,
      searchHint: 'Procurar funções...',
      onRequestNextPage: hasNextPage ? _handleRequestNextPage : null,
      icon: Icons.add,
      emptyState: emptyState,
      onIconTap: _handleCreateFunction,
      children: [
        if (functionsState.isInitialLoading)
          const Center(child: CircularProgressIndicator())
        else
          Column(
            spacing: 8,
            children: functionsState.items
                .map(
                  (fn) => _FunctionExpandedCard(
                    key: ValueKey(fn.id),
                    function: fn,
                    organizationId: widget.organization.id,
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _FunctionExpandedCard extends ConsumerWidget {
  const _FunctionExpandedCard({
    super.key,
    required this.function,
    required this.organizationId,
  });

  final OrganizationFunctionModel function;
  final String organizationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersState = ref.watch(functionMembersPagedProvider(function.id));

    return ExpandedCard(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
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
      onExpand: () {
        ref
            .read(functionMembersPagedProvider(function.id).notifier)
            .loadNextPage();
      },
      actions: [
        _ActionButton(
          label: 'Limpar função',
          icon: Icons.cleaning_services_rounded,
          color: const Color(0xFFF97316),
          onTap: () => _confirmClear(context, ref),
        ),
        const SizedBox(width: 8),
        _IconActionButton(
          icon: Icons.delete_outline_rounded,
          color: const Color(0xFFEF4444),
          tooltip: 'Excluir função',
          onTap: () => _confirmDelete(context, ref),
        ),
      ],
      children: [
        _MembersList(
          functionId: function.id,
          organizationId: organizationId,
          state: membersState,
        ),
      ],
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Limpar função',
        message:
            'Tem certeza que deseja remover todos os membros de "${function.name}"? Esta ação não pode ser desfeita.',
        confirmLabel: 'Limpar',
        confirmColor: const Color(0xFFF97316),
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    try {
      await ref.read(clearFunctionMembersProvider.notifier).clear(
            organizationId: organizationId,
            functionId: function.id,
          );

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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Excluir função',
        message:
            'Tem certeza que deseja excluir a função "${function.name}"? Esta ação não pode ser desfeita.',
        confirmLabel: 'Excluir',
        confirmColor: const Color(0xFFEF4444),
      ),
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

class _MembersList extends ConsumerWidget {
  const _MembersList({
    required this.functionId,
    required this.organizationId,
    required this.state,
  });

  final String functionId;
  final String organizationId;
  final StateListPaged<OrganizationFunctionMemberModel> state;

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
                .read(functionMembersPagedProvider(functionId).notifier)
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
            'Nenhum membro nesta função',
            style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...state.items.map(
          (m) => _MemberTile(
            member: m,
            organizationId: organizationId,
            functionId: functionId,
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
                .read(functionMembersPagedProvider(functionId).notifier)
                .loadNextPage(),
            child: const Text('Carregar mais'),
          ),
      ],
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
                _Avatar(
                  name: member.memberName,
                  avatarUrl: member.memberAvatarUrl,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    member.memberName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.person_remove_outlined,
                    size: 18,
                    color: Color(0xFFEF4444),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Remover membro',
        message: 'Remover "${member.memberName}" da função?',
        confirmLabel: 'Remover',
        confirmColor: const Color(0xFFEF4444),
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    try {
      await ref.read(deleteFunctionMemberProvider.notifier).remove(
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
                errorBuilder: (_, __, ___) => _initials,
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

// ---------------------------------------------------------------------------

class _NoFunctionsEmptyState extends StatelessWidget {
  const _NoFunctionsEmptyState({this.onCreateFunction});

  final VoidCallback? onCreateFunction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: const Text('🎵', style: TextStyle(fontSize: 36)),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma função criada ainda',
            style: theme.textTheme.titleSmall?.copyWith(
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Funções ajudam a identificar a atividade de cada membro dentro da organização.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          if (onCreateFunction != null) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onCreateFunction,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Criar primeira função'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
