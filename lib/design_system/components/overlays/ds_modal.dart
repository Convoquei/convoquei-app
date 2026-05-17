// Utilitário para exibir modais responsivos (bottom sheet em mobile, dialog em wide).
// Anteriormente: AppModal + BaseModalStatefulWidget/BaseModalState.
//
// Uso simples (widget avulso):
//   DSModal.show(context, MyModalWidget())
//
// Uso como base class (com layout padrão de drag handle + header + fechar):
//   class MyModal extends BaseModalStatefulWidget { ... }
//   class _MyModalState extends BaseModalState<MyModal> {
//     @override String? get titleText => 'Título';
//     @override List<Widget> buildBody(BuildContext context) => [Text('conteúdo')];
//   }
import 'package:convoquei_app/core/constants/app_breakpoints.dart';
import 'package:flutter/material.dart';

import '../../theme/ds_context_extensions.dart';
import '../../tokens/ds_colors_primitive.dart';
import '../../tokens/ds_spacing.dart';

abstract final class DSModal {
  static Future<T?> show<T>(
    BuildContext context,
    Widget modal, {
    double maxWidth = 520,
  }) {
    if (AppBreakpoints.isWide(context)) {
      return showDialog<T>(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: modal,
          ),
        ),
      );
    }

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => modal,
    );
  }

  static void hide<T>(BuildContext context, [T? result]) =>
      Navigator.of(context).pop(result);
}

// ── Base class para modais com layout padrão ──────────────────────────────────

abstract class DSBaseModal extends StatefulWidget {
  const DSBaseModal({super.key});

  static Future<T?> show<T>(
    BuildContext context,
    DSBaseModal modal, {
    double maxWidth = 520,
  }) =>
      DSModal.show<T>(context, modal, maxWidth: maxWidth);

  static void hide<T>(BuildContext context, [T? result]) =>
      DSModal.hide<T>(context, result);
}

abstract class DSBaseModalState<T extends DSBaseModal> extends State<T> {
  String? get titleText => null;
  Widget? get titleWidget => null;
  bool get showCloseButton => true;
  bool get showDragHandle => true;

  List<Widget> buildBody(BuildContext context);

  @override
  Widget build(BuildContext context) {
    final isDialog = AppBreakpoints.isWide(context);
    final bottomPadding = isDialog ? 0.0 : MediaQuery.viewInsetsOf(context).bottom;
    final colors = context.colors;

    final resolvedTitle = titleWidget ??
        (titleText != null
            ? Text(titleText!, style: Theme.of(context).textTheme.titleLarge)
            : null);

    final hasHeader = resolvedTitle != null || showCloseButton;

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
            if (!isDialog && showDragHandle) ...[
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
            if (hasHeader)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  DSSpacing.xl,
                  DSSpacing.lg,
                  DSSpacing.lg,
                  DSSpacing.lg,
                ),
                child: Row(
                  children: [
                    if (resolvedTitle != null) Expanded(child: resolvedTitle),
                    if (showCloseButton)
                      Container(
                        decoration: BoxDecoration(
                          color: colors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => DSBaseModal.hide(context, false),
                        ),
                      ),
                  ],
                ),
              ),
            ...buildBody(context),
            SizedBox(height: bottomPadding),
          ],
        ),
      ),
    );
  }
}
