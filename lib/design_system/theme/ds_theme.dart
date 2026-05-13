// Monta o ThemeData completo do app consumindo os tokens do design system.
// Use DSTheme.light / DSTheme.dark no MaterialApp.
//
// Exemplo:
//   MaterialApp(theme: DSTheme.light, darkTheme: DSTheme.dark)
import 'package:flutter/material.dart';

import '../tokens/ds_radius.dart';
import '../tokens/ds_typography.dart';
import 'ds_colors.dart';
import 'ds_text_styles.dart';

abstract final class DSTheme {
  static final ThemeData light = _build(const DSColors.light());
  static final ThemeData dark  = _build(const DSColors.dark());

  static ThemeData _build(DSColors colors) {
    final textStyles = colors == const DSColors.light()
        ? DSTextStyles.light(
            textPrimary:   colors.textPrimary,
            textSecondary: colors.textSecondary,
          )
        : DSTextStyles.dark(
            textPrimary:   colors.textPrimary,
            textSecondary: colors.textSecondary,
          );

    final brightness = colors.background.computeLuminance() > 0.5
        ? Brightness.light
        : Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,

      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: brightness,
        primary: colors.primary,
        secondary: colors.secondary,
        surface: colors.background,
      ),

      extensions: [colors, textStyles],

      scaffoldBackgroundColor: colors.background,

      textTheme: TextTheme(
        displayLarge:  textStyles.displayLarge,
        displayMedium: textStyles.displayMedium,
        titleLarge:    textStyles.titleLarge,
        titleMedium:   textStyles.titleMedium,
        titleSmall:    textStyles.titleSmall,
        labelLarge:    textStyles.labelLarge,
        labelMedium:   textStyles.labelMedium,
        labelSmall:    textStyles.labelSmall,
        bodyLarge:     textStyles.bodyLarge,
        bodyMedium:    textStyles.bodyMedium,
        bodySmall:     textStyles.bodySmall,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: DSTypography.displayFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: DSRadius.allMd),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: DSTypography.bodyFamily,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: DSRadius.allLg),
      ),

      datePickerTheme: DatePickerThemeData(
        backgroundColor: colors.surface,
        headerBackgroundColor: colors.primary,
        headerForegroundColor: colors.onPrimary,
        headerHeadlineStyle: TextStyle(
          fontFamily: DSTypography.displayFamily,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: colors.onPrimary,
        ),
        headerHelpStyle: TextStyle(
          fontFamily: DSTypography.bodyFamily,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: colors.onPrimary.withValues(alpha: 0.7),
          letterSpacing: 1.2,
        ),
        shape: RoundedRectangleBorder(borderRadius: DSRadius.allXl),
        dayStyle: const TextStyle(fontFamily: DSTypography.bodyFamily, fontSize: 13),
        weekdayStyle: TextStyle(
          fontFamily: DSTypography.bodyFamily,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colors.textSecondary,
        ),
        yearStyle: const TextStyle(fontFamily: DSTypography.bodyFamily, fontSize: 13),
        todayBorder: BorderSide(color: colors.primary, width: 1.5),
        todayForegroundColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.onPrimary
              : colors.primary,
        ),
        dayForegroundColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) return colors.border;
          if (states.contains(WidgetState.selected)) return colors.onPrimary;
          return colors.textPrimary;
        }),
        dayBackgroundColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primary
              : Colors.transparent,
        ),
        dayOverlayColor: WidgetStateColor.resolveWith(
          (_) => colors.primary.withValues(alpha: 0.08),
        ),
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: colors.textSecondary,
          textStyle: const TextStyle(
            fontFamily: DSTypography.bodyFamily,
            fontWeight: FontWeight.w500,
          ),
        ),
        confirmButtonStyle: TextButton.styleFrom(
          foregroundColor: colors.primary,
          textStyle: const TextStyle(
            fontFamily: DSTypography.bodyFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      timePickerTheme: TimePickerThemeData(
        backgroundColor: colors.surface,
        hourMinuteColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primary.withValues(alpha: 0.12)
              : colors.background,
        ),
        hourMinuteTextColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primary
              : colors.textPrimary,
        ),
        hourMinuteShape: RoundedRectangleBorder(borderRadius: DSRadius.allMd),
        dialBackgroundColor: colors.background,
        dialHandColor: colors.primary,
        dialTextColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.onPrimary
              : colors.textPrimary,
        ),
        entryModeIconColor: colors.textSecondary,
        helpTextStyle: TextStyle(
          fontFamily: DSTypography.bodyFamily,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: colors.textSecondary,
          letterSpacing: 1.2,
        ),
        hourMinuteTextStyle: const TextStyle(
          fontFamily: DSTypography.displayFamily,
          fontSize: 48,
          fontWeight: FontWeight.w600,
        ),
        dayPeriodTextStyle: const TextStyle(
          fontFamily: DSTypography.bodyFamily,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        dayPeriodColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primary.withValues(alpha: 0.12)
              : colors.background,
        ),
        dayPeriodTextColor: WidgetStateColor.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primary
              : colors.textSecondary,
        ),
        shape: RoundedRectangleBorder(borderRadius: DSRadius.allXl),
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: colors.textSecondary,
          textStyle: const TextStyle(
            fontFamily: DSTypography.bodyFamily,
            fontWeight: FontWeight.w500,
          ),
        ),
        confirmButtonStyle: TextButton.styleFrom(
          foregroundColor: colors.primary,
          textStyle: const TextStyle(
            fontFamily: DSTypography.bodyFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: WidgetStateColor.resolveWith((_) => colors.surface),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(
          fontFamily: DSTypography.bodyFamily,
          fontSize: 13,
          color: colors.textSecondary,
        ),
        labelStyle: TextStyle(
          fontFamily: DSTypography.bodyFamily,
          fontSize: 13,
          color: colors.textSecondary,
        ),
        prefixIconColor: colors.textSecondary,
        suffixIconColor: colors.textSecondary,
        border: OutlineInputBorder(
          borderRadius: DSRadius.allMd,
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: DSRadius.allMd,
          borderSide: BorderSide(color: colors.border),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: DSRadius.allMd,
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: DSRadius.allMd,
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: DSRadius.allMd,
          borderSide: BorderSide(color: colors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: DSRadius.allMd,
          borderSide: BorderSide(color: colors.danger, width: 1.5),
        ),
        errorStyle: TextStyle(
          fontFamily: DSTypography.bodyFamily,
          fontSize: 12,
          color: colors.danger,
        ),
      ),
    );
  }
}
