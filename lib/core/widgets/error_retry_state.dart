import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/action_button.dart';
import 'package:flutter/material.dart';

/// Estado de erro animado com ícone configurável e ações contextuais.
///
/// Exibe:
/// - Ícone animado (pop-in) dentro de um círculo vermelho translúcido.
/// - Título [message] e [description] opcional.
/// - Botão "Tentar Novamente" se [onRetry] for fornecido.
/// - Botão "Voltar" se houver uma rota anterior na pilha de navegação.
class ErrorRetryState extends StatelessWidget {
  const ErrorRetryState({
    super.key,
    required this.message,
    this.description,
    this.icon = Icons.cloud_off_rounded,
    this.onRetry,
  });

  final String message;
  final String? description;
  final IconData icon;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.5, end: 1.0),
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            builder: (_, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.errorColor.withValues(alpha: 0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.errorColor.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: AppTheme.errorColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            builder: (_, t, child) => Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(0, 10 * (1 - t)),
                child: child,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    description!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 32),
                if (onRetry != null)
                  ActionButton(
                    label: 'Tentar Novamente',
                    icon: Icons.refresh_rounded,
                    onPressed: onRetry,
                  ),
                if (onRetry != null && canPop) const SizedBox(height: 12),
                if (canPop)
                  ActionButton(
                    label: 'Voltar',
                    icon: Icons.arrow_back_rounded,
                    outlined: true,
                    schema: ActionButtonSchema.ghost,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
