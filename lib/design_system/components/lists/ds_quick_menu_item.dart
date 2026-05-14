// Atalho de ação rápida: ícone em tile + label abaixo.
// DSQuickMenuItem(icon: Icons.add_rounded, label: 'Novo Evento', onTap: _create)
import 'package:flutter/material.dart';

import '../../theme/ds_context_extensions.dart';
import '../../tokens/ds_radius.dart';
import '../../tokens/ds_spacing.dart';
import '../../foundations/ds_text.dart';

class DSQuickMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const DSQuickMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: DSRadius.allLg,
              border: Border.all(color: colors.border),
            ),
            child: Icon(icon, color: colors.primary, size: 24),
          ),
          const SizedBox(height: DSSpacing.xs),
          DSText(
            label,
            variant: DSTextVariant.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
