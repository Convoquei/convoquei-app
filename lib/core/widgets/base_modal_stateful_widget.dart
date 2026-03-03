import 'package:convoquei_app/core/constants/app_breakpoints.dart';
import 'package:flutter/material.dart';

/// Widget base para modais responsivos.
///
/// Em telas wide abre um [Dialog] centralizado.
/// Em telas menores abre um [ModalBottomSheet].
///
/// Uso:
/// ```dart
/// class MyModal extends BaseModalStatefulWidget {
///   const MyModal({super.key});
///
///   static Future<bool?> show(BuildContext context) =>
///       BaseModalStatefulWidget.showModal<bool>(context, const MyModal());
///
///   @override
///   State<MyModal> createState() => _MyModalState();
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