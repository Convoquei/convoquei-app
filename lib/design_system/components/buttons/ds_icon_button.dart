// Botão circular de ação com ícone e variante de cor semântica.
//
// Exemplo:
//   DSIconButton(icon: Icons.close, onPressed: _close)
//   DSIconButton(icon: Icons.add, backgroundColor: context.colors.surfaceSubtle, onPressed: _add)
import 'package:flutter/material.dart';

import '../../theme/ds_context_extensions.dart';
import '../../tokens/ds_spacing.dart';

class DSIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  const DSIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.surfaceSubtle,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: DSSpacing.xl, color: iconColor ?? colors.textPrimary),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
