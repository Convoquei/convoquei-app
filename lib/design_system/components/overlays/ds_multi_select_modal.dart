// Modal de seleção múltipla genérico com busca e callback de save.
// Anteriormente: MultiSelectModal.
//
// Exemplo:
//   DSMultiSelectModal.show<GroupModel>(
//     context,
//     title: 'Selecionar grupos',
//     fetcher: (ref) => ref.read(groupsProvider.future),
//     idExtractor: (g) => g.id,
//     itemBuilder: (g, selected, onTap) => DSSelectableTile(...),
//     onSave: (ids) async => await ref.read(saveGroupsProvider.notifier).run(ids),
//   )
import 'package:convoquei_app/core/services/toast_feedback_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:convoquei_app/core/constants/app_breakpoints.dart';

import '../../theme/ds_context_extensions.dart';
import '../../tokens/ds_colors_primitive.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';
import '../buttons/ds_button.dart';
import 'ds_modal.dart';

class DSMultiSelectModal<T> extends ConsumerStatefulWidget {
  const DSMultiSelectModal({
    super.key,
    required this.title,
    required this.fetcher,
    required this.idExtractor,
    required this.itemBuilder,
    required this.onSave,
    this.titleWidget,
    this.subtitle,
    this.initialSelectedIds = const {},
    this.saveLabel = 'Salvar alterações',
    this.emptyWidget,
    this.settingsWidget,
    this.errorMessage = 'Erro ao carregar itens.',
    this.saveErrorMessage = 'Erro ao salvar alterações.',
    this.saveSuccessMessage = 'Alterações salvas com sucesso!',
  });

  final String title;
  final Widget? titleWidget;
  final String? subtitle;

  final Future<List<T>> Function(WidgetRef ref) fetcher;
  final String Function(T item) idExtractor;
  final Widget Function(T item, bool isSelected, VoidCallback onTap) itemBuilder;
  final Set<String> initialSelectedIds;
  final Future<void> Function(Set<String> selectedIds) onSave;
  final String saveLabel;
  final Widget? emptyWidget;
  final Widget? settingsWidget;
  final String errorMessage;
  final String saveErrorMessage;
  final String saveSuccessMessage;

  static Future<bool?> show<T>(
    BuildContext context, {
    required String title,
    required Future<List<T>> Function(WidgetRef ref) fetcher,
    required String Function(T item) idExtractor,
    required Widget Function(T item, bool isSelected, VoidCallback onTap) itemBuilder,
    required Future<void> Function(Set<String> selectedIds) onSave,
    Widget? titleWidget,
    String? subtitle,
    Set<String> initialSelectedIds = const {},
    String saveLabel = 'Salvar alterações',
    Widget? emptyWidget,
    Widget? settingsWidget,
    String errorMessage = 'Erro ao carregar itens.',
    String saveErrorMessage = 'Erro ao salvar alterações.',
    String saveSuccessMessage = 'Alterações salvas com sucesso!',
  }) {
    return DSModal.show<bool>(
      context,
      DSMultiSelectModal<T>(
        title: title,
        titleWidget: titleWidget,
        subtitle: subtitle,
        fetcher: fetcher,
        idExtractor: idExtractor,
        itemBuilder: itemBuilder,
        initialSelectedIds: initialSelectedIds,
        onSave: onSave,
        saveLabel: saveLabel,
        emptyWidget: emptyWidget,
        settingsWidget: settingsWidget,
        errorMessage: errorMessage,
        saveErrorMessage: saveErrorMessage,
        saveSuccessMessage: saveSuccessMessage,
      ),
    );
  }

  @override
  ConsumerState<DSMultiSelectModal<T>> createState() =>
      _DSMultiSelectModalState<T>();
}

