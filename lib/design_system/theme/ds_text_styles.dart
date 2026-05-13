// Estilos de texto semânticos — mapeiam a escala tipográfica para TextStyle.
// Acesse via context.textStyles (ds_context_extensions.dart).
//
// Exemplo:
//   Text('Título', style: context.textStyles.titleLarge)
import 'package:flutter/material.dart';

import '../tokens/ds_typography.dart';

class DSTextStyles extends ThemeExtension<DSTextStyles> {
  const DSTextStyles({
    required this.displayLarge,
    required this.displayMedium,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.labelLarge,
    required this.labelMedium,
    required this.labelSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
  });

  final TextStyle displayLarge;
  final TextStyle displayMedium;
  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle titleSmall;
  final TextStyle labelLarge;
  final TextStyle labelMedium;
  final TextStyle labelSmall;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;

  // ── Construtores ──────────────────────────────────────────────────────────

  DSTextStyles.light({required Color textPrimary, required Color textSecondary})
      : displayLarge = TextStyle(
          fontFamily: DSTypography.displayFamily,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        displayMedium = TextStyle(
          fontFamily: DSTypography.displayFamily,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge = TextStyle(
          fontFamily: DSTypography.displayFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium = TextStyle(
          fontFamily: DSTypography.bodyFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.4,
        ),
        titleSmall = TextStyle(
          fontFamily: DSTypography.bodyFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.4,
        ),
        labelLarge = TextStyle(
          fontFamily: DSTypography.bodyFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          height: 1.2,
        ),
        labelMedium = TextStyle(
          fontFamily: DSTypography.bodyFamily,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          height: 1.2,
        ),
        labelSmall = TextStyle(
          fontFamily: DSTypography.bodyFamily,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          height: 1.2,
        ),
        bodyLarge = TextStyle(
          fontFamily: DSTypography.bodyFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium = TextStyle(
          fontFamily: DSTypography.bodyFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.5,
        ),
        bodySmall = TextStyle(
          fontFamily: DSTypography.bodyFamily,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.5,
        );

  DSTextStyles.dark({required Color textPrimary, required Color textSecondary})
      : this.light(textPrimary: textPrimary, textSecondary: textSecondary);

  // ── ThemeExtension ────────────────────────────────────────────────────────

  @override
  DSTextStyles copyWith({
    TextStyle? displayLarge,
    TextStyle? displayMedium,
    TextStyle? titleLarge,
    TextStyle? titleMedium,
    TextStyle? titleSmall,
    TextStyle? labelLarge,
    TextStyle? labelMedium,
    TextStyle? labelSmall,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
  }) {
    return DSTextStyles(
      displayLarge:  displayLarge  ?? this.displayLarge,
      displayMedium: displayMedium ?? this.displayMedium,
      titleLarge:    titleLarge    ?? this.titleLarge,
      titleMedium:   titleMedium   ?? this.titleMedium,
      titleSmall:    titleSmall    ?? this.titleSmall,
      labelLarge:    labelLarge    ?? this.labelLarge,
      labelMedium:   labelMedium   ?? this.labelMedium,
      labelSmall:    labelSmall    ?? this.labelSmall,
      bodyLarge:     bodyLarge     ?? this.bodyLarge,
      bodyMedium:    bodyMedium    ?? this.bodyMedium,
      bodySmall:     bodySmall     ?? this.bodySmall,
    );
  }

  @override
  DSTextStyles lerp(DSTextStyles? other, double t) {
    if (other == null) return this;
    return DSTextStyles(
      displayLarge:  TextStyle.lerp(displayLarge,  other.displayLarge,  t)!,
      displayMedium: TextStyle.lerp(displayMedium, other.displayMedium, t)!,
      titleLarge:    TextStyle.lerp(titleLarge,    other.titleLarge,    t)!,
      titleMedium:   TextStyle.lerp(titleMedium,   other.titleMedium,   t)!,
      titleSmall:    TextStyle.lerp(titleSmall,    other.titleSmall,    t)!,
      labelLarge:    TextStyle.lerp(labelLarge,    other.labelLarge,    t)!,
      labelMedium:   TextStyle.lerp(labelMedium,   other.labelMedium,   t)!,
      labelSmall:    TextStyle.lerp(labelSmall,    other.labelSmall,    t)!,
      bodyLarge:     TextStyle.lerp(bodyLarge,     other.bodyLarge,     t)!,
      bodyMedium:    TextStyle.lerp(bodyMedium,    other.bodyMedium,    t)!,
      bodySmall:     TextStyle.lerp(bodySmall,     other.bodySmall,     t)!,
    );
  }
}
