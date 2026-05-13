// Botão de ação reutilizável com schemas, tamanhos, loading e ícone.
// Anteriormente: ActionButton.
//
// Exemplo:
//   DSButton(label: 'Salvar', onPressed: _save)
//   DSButton(label: 'Cancelar', outlined: true, schema: DSButtonSchema.ghost, fullWidth: false, onPressed: _cancel)
//   DSButton(label: 'Disponível', schema: DSButtonSchema.success, icon: Icons.check_rounded, isLoading: _loading, onPressed: _submit)
import 'package:flutter/material.dart';

import '../../theme/ds_context_extensions.dart';
import '../../tokens/ds_radius.dart';
import '../../tokens/ds_typography.dart';

enum DSButtonSchema { primary, secondary, success, danger, ghost }

enum DSButtonSize {
  /// Altura 52 · fontSize 14 · iconSize 18
  md,
  /// Altura 40 · fontSize 13 · iconSize 16
  sm,
  /// Altura 32 · fontSize 11 · iconSize 13
  xs,
}

class DSButton extends StatelessWidget {
  const DSButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.outlined = false,
    this.icon,
    this.schema = DSButtonSchema.primary,
    this.size = DSButtonSize.md,
    this.fullWidth = true,
    this.height,
    this.borderRadius,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool outlined;
  final IconData? icon;
  final DSButtonSchema schema;
  final DSButtonSize size;
  final bool fullWidth;
  final double? height;
  final double? borderRadius;

  // ── Dimensões ─────────────────────────────────────────────────────────────

  double get _height => height ?? switch (size) {
    DSButtonSize.md => 52,
    DSButtonSize.sm => 40,
    DSButtonSize.xs => 32,
  };

  double get _borderRadiusValue => borderRadius ?? switch (size) {
    DSButtonSize.md => DSRadius.lg,
    DSButtonSize.sm => DSRadius.md,
    DSButtonSize.xs => DSRadius.sm,
  };

  double get _fontSize => switch (size) {
    DSButtonSize.md => 14,
    DSButtonSize.sm => 13,
    DSButtonSize.xs => 11,
  };

  double get _iconSize => switch (size) {
    DSButtonSize.md => 18,
    DSButtonSize.sm => 16,
    DSButtonSize.xs => 13,
  };

  double get _iconSpacing => switch (size) {
    DSButtonSize.md => 8,
    DSButtonSize.sm => 6,
    DSButtonSize.xs => 4,
  };

  double get _spinnerSize => switch (size) {
    DSButtonSize.md => 20,
    DSButtonSize.sm => 17,
    DSButtonSize.xs => 14,
  };

  // ── Cores (resolvidas em build para acessar context) ──────────────────────

  Color _schemaColor(BuildContext context) => switch (schema) {
    DSButtonSchema.primary   => context.colors.primary,
    DSButtonSchema.secondary => context.colors.secondary,
    DSButtonSchema.success   => context.colors.success,
    DSButtonSchema.danger    => context.colors.danger,
    DSButtonSchema.ghost     => context.colors.textSecondary,
  };

  Color _schemaTint(BuildContext context) => switch (schema) {
    DSButtonSchema.primary   => context.colors.primaryTint,
    DSButtonSchema.secondary => context.colors.secondary.withValues(alpha: 0.06),
    DSButtonSchema.success   => context.colors.successTint,
    DSButtonSchema.danger    => context.colors.dangerTint,
    DSButtonSchema.ghost     => context.colors.surfaceSubtle,
  };

  Color _schemaBorder(BuildContext context) => switch (schema) {
    DSButtonSchema.primary   => context.colors.primary.withValues(alpha: 0.5),
    DSButtonSchema.secondary => context.colors.secondary.withValues(alpha: 0.5),
    DSButtonSchema.success   => context.colors.successTint,
    DSButtonSchema.danger    => context.colors.dangerTint,
    DSButtonSchema.ghost     => context.colors.border,
  };

  BorderRadius get _borderRadiusObj => BorderRadius.circular(_borderRadiusValue);

  // ── Conteúdo ──────────────────────────────────────────────────────────────

  Widget _buildChild(Color foreground) {
    if (isLoading) {
      return SizedBox(
        width: _spinnerSize,
        height: _spinnerSize,
        child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _iconSize, color: foreground),
          SizedBox(width: _iconSpacing),
          Text(label),
        ],
      );
    }
    return Text(label);
  }

  @override
  Widget build(BuildContext context) {
    final color = _schemaColor(context);
    final effectiveOnPressed = isLoading ? null : onPressed;
    final textStyle = TextStyle(
      fontFamily: DSTypography.bodyFamily,
      fontWeight: FontWeight.w600,
      fontSize: _fontSize,
    );

    Widget button;

    if (outlined) {
      button = OutlinedButton(
        onPressed: effectiveOnPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          backgroundColor: _schemaTint(context),
          disabledForegroundColor: color.withValues(alpha: 0.45),
          disabledBackgroundColor: _schemaTint(context),
          side: BorderSide(color: _schemaBorder(context), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: _borderRadiusObj),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          textStyle: textStyle,
        ),
        child: _buildChild(
          effectiveOnPressed == null ? color.withValues(alpha: 0.45) : color,
        ),
      );
    } else {
      button = FilledButton(
        onPressed: effectiveOnPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withValues(alpha: 0.5),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
          shape: RoundedRectangleBorder(borderRadius: _borderRadiusObj),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          textStyle: textStyle,
        ),
        child: _buildChild(Colors.white),
      );
    }

    if (fullWidth) return SizedBox(width: double.infinity, height: _height, child: button);
    return SizedBox(height: _height, child: button);
  }
}
