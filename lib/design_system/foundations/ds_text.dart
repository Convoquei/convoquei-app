// Wrapper de texto que aplica variantes tipográficas do design system.
// Para uso inline, prefira Text(..., style: context.textStyles.titleLarge).
//
// Exemplo:
//   DSText('Título', variant: DSTextVariant.titleLarge)
//   DSText('Subtítulo', variant: DSTextVariant.bodyMedium, color: context.colors.textSecondary)
import 'package:flutter/material.dart';

import '../theme/ds_context_extensions.dart';

enum DSTextVariant {
  displayLarge,
  displayMedium,
  titleLarge,
  titleMedium,
  titleSmall,
  labelLarge,
  labelMedium,
  labelSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
}

class DSText extends StatelessWidget {
  final String data;
  final DSTextVariant variant;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const DSText(
    this.data, {
    super.key,
    this.variant = DSTextVariant.bodyMedium,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  TextStyle _resolveStyle(BuildContext context) {
    final styles = context.textStyles;
    final base = switch (variant) {
      DSTextVariant.displayLarge  => styles.displayLarge,
      DSTextVariant.displayMedium => styles.displayMedium,
      DSTextVariant.titleLarge    => styles.titleLarge,
      DSTextVariant.titleMedium   => styles.titleMedium,
      DSTextVariant.titleSmall    => styles.titleSmall,
      DSTextVariant.labelLarge    => styles.labelLarge,
      DSTextVariant.labelMedium   => styles.labelMedium,
      DSTextVariant.labelSmall    => styles.labelSmall,
      DSTextVariant.bodyLarge     => styles.bodyLarge,
      DSTextVariant.bodyMedium    => styles.bodyMedium,
      DSTextVariant.bodySmall     => styles.bodySmall,
    };
    return color != null ? base.copyWith(color: color) : base;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: _resolveStyle(context),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
