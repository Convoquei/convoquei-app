// Tokens semânticos de cor — mapeiam a paleta crua para intenções visuais.
// Acesse via context.colors (ds_context_extensions.dart), nunca diretamente.
//
// Exemplo:
//   Container(color: context.colors.surface)
import 'package:flutter/material.dart';

import '../tokens/ds_colors_primitive.dart';

class DSColors extends ThemeExtension<DSColors> {
  const DSColors({
    required this.background,
    required this.surface,
    required this.surfaceSubtle,
    required this.surfaceElevated,
    required this.border,
    required this.borderStrong,
    required this.divider,
    required this.primary,
    required this.primaryTint,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textOnPrimary,
    required this.success,
    required this.successTint,
    required this.warning,
    required this.warningTint,
    required this.danger,
    required this.dangerTint,
    required this.info,
    required this.infoTint,
  });

  final Color background;
  final Color surface;
  final Color surfaceSubtle;
  final Color surfaceElevated;

  final Color border;
  final Color borderStrong;
  final Color divider;

  final Color primary;
  final Color primaryTint;
  final Color onPrimary;

  final Color secondary;
  final Color onSecondary;

  final Color textPrimary;
  final Color textSecondary;
  final Color textOnPrimary;

  final Color success;
  final Color successTint;
  final Color warning;
  final Color warningTint;
  final Color danger;
  final Color dangerTint;
  final Color info;
  final Color infoTint;

  // ── Construtores ──────────────────────────────────────────────────────────

  const DSColors.light()
      : background     = DSColorsPrimitive.slate50,
        surface        = const Color(0xFFFFFFFF),
        surfaceSubtle  = DSColorsPrimitive.slate100,
        surfaceElevated = const Color(0xFFFFFFFF),
        border         = DSColorsPrimitive.slate200,
        borderStrong   = DSColorsPrimitive.slate500,
        divider        = DSColorsPrimitive.slate200,
        primary        = DSColorsPrimitive.blue700,
        primaryTint    = const Color(0x0F1D4ED8), // blue700 6%
        onPrimary      = const Color(0xFFFFFFFF),
        secondary      = DSColorsPrimitive.orange500,
        onSecondary    = const Color(0xFFFFFFFF),
        textPrimary    = DSColorsPrimitive.slate800,
        textSecondary  = DSColorsPrimitive.slate500,
        textOnPrimary  = const Color(0xFFFFFFFF),
        success        = DSColorsPrimitive.green500,
        successTint    = DSColorsPrimitive.green100,
        warning        = DSColorsPrimitive.amber500,
        warningTint    = DSColorsPrimitive.amber100,
        danger         = DSColorsPrimitive.red500,
        dangerTint     = DSColorsPrimitive.red100,
        info           = DSColorsPrimitive.sky500,
        infoTint       = DSColorsPrimitive.sky100;

  const DSColors.dark()
      : background     = DSColorsPrimitive.darkBackground,
        surface        = DSColorsPrimitive.darkSurface,
        surfaceSubtle  = DSColorsPrimitive.darkSubtle,
        surfaceElevated = const Color(0xFF334155),
        border         = DSColorsPrimitive.darkBorder,
        borderStrong   = DSColorsPrimitive.slate500,
        divider        = DSColorsPrimitive.darkBorder,
        primary        = DSColorsPrimitive.blue500,
        primaryTint    = const Color(0x1A2563EB), // blue500 10%
        onPrimary      = const Color(0xFFFFFFFF),
        secondary      = DSColorsPrimitive.orange500,
        onSecondary    = const Color(0xFFFFFFFF),
        textPrimary    = const Color(0xFFF1F5F9),
        textSecondary  = DSColorsPrimitive.slate500,
        textOnPrimary  = const Color(0xFFFFFFFF),
        success        = DSColorsPrimitive.green500,
        successTint    = const Color(0xFF064E3B),
        warning        = DSColorsPrimitive.amber500,
        warningTint    = const Color(0xFF78350F),
        danger         = DSColorsPrimitive.red500,
        dangerTint     = const Color(0xFF7F1D1D),
        info           = DSColorsPrimitive.sky500,
        infoTint       = const Color(0xFF1E3A5F);

