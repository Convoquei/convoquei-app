import 'package:convoquei_app/core/constants/app_breakpoints.dart';
import 'package:flutter/material.dart';

/// Widget base para modais responsivos.
///
/// Em telas wide abre um [Dialog] centralizado.
/// Em telas menores abre um [ModalBottomSheet].
///
/// Prefira estender [BaseModalState] no State para ganhar o layout padrão
/// (drag handle, cabeçalho com título e botão fechar) automaticamente.
///
/// Uso:
/// ```dart
/// class MyModal extends BaseModalStatefulWidget {
///   const MyModal({super.key});
///
///   static Future<bool?> show(BuildContext context) =>
///       BaseModalStatefulWidget.show<bool>(context, const MyModal());
///
///   @override
///   State<MyModal> createState() => _MyModalState();
/// }
///
/// class _MyModalState extends BaseModalState<MyModal> {
///   @override
///   String? get titleText => 'Título';
///
///   @override
///   Widget buildBody(BuildContext context) => const Placeholder();
/// }
/// ```
abstract class BaseModalStatefulWidget extends StatefulWidget {
  const BaseModalStatefulWidget({super.key});

  static Future<T?> show<T>(
      BuildContext context,
      BaseModalStatefulWidget modal, {
        double maxWidth = 520,
      }) {
    if (AppBreakpoints.isWide(context)) {
      return showDialog<T>(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 24,
          ),
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

/// State base que fornece o layout padrão de modal:
/// fundo branco, bordas arredondadas, drag handle (bottom sheet),
/// cabeçalho com título e botão fechar.
///
/// Sobrescreva:
/// - [titleText] para um título simples em `String`.
/// - [titleWidget] para um widget totalmente customizado no lugar do título
///   (tem prioridade sobre [titleText]).
/// - [showCloseButton] para ocultar o botão ×.
/// - [buildBody] para o conteúdo abaixo do cabeçalho.
abstract class BaseModalState<T extends BaseModalStatefulWidget>
    extends State<T> {
  /// Título simples. Ignorado se [titleWidget] for sobrescrito.
  String? get titleText => null;

  /// Widget customizado no lugar do título.
  /// Tem prioridade sobre [titleText].
  Widget? get titleWidget => null;

  /// Exibe o botão × no canto direito do cabeçalho. Padrão: `true`.
  bool get showCloseButton => true;

  /// Conteúdo principal do modal, renderizado abaixo do cabeçalho.
  ///
  /// Retorna uma lista para que os filhos sejam inseridos diretamente no
  /// [Column] externo — necessário para que [Flexible] funcione corretamente
  /// com conteúdo rolável sem precisar de colunas aninhadas.
  List<Widget> buildBody(BuildContext context);

  @override
  Widget build(BuildContext context) {
    final isDialog = AppBreakpoints.isWide(context);
    final bottomPadding =
        isDialog ? 0.0 : MediaQuery.viewInsetsOf(context).bottom;
    final theme = Theme.of(context);

    final resolvedTitle = titleWidget ??
        (titleText != null
            ? Text(titleText!, style: theme.textTheme.titleLarge)
            : null);

    final hasHeader = resolvedTitle != null || showCloseButton;

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
            if (hasHeader)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
                child: Row(
                  children: [
                    if (resolvedTitle != null) Expanded(child: resolvedTitle),
                    if (showCloseButton)
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () =>
                              BaseModalStatefulWidget.hide(context, false),
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