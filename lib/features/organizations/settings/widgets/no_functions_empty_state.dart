import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class NoFunctionsEmptyState extends StatelessWidget {
  const NoFunctionsEmptyState({super.key, this.onCreateFunction});

  final VoidCallback? onCreateFunction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.surfaceSubtle,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: const Text('🎵', style: TextStyle(fontSize: 36)),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma função criada ainda',
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Funções ajudam a identificar a atividade de cada membro dentro da organização.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          if (onCreateFunction != null) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onCreateFunction,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Criar primeira função'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
