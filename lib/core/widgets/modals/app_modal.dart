import 'package:convoquei_app/core/constants/app_breakpoints.dart';
import 'package:flutter/material.dart';

class AppModal {
  AppModal._();

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
