import 'package:flutter/material.dart';

import '../../theme/ds_context_extensions.dart';
import '../../tokens/ds_elevation.dart';
import '../../tokens/ds_radius.dart';
import '../buttons/ds_button.dart';

/// Botão de ação 48×48 com bordas arredondadas — padrão de toolbar nas telas de listagem.
/// Usar para ações primárias (criar, convidar) ao lado de [DSSearchInput] e [DSFilterButton].
///
/// Exemplo:
///   DSSquareIconButton(icon: Icons.add_rounded, onPressed: _handleCreate)
///   DSSquareIconButton(icon: Icons.person_add_rounded, schema: DSButtonSchema.ghost, onPressed: _invite)
class DSSquareIconButton extends StatelessWidget {
  const DSSquareIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.schema = DSButtonSchema.primary,
    this.size = 48,
    this.iconSize = 22,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final DSButtonSchema schema;
  final double size;
  final double iconSize;

  bool get _isPrimary => schema == DSButtonSchema.primary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final bg = switch (schema) {
      DSButtonSchema.primary   => colors.primary,
      DSButtonSchema.secondary => colors.secondary,
      DSButtonSchema.success   => colors.success,
      DSButtonSchema.danger    => colors.danger,
      DSButtonSchema.ghost     => colors.surfaceSubtle,
    };

    final iconColor = _isPrimary || schema == DSButtonSchema.success || schema == DSButtonSchema.danger
        ? colors.onPrimary
        : colors.textPrimary;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: onPressed == null ? bg.withValues(alpha: 0.5) : bg,
          borderRadius: DSRadius.allMd,
          border: Border.all(color: colors.border),
          boxShadow: _isPrimary ? DSElevation.md : null,
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: onPressed == null ? iconColor.withValues(alpha: 0.5) : iconColor,
        ),
      ),
    );
  }
}
