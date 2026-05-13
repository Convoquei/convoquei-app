// Estado de erro animado com ícone, mensagem e ações. Anteriormente: ErrorRetryState.
//
// Exemplo:
//   DSErrorRetryState(message: 'Erro ao carregar', onRetry: _reload)
//   DSErrorRetryState(message: 'Sem conexão', description: 'Verifique a internet.', icon: Icons.wifi_off_rounded)
import 'package:flutter/material.dart';

import '../../theme/ds_context_extensions.dart';
import '../../tokens/ds_spacing.dart';
import '../buttons/ds_button.dart';

class DSErrorRetryState extends StatelessWidget {
  const DSErrorRetryState({
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
    final colors = context.colors;
    final canPop = Navigator.canPop(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.5, end: 1.0),
            duration: const Duration(milliseconds: 700),
            curve: Curves.elasticOut,
            builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: colors.danger.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(color: colors.danger.withValues(alpha: 0.15)),
                boxShadow: [
                  BoxShadow(
                    color: colors.danger.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(color: colors.surface, shape: BoxShape.circle),
                  child: Icon(icon, size: 32, color: colors.danger),
                ),
              ),
            ),
          ),
          const SizedBox(height: DSSpacing.xl),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            builder: (_, t, child) => Opacity(
              opacity: t,
              child: Transform.translate(offset: Offset(0, 10 * (1 - t)), child: child),
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
                  const SizedBox(height: DSSpacing.md),
                  Text(
                    description!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: DSSpacing.xxl),
                if (onRetry != null)
                  DSButton(
                    label: 'Tentar Novamente',
                    icon: Icons.refresh_rounded,
                    onPressed: onRetry,
                  ),
                if (onRetry != null && canPop) const SizedBox(height: DSSpacing.md),
                if (canPop)
                  DSButton(
                    label: 'Voltar',
                    icon: Icons.arrow_back_rounded,
                    outlined: true,
                    schema: DSButtonSchema.ghost,
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
