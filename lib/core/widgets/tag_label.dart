import 'package:flutter/material.dart';

enum TagLabelVariant { filled, outlined, soft, ghost, elevated }

enum TagLabelSize { sm, md, lg }

class TagLabel extends StatelessWidget {
  const TagLabel({
    super.key,
    required this.label,
    required this.color,
    this.variant = TagLabelVariant.soft,
    this.size = TagLabelSize.sm,
  });

  final String label;

  /// Cor base da tag. Fundo, borda e texto são derivados dela conforme a variante.
  final Color color;

  final TagLabelVariant variant;
  final TagLabelSize size;

  // ─── Tamanhos ──────────────────────────────────────────────────────────────

  double get _fontSize => switch (size) {
    TagLabelSize.sm => 10,
    TagLabelSize.md => 12,
    TagLabelSize.lg => 14,
  };

  EdgeInsets get _padding => switch (size) {
    TagLabelSize.sm => const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    TagLabelSize.md => const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    TagLabelSize.lg => const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  };

  double get _borderRadius => switch (size) {
    TagLabelSize.sm => 6,
    TagLabelSize.md => 8,
    TagLabelSize.lg => 10,
  };

  // ─── Variantes ─────────────────────────────────────────────────────────────

  Color get _backgroundColor => switch (variant) {
    TagLabelVariant.filled   => color,
    TagLabelVariant.outlined => Colors.transparent,
    TagLabelVariant.soft     => color.withOpacity(0.10),
    TagLabelVariant.ghost    => Colors.transparent,
    TagLabelVariant.elevated => Colors.white,
  };

  Border? get _border => switch (variant) {
    TagLabelVariant.filled   => null,
    TagLabelVariant.outlined => Border.all(color: color),
    TagLabelVariant.soft     => Border.all(color: color.withOpacity(0.25)),
    TagLabelVariant.ghost    => null,
    TagLabelVariant.elevated => Border.all(color: const Color(0xFFE2E8F0)),
  };

  Color get _textColor => switch (variant) {
    TagLabelVariant.filled   => Colors.white,
    TagLabelVariant.outlined => color,
    TagLabelVariant.soft     => color,
    TagLabelVariant.ghost    => color,
    TagLabelVariant.elevated => const Color(0xFF64748B),
  };

  List<BoxShadow>? get _shadow => variant == TagLabelVariant.elevated
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
          fontFamily: 'Inter',
          fontSize: _fontSize,
          fontWeight: FontWeight.w500,
          color: _textColor,
          height: 1.2,
        ),
      ),
    );
  }
}