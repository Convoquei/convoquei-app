// Ícone com tamanhos pré-definidos em tokens.
//
// Exemplo:
//   DSIcon(Icons.check_rounded)
//   DSIcon(Icons.close, size: DSIconSize.sm, color: context.colors.textSecondary)
import 'package:flutter/material.dart';

import '../theme/ds_context_extensions.dart';

enum DSIconSize { xs, sm, md, lg }

class DSIcon extends StatelessWidget {
  final IconData icon;
  final DSIconSize size;
  final Color? color;

  const DSIcon(
    this.icon, {
    super.key,
    this.size = DSIconSize.md,
    this.color,
  });

  double get _sizeValue => switch (size) {
    DSIconSize.xs => 14,
    DSIconSize.sm => 18,
    DSIconSize.md => 24,
    DSIconSize.lg => 32,
  };

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: _sizeValue,
      color: color ?? context.colors.textSecondary,
    );
  }
}
