// Tile selecionável com checkbox visual animado. Anteriormente: SelectableTile.
//
// Exemplo:
//   DSSelectableTile(title: 'Domingo', isSelected: _selected, onTap: _toggle)
//   DSSelectableTile(title: 'Manhã', description: '6h–12h', isSelected: false, onTap: _toggle)
import 'package:flutter/material.dart';

import '../../theme/ds_context_extensions.dart';
import '../../tokens/ds_motion.dart';
import '../../tokens/ds_radius.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';

class DSSelectableTile extends StatelessWidget {
  const DSSelectableTile({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.description,
  });

  final String title;
  final String? description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: DSSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: DSRadius.allLg,
        child: AnimatedContainer(
          duration: DSMotion.fast,
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.lg,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: isSelected ? colors.primary.withValues(alpha: 0.05) : colors.surface,
            borderRadius: DSRadius.allLg,
            border: Border.all(
              color: isSelected
                  ? colors.primary.withValues(alpha: 0.4)
                  : colors.border,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: DSTypography.bodyFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        description!,
                        style: TextStyle(
                          fontFamily: DSTypography.bodyFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: DSSpacing.md),
              AnimatedContainer(
                duration: DSMotion.fast,
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? colors.primary : colors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? colors.primary : colors.border,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(Icons.check, size: 16, color: colors.onPrimary)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
