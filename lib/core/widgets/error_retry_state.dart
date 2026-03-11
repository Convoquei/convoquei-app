import 'package:convoquei_app/core/widgets/action_button.dart';
import 'package:flutter/material.dart';

/// Estado de erro genérico com botão de tentar novamente.
class ErrorRetryState extends StatelessWidget {
  final VoidCallback onRetry;
  final String message;
  final String description;

  const ErrorRetryState({
    super.key,
    required this.onRetry,
    this.message = 'Não foi possível carregar os dados',
    this.description = 'Verifique sua conexão e tente novamente.',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ActionButton(
            label: 'Tentar novamente',
            icon: Icons.refresh_rounded,
            outlined: true,
            fullWidth: false,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