class _DSMultiSelectModalState<T>
    extends ConsumerState<DSMultiSelectModal<T>> {
  late Set<String> _selectedIds;
  Future<List<T>>? _future;
  bool _hasError = false;
  bool _isDirty = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedIds = {...widget.initialSelectedIds};
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadData();
    });
  }

  void _loadData() {
    final future = widget.fetcher(ref);
    future.then((_) {
      if (mounted) setState(() => _hasError = false);
    }).catchError((_) {
      if (mounted) setState(() => _hasError = true);
    });
    setState(() {
      _hasError = false;
      _future = future;
    });
  }

  void _toggle(String id) {
    setState(() {
      final updated = {..._selectedIds};
      updated.contains(id) ? updated.remove(id) : updated.add(id);
      _selectedIds = updated;
      _isDirty = true;
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await widget.onSave(_selectedIds);
      if (!mounted) return;
      ToastFeedbackService.showToast(context, widget.saveSuccessMessage, ToastType.success);
      DSModal.hide(context, true);
    } catch (_) {
      if (!mounted) return;
      ToastFeedbackService.showToast(context, widget.saveErrorMessage, ToastType.error);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDialog = AppBreakpoints.isWide(context);
    final bottomPadding = isDialog ? 0.0 : MediaQuery.viewInsetsOf(context).bottom;
    final colors = context.colors;

    final resolvedTitle = widget.titleWidget ??
        Text(
          widget.title,
          style: TextStyle(
            fontFamily: DSTypography.displayFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        );

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: isDialog
            ? BorderRadius.circular(32)
            : const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isDialog) ...[
              const SizedBox(height: DSSpacing.md),
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: DSColorsPrimitive.slate200,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ] else
              const SizedBox(height: DSSpacing.sm),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DSSpacing.xl,
                DSSpacing.lg,
                DSSpacing.lg,
                DSSpacing.lg,
              ),
              child: Row(
                children: [
                  Expanded(child: resolvedTitle),
                  Container(
                    decoration: BoxDecoration(
                      color: colors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => DSModal.hide(context, false),
                    ),
                  ),
                ],
              ),
            ),
            FutureBuilder<List<T>>(
              future: _future,
              builder: (context, snapshot) {
                if (_future == null ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: DSSpacing.xl),
                    child: Center(child: CupertinoActivityIndicator(radius: 10)),
                  );
                }
                if (snapshot.hasError) return _ErrorBody(onRetry: _loadData);

                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return SingleChildScrollView(
                    child: widget.emptyWidget ??
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: Center(child: Text('Nenhum item disponível.')),
                        ),
                  );
                }

                return Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      DSSpacing.xl,
                      DSSpacing.sm,
                      DSSpacing.xl,
                      DSSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: DSSpacing.md,
                              top: DSSpacing.sm,
                            ),
                            child: Text(
                              widget.subtitle!.toUpperCase(),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: const Color(0xFF94A3B8),
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                            ),
                          ),
                        ...items.map((item) {
                          final id = widget.idExtractor(item);
                          return widget.itemBuilder(
                            item,
                            _selectedIds.contains(id),
                            () => _toggle(id),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
            if (!_hasError && widget.settingsWidget != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  DSSpacing.xl,
                  DSSpacing.md,
                  DSSpacing.xl,
                  0,
                ),
                child: widget.settingsWidget!,
              ),
            if (!_hasError) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  DSSpacing.xl,
                  DSSpacing.lg,
                  DSSpacing.xl,
                  DSSpacing.xl,
                ),
                child: DSButton(
                  label: widget.saveLabel,
                  onPressed: _isDirty && !_isSaving ? _save : null,
                  isLoading: _isSaving,
                ),
              ),
            ],
            SizedBox(height: bottomPadding),
          ],
        ),
      ),
    );
  }
}

// ── Estado de erro interno ────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xxl, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colors.dangerTint,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(Icons.wifi_off_rounded, size: 32, color: colors.danger),
          ),
          const SizedBox(height: DSSpacing.xl),
          Text(
            'Algo deu errado',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DSSpacing.sm),
          Text(
            'Infelizmente não conseguimos carregar as informações. Verifique sua conexão e tente novamente.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          DSButton(
            label: 'Tentar novamente',
            icon: Icons.refresh_rounded,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
