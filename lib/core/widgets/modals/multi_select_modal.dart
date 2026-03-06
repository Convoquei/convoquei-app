import 'package:convoquei_app/core/widgets/modals/app_modal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:convoquei_app/core/constants/app_breakpoints.dart';
import 'package:convoquei_app/core/services/toast_feedback_service.dart';
import 'package:convoquei_app/core/widgets/action_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MultiSelectModal<T> extends ConsumerStatefulWidget {
  const MultiSelectModal({
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
    this.errorMessage = 'Erro ao carregar itens.',
    this.saveErrorMessage = 'Erro ao salvar alterações.',
    this.saveSuccessMessage = 'Alterações salvas com sucesso!',
  });

  final String title;
  final Widget? titleWidget;
  final String? subtitle;

  /// Busca os itens — chamado uma única vez no [initState] com [ref] estável.
  final Future<List<T>> Function(WidgetRef ref) fetcher;

  /// Extrai o id único de cada item.
  final String Function(T item) idExtractor;

  /// Constrói cada item da lista.
  final Widget Function(T item, bool isSelected, VoidCallback onTap) itemBuilder;

  final Set<String> initialSelectedIds;

  /// Chamado ao confirmar com os ids selecionados.
  final Future<void> Function(Set<String> selectedIds) onSave;

  final String saveLabel;
  final Widget? emptyWidget;
  final String errorMessage;
  final String saveErrorMessage;
  final String saveSuccessMessage;

  // ─── show ──────────────────────────────────────────────────────────────────

  static Future<bool?> show<T>(
      BuildContext context, {
        required String title,
        required Future<List<T>> Function(WidgetRef ref) fetcher,
        required String Function(T item) idExtractor,
        required Widget Function(T item, bool isSelected, VoidCallback onTap)
        itemBuilder,
        required Future<void> Function(Set<String> selectedIds) onSave,
        Widget? titleWidget,
        String? subtitle,
        Set<String> initialSelectedIds = const {},
        String saveLabel = 'Salvar alterações',
        Widget? emptyWidget,
        String errorMessage = 'Erro ao carregar itens.',
        String saveErrorMessage = 'Erro ao salvar alterações.',
        String saveSuccessMessage = 'Alterações salvas com sucesso!',
      }) {
    return AppModal.show<bool>(
      context,
      MultiSelectModal<T>(
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
        errorMessage: errorMessage,
        saveErrorMessage: saveErrorMessage,
        saveSuccessMessage: saveSuccessMessage,
      ),
    );
  }

  @override
  ConsumerState<MultiSelectModal<T>> createState() =>
      _MultiSelectModalState<T>();
}

class _MultiSelectModalState<T> extends ConsumerState<MultiSelectModal<T>> {
  late final Set<String> _selectedIds;
  late final Future<List<T>> _future;
  bool _isDirty = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedIds = {...widget.initialSelectedIds};
    // ref estável em ConsumerState — future criada uma única vez.
    _future = widget.fetcher(ref);
  }

  void _toggle(String id) {
    setState(() {
      _selectedIds.contains(id)
          ? _selectedIds.remove(id)
          : _selectedIds.add(id);
      _isDirty = true;
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await widget.onSave(_selectedIds);
      if (!mounted) return;
      ToastFeedbackService.showToast(
        context,
        widget.saveSuccessMessage,
        ToastType.success,
      );
      AppModal.hide(context, true);
    } catch (error) {
      debugPrint('Error saving MultiSelectModal: $error');

      if (!mounted) return;
      ToastFeedbackService.showToast(
        context,
        widget.saveErrorMessage,
        ToastType.error,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDialog = AppBreakpoints.isWide(context);
    final bottomPadding =
    isDialog ? 0.0 : MediaQuery.viewInsetsOf(context).bottom;

    final resolvedTitle = widget.titleWidget ??
        Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
            // Drag handle — só no bottom sheet
            if (!isDialog) ...[
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ] else
              const SizedBox(height: 8),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
              child: Row(
                children: [
                  Expanded(child: resolvedTitle),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => AppModal.hide(context, false),
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Flexible(
              child: FutureBuilder<List<T>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: CupertinoActivityIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Text(
                          widget.errorMessage,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.red),
                        ),
                      ),
                    );
                  }

                  final items = snapshot.data ?? [];

                  if (items.isEmpty) {
                    return SingleChildScrollView(
                      child: widget.emptyWidget ??
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 48),
                            child: Center(
                              child: Text('Nenhum item disponível.'),
                            ),
                          ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12, top: 8),
                            child: Text(
                              widget.subtitle!.toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                color: const Color(0xFF94A3B8),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ...items.map((item) {
                          final id = widget.idExtractor(item);
                          final isSelected = _selectedIds.contains(id);
                          return widget.itemBuilder(
                            item,
                            isSelected,
                                () => _toggle(id),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 1),

            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: ActionButton(
                label: widget.saveLabel,
                onPressed: _isDirty && !_isSaving ? _save : null,
                isLoading: _isSaving,
              ),
            ),

            SizedBox(height: bottomPadding),
          ],
        ),
      ),
    );
  }
}




















