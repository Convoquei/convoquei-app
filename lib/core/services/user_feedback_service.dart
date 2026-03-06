import 'package:flutter/material.dart';

enum _FeedbackType { error, success, warning, info }

class UserFeedbackService {
  UserFeedbackService._();

  // ── Public API ────────────────────────────────────────────────────────────

  static Future<void> error(
    BuildContext context, {
    required String message,
    String title = 'Erro',
    String buttonLabel = 'Fechar',
  }) =>
      _show(
        context,
        type: _FeedbackType.error,
        title: title,
        message: message,
        buttonLabel: buttonLabel,
      );

  static Future<void> success(
    BuildContext context, {
    required String message,
    String title = 'Sucesso',
    String buttonLabel = 'OK',
  }) =>
      _show(
        context,
        type: _FeedbackType.success,
        title: title,
        message: message,
        buttonLabel: buttonLabel,
      );

  static Future<void> warning(
    BuildContext context, {
    required String message,
    String title = 'Atenção',
    String buttonLabel = 'Entendi',
  }) =>
      _show(
        context,
        type: _FeedbackType.warning,
        title: title,
        message: message,
        buttonLabel: buttonLabel,
      );

  static Future<void> info(
    BuildContext context, {
    required String message,
    String title = 'Informação',
    String buttonLabel = 'OK',
  }) =>
      _show(
        context,
        type: _FeedbackType.info,
        title: title,
        message: message,
        buttonLabel: buttonLabel,
      );

  static Future<bool> confirm(
    BuildContext context, {
    required String message,
    String title = 'Confirmar',
    String confirmLabel = 'Confirmar',
    String cancelLabel = 'Cancelar',
    bool destructive = false,
  }) =>
      _showConfirm(
        context,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        destructive: destructive,
      );

  // ── Internal ──────────────────────────────────────────────────────────────

  static Future<bool> _showConfirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required String cancelLabel,
    required bool destructive,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        destructive: destructive,
      ),
    ).then((v) => v ?? false);
  }

  static Future<void> _show(
    BuildContext context, {
    required _FeedbackType type,
    required String title,
    required String message,
    required String buttonLabel,
  }) {
    final style = _FeedbackStyle.of(type);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Icon(style.icon, color: style.accentColor, size: 36),
            const SizedBox(height: 16),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Message
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Action button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: style.accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Style helper ──────────────────────────────────────────────────────────────

class _FeedbackStyle {
  final Color accentColor;
  final IconData icon;

  const _FeedbackStyle({required this.accentColor, required this.icon});

  static _FeedbackStyle of(_FeedbackType type) {
    switch (type) {
      case _FeedbackType.error:
        return const _FeedbackStyle(
          accentColor: Color(0xFFDC2626),
          icon: Icons.error_outline_rounded,
        );
      case _FeedbackType.success:
        return const _FeedbackStyle(
          accentColor: Color(0xFF16A34A),
          icon: Icons.check_circle_outline_rounded,
        );
      case _FeedbackType.warning:
        return const _FeedbackStyle(
          accentColor: Color(0xFFD97706),
          icon: Icons.warning_amber_rounded,
        );
      case _FeedbackType.info:
        return const _FeedbackStyle(
          accentColor: Color(0xFF2563EB),
          icon: Icons.info_outline_rounded,
        );
    }
  }
}

// ── Confirm dialog ────────────────────────────────────────────────────────────

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.destructive,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final confirmColor =
        destructive ? const Color(0xFFDC2626) : const Color(0xFF1D4ED8);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            destructive
                ? Icons.delete_outline_rounded
                : Icons.help_outline_rounded,
            color: confirmColor,
            size: 36,
          ),
          const SizedBox(height: 16),

          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    foregroundColor: const Color(0xFF64748B),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(cancelLabel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: confirmColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(confirmLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
