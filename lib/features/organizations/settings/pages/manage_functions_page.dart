import 'package:convoquei_app/core/network/exceptions/api_exception.dart';
import 'package:convoquei_app/core/services/toast_feedback_service.dart';
import 'package:convoquei_app/core/services/user_feedback_service.dart';
import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/app_loading_info.dart';
import 'package:convoquei_app/core/widgets/app_loading_screen.dart';
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
import 'package:convoquei_app/core/models/state_list_paged.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Cores de ação destrutiva/atenção ────────────────────────────────────────
const _kDangerColor = Color(0xFFEF4444);
const _kWarningColor = Color(0xFFF97316);
const _kSurfaceColor = Color(0xFFF1F5F9);

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(functionsPagedProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(functionsPagedProvider);

    // Loading inicial — cobre o frame em que page==0, items vazios e sem erro
    if (state.isInitialLoading ||
        (state.page == 0 && state.items.isEmpty && state.error == null)) {
      return const AppLoadingScreen(
        content: AppLoadingInfo(
          label: 'Carregando funções...',
          description: 'Buscando funções da organização',
        ),
        skeleton: AppLoadingSkeleton.list,
      );
    }

    final emptyState = state.items.isEmpty
        ? _NoFunctionsEmptyState(onCreateFunction: _handleCreateFunction)
        : null;

    return BaseScrollablePage(
      useSafeArea: true,
      searchHint: 'Procurar funções...',
      onRequestNextPage: state.hasNextPage ? _handleRequestNextPage : null,
      icon: Icons.add,
      emptyState: emptyState,
      onIconTap: _handleCreateFunction,
      children: [
        Column(
          spacing: 8,
          children: state.items
              .map(
                (fn) => _FunctionExpandedCard(
                  key: ValueKey(fn.id),
                  function: fn,
                  organizationId: widget.organization.id,
                ),
              )
              .toList(),
        ),
        if (state.isLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
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
    return ExpandedCard(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _kSurfaceColor,
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
          color: _kWarningColor,
          onTap: () => _confirmClear(context, ref),
        ),
        const SizedBox(width: 8),
        _IconActionButton(
          icon: Icons.delete_outline_rounded,
          color: _kDangerColor,
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
// Seção de membros — widget separado para isolar o watch do provider Family

class _MembersSection extends ConsumerWidget {
  const _MembersSection({
    required this.functionId,
    required this.organizationId,
  });

  final String functionId;
  final String organizationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(functionMembersPagedProvider(functionId));

    if (state.isInitialLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
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

    return _MembersList(
      functionId: functionId,
      organizationId: organizationId,
      state: state,
    );
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
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
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
                    color: _kDangerColor,
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
              color: _kSurfaceColor,
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
