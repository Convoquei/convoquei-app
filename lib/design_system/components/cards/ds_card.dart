// Card base com superfície branca, raio lg e borda sutil.
// Use como container de conteúdo padronizado.
//
// Exemplo:
//   DSCard(child: Text('Conteúdo'))
//   DSCard(padding: EdgeInsets.all(DSSpacing.xl), child: MyContent())
import 'package:flutter/material.dart';

import '../../theme/ds_context_extensions.dart';
import '../../tokens/ds_radius.dart';
import '../../tokens/ds_spacing.dart';

class DSCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool hasBorder;
  final bool hasElevation;

  const DSCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.hasBorder = true,
    this.hasElevation = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectivePadding = padding ?? const EdgeInsets.all(DSSpacing.lg);

    final decoration = BoxDecoration(
      color: colors.surface,
      borderRadius: DSRadius.allLg,
      border: hasBorder ? Border.all(color: colors.border) : null,
      boxShadow: hasElevation
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ]
          : null,
    );

    if (onTap != null) {
      return Material(
        color: colors.surface,
        borderRadius: DSRadius.allLg,
        child: InkWell(
          onTap: onTap,
          borderRadius: DSRadius.allLg,
          child: Ink(
            decoration: decoration,
            child: Padding(padding: effectivePadding, child: child),
          ),
        ),
      );
    }

    return Container(
      decoration: decoration,
      padding: effectivePadding,
      child: child,
    );
  }
}
