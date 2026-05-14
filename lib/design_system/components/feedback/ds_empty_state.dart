// Estado vazio genérico com ícone circular, título, descrição e ação opcional.
//
// Exemplo:
//   DSEmptyState(
//     icon: Icons.event_busy_rounded,
//     title: 'Nenhum evento próximo',
//     description: 'Crie o primeiro evento da sua organização.',
//     actionLabel: 'Criar evento',
//     onAction: _createEvent,
//   )
import 'package:flutter/material.dart';

import '../../theme/ds_context_extensions.dart';
import '../../tokens/ds_spacing.dart';
import '../buttons/ds_button.dart';

class DSEmptyState extends StatelessWidget {
  const DSEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: colors.primary),
            ),
            const SizedBox(height: DSSpacing.xl),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: DSSpacing.md),
              Text(
                description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: DSSpacing.xl),
              DSButton(
                label: actionLabel!,
                fullWidth: false,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