  // ── ThemeExtension ────────────────────────────────────────────────────────

  @override
  DSColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceSubtle,
    Color? surfaceElevated,
    Color? border,
    Color? borderStrong,
    Color? divider,
    Color? primary,
    Color? primaryTint,
    Color? onPrimary,
    Color? secondary,
    Color? onSecondary,
    Color? textPrimary,
    Color? textSecondary,
    Color? textOnPrimary,
    Color? success,
    Color? successTint,
    Color? warning,
    Color? warningTint,
    Color? danger,
    Color? dangerTint,
    Color? info,
    Color? infoTint,
  }) {
    return DSColors(
      background:      background      ?? this.background,
      surface:         surface         ?? this.surface,
      surfaceSubtle:   surfaceSubtle   ?? this.surfaceSubtle,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      border:          border          ?? this.border,
      borderStrong:    borderStrong    ?? this.borderStrong,
      divider:         divider         ?? this.divider,
      primary:         primary         ?? this.primary,
      primaryTint:     primaryTint     ?? this.primaryTint,
      onPrimary:       onPrimary       ?? this.onPrimary,
      secondary:       secondary       ?? this.secondary,
      onSecondary:     onSecondary     ?? this.onSecondary,
      textPrimary:     textPrimary     ?? this.textPrimary,
      textSecondary:   textSecondary   ?? this.textSecondary,
      textOnPrimary:   textOnPrimary   ?? this.textOnPrimary,
      success:         success         ?? this.success,
      successTint:     successTint     ?? this.successTint,
      warning:         warning         ?? this.warning,
      warningTint:     warningTint     ?? this.warningTint,
      danger:          danger          ?? this.danger,
      dangerTint:      dangerTint      ?? this.dangerTint,
      info:            info            ?? this.info,
      infoTint:        infoTint        ?? this.infoTint,
    );
  }

  @override
  DSColors lerp(DSColors? other, double t) {
    if (other == null) return this;
    return DSColors(
      background:      Color.lerp(background,      other.background,      t)!,
      surface:         Color.lerp(surface,          other.surface,         t)!,
      surfaceSubtle:   Color.lerp(surfaceSubtle,    other.surfaceSubtle,   t)!,
      surfaceElevated: Color.lerp(surfaceElevated,  other.surfaceElevated, t)!,
      border:          Color.lerp(border,           other.border,          t)!,
      borderStrong:    Color.lerp(borderStrong,     other.borderStrong,    t)!,
      divider:         Color.lerp(divider,          other.divider,         t)!,
      primary:         Color.lerp(primary,          other.primary,         t)!,
      primaryTint:     Color.lerp(primaryTint,      other.primaryTint,     t)!,
      onPrimary:       Color.lerp(onPrimary,        other.onPrimary,       t)!,
      secondary:       Color.lerp(secondary,        other.secondary,       t)!,
      onSecondary:     Color.lerp(onSecondary,      other.onSecondary,     t)!,
      textPrimary:     Color.lerp(textPrimary,      other.textPrimary,     t)!,
      textSecondary:   Color.lerp(textSecondary,    other.textSecondary,   t)!,
      textOnPrimary:   Color.lerp(textOnPrimary,    other.textOnPrimary,   t)!,
      success:         Color.lerp(success,          other.success,         t)!,
      successTint:     Color.lerp(successTint,      other.successTint,     t)!,
      warning:         Color.lerp(warning,          other.warning,         t)!,
      warningTint:     Color.lerp(warningTint,      other.warningTint,     t)!,
      danger:          Color.lerp(danger,           other.danger,          t)!,
      dangerTint:      Color.lerp(dangerTint,       other.dangerTint,      t)!,
      info:            Color.lerp(info,             other.info,            t)!,
      infoTint:        Color.lerp(infoTint,         other.infoTint,        t)!,
    );
  }
}
