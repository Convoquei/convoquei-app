// Etiqueta colorida de status com variantes visuais.
// Anteriormente: TagLabel.
//
// Exemplo:
//   DSBadge(label: 'Disponível', color: context.colors.success)
//   DSBadge(label: 'Cancelado', color: context.colors.danger, variant: DSBadgeVariant.filled)
import 'package:flutter/material.dart';

import '../tokens/ds_colors_primitive.dart';
import '../tokens/ds_radius.dart';
import '../tokens/ds_typography.dart';

enum DSBadgeVariant { filled, outlined, soft, ghost, elevated }

enum DSBadgeSize { sm, md, lg }

class DSBadge extends StatelessWidget {
  const DSBadge({
    super.key,
    required this.label,
    required this.color,
    this.variant = DSBadgeVariant.soft,
    this.size = DSBadgeSize.sm,
  });

  final String label;
  final Color color;
  final DSBadgeVariant variant;
  final DSBadgeSize size;

  double get _fontSize => switch (size) {
    DSBadgeSize.sm => 10,
    DSBadgeSize.md => 12,
    DSBadgeSize.lg => 14,
  };

  EdgeInsets get _padding => switch (size) {
    DSBadgeSize.sm => const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    DSBadgeSize.md => const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    DSBadgeSize.lg => const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  };

  double get _borderRadius => switch (size) {
    DSBadgeSize.sm => DSRadius.sm - 2,
    DSBadgeSize.md => DSRadius.sm,
    DSBadgeSize.lg => DSRadius.md - 2,
  };

  Color get _backgroundColor => switch (variant) {
    DSBadgeVariant.filled   => color,
    DSBadgeVariant.outlined => Colors.transparent,
    DSBadgeVariant.soft     => color.withValues(alpha: 0.10),
    DSBadgeVariant.ghost    => Colors.transparent,
    DSBadgeVariant.elevated => Colors.white,
  };

  Border? get _border => switch (variant) {
    DSBadgeVariant.filled   => null,
    DSBadgeVariant.outlined => Border.all(color: color),
    DSBadgeVariant.soft     => Border.all(color: color.withValues(alpha: 0.25)),
    DSBadgeVariant.ghost    => null,
    DSBadgeVariant.elevated => Border.all(color: DSColorsPrimitive.slate200),
  };

  Color get _textColor => switch (variant) {
    DSBadgeVariant.filled   => Colors.white,
    DSBadgeVariant.outlined => color,
    DSBadgeVariant.soft     => color,
    DSBadgeVariant.ghost    => color,
    DSBadgeVariant.elevated => DSColorsPrimitive.slate500,
  };

  List<BoxShadow>? get _shadow => variant == DSBadgeVariant.elevated
      ? const [BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 1))]
      : null;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(_borderRadius),
        border: _border,
        boxShadow: _shadow,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: DSTypography.bodyFamily,
          fontSize: _fontSize,
          fontWeight: FontWeight.w500,
          color: _textColor,
          height: 1.2,
        ),
      ),
    );
  }
}
