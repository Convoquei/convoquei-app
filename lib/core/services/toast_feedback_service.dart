import 'package:flutter/material.dart';

enum ToastType { success, error, info }

class ToastFeedbackService {
  static void showToast(BuildContext context, String message, ToastType type) {
    if (!context.mounted) return;

    final config = _ToastConfig.from(type);

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          duration: const Duration(seconds: 3),
          content: _ToastWidget(message: message, config: config),
        ),
      );
  }
}

class _ToastConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final IconData icon;
  final String label;

  const _ToastConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.icon,
    required this.label,
  });

  factory _ToastConfig.from(ToastType type) {
    switch (type) {
      case ToastType.success:
        return const _ToastConfig(
          backgroundColor: Color(0xFFF0FDF4),
          borderColor: Color(0xFF86EFAC),
          iconColor: Color(0xFF16A34A),
          icon: Icons.check_circle_rounded,
          label: 'Sucesso',
        );
      case ToastType.error:
        return const _ToastConfig(
          backgroundColor: Color(0xFFFEF2F2),
          borderColor: Color(0xFFFCA5A5),
          iconColor: Color(0xFFDC2626),
          icon: Icons.cancel_rounded,
          label: 'Erro',
        );
      case ToastType.info:
        return const _ToastConfig(
          backgroundColor: Color(0xFFEFF6FF),
          borderColor: Color(0xFF93C5FD),
          iconColor: Color(0xFF1D4ED8), // primaryColor do tema
          icon: Icons.info_rounded,
          label: 'Informação',
        );
    }
  }
}

class _ToastWidget extends StatelessWidget {
  final String message;
  final _ToastConfig config;

  const _ToastWidget({required this.message, required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: config.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(config.icon, color: config.iconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  config.label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: config.iconColor,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF1E293B), // textPrimary
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}