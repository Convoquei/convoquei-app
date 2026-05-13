// Card clicável com ícone, título e subtítulo. Variantes outlined e filled.
// Anteriormente: ActionCard.
//
// Exemplo:
//   DSActionCard(icon: Icons.group, title: 'Equipe', subtitle: 'Gerencie membros', outlined: true, onTap: ...)
//   DSActionCard(icon: Icons.add, title: 'Novo', subtitle: 'Cria evento', outlined: false, onTap: ...)
import 'package:flutter/material.dart';

import '../../theme/ds_context_extensions.dart';
import '../../tokens/ds_radius.dart';
import '../../tokens/ds_spacing.dart';

class DSActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool outlined;

  const DSActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.outlined,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (outlined) {
      return Material(
        color: colors.surface,
        borderRadius: DSRadius.allLg,
        child: InkWell(
          onTap: onTap,
          borderRadius: DSRadius.allLg,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DSSpacing.lg),
            decoration: BoxDecoration(
              border: Border.all(color: colors.border),
              borderRadius: DSRadius.allLg,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: DSRadius.allMd,
                    border: Border.all(color: colors.surfaceSubtle),
                  ),
                  child: Icon(icon, color: colors.textSecondary, size: 24),
                ),
                const SizedBox(width: DSSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 2),
                      Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: colors.border),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: colors.primary,
      borderRadius: DSRadius.allLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: DSRadius.allLg,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(DSSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: DSRadius.allMd,
                ),
                child: Icon(icon, color: colors.onPrimary, size: 24),
              ),
              const SizedBox(width: DSSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: colors.onPrimary,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onPrimary.withValues(alpha: 0.8),
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: colors.onPrimary.withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }
}
