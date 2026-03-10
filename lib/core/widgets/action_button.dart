import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Schema de cor do botão.
enum ActionButtonSchema {
  primary,
  secondary,
  /// Verde suave — confirmação, disponibilidade positiva.
  success,
  /// Vermelho suave — ação destrutiva, indisponibilidade.
  danger,
  /// Cinza neutro — ações secundárias discretas (ex.: "Desfazer").
  ghost,
}

/// Tamanho pré-definido do botão.
enum ActionButtonSize {
  /// altura 52 • fontSize 14 • iconSize 18 (padrão)
  md,
  /// altura 40 • fontSize 13 • iconSize 16
  sm,
  /// altura 32 • fontSize 11 • iconSize 13
  xs,
}

/// Botão de ação reutilizável que encapsula:
/// - variante **filled** (padrão) ou **outlined**
/// - estado de **loading** com spinner automático
/// - suporte a **ícone** opcional à esquerda do label
/// - schemas: **primary**, **secondary**, **success**, **danger**, **ghost**
/// - tamanhos pré-definidos via [ActionButtonSize]
///
/// Exemplo — filled success com loading:
/// ```dart
/// ActionButton(
///   label: 'Disponível',
///   schema: ActionButtonSchema.success,
///   icon: Icons.check_rounded,
///   isLoading: _isLoading,
///   onPressed: _submit,
/// )
/// ```
///
/// Exemplo — outlined ghost pequeno:
/// ```dart
/// ActionButton(
///   label: 'Desfazer',
///   outlined: true,
///   size: ActionButtonSize.xs,
///   schema: ActionButtonSchema.ghost,
///   fullWidth: false,
///   onPressed: _undo,
/// )
/// ```
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.outlined = false,
    this.icon,
    this.schema = ActionButtonSchema.primary,
    this.size = ActionButtonSize.md,
    this.fullWidth = true,
    // Quando passados explicitamente, sobrepõem os valores do [size].
    this.height,
    this.borderRadius,
  });

  /// Texto exibido no botão.
  final String label;

  /// Callback chamado ao pressionar. Se `null`, o botão fica desabilitado.
  final VoidCallback? onPressed;

  /// Exibe um [CircularProgressIndicator] e desabilita o botão quando `true`.
  final bool isLoading;

  /// Quando `true`, renderiza como botão outlined; caso contrário, filled.
  final bool outlined;

  /// Ícone opcional exibido antes do [label].
  final IconData? icon;

  /// Esquema de cores.
  final ActionButtonSchema schema;

  /// Tamanho pré-definido. Pode ser sobreposto por [height] e [borderRadius].
  final ActionButtonSize size;

  /// Quando `true`, o botão ocupa a largura máxima disponível.
  final bool fullWidth;

  /// Altura fixa. Se `null`, usa o valor de [size].
  final double? height;

  /// Raio de arredondamento. Se `null`, usa o valor de [size].
  final double? borderRadius;

  // ── tamanhos ──────────────────────────────────────────────────────────────

  double get _height => height ?? switch (size) {
    ActionButtonSize.md => 52,
    ActionButtonSize.sm => 40,
    ActionButtonSize.xs => 32,
  };

  double get _borderRadiusValue => borderRadius ?? switch (size) {
    ActionButtonSize.md => 16,
    ActionButtonSize.sm => 12,
    ActionButtonSize.xs => 8,
  };

  double get _fontSize => switch (size) {
    ActionButtonSize.md => 14,
    ActionButtonSize.sm => 13,
    ActionButtonSize.xs => 11,
  };

  double get _iconSize => switch (size) {
    ActionButtonSize.md => 18,
    ActionButtonSize.sm => 16,
    ActionButtonSize.xs => 13,
  };

  double get _iconSpacing => switch (size) {
    ActionButtonSize.md => 8,
    ActionButtonSize.sm => 6,
    ActionButtonSize.xs => 4,
  };

  double get _spinnerSize => switch (size) {
    ActionButtonSize.md => 20,
    ActionButtonSize.sm => 17,
    ActionButtonSize.xs => 14,
  };

  // ── cores ─────────────────────────────────────────────────────────────────

  /// Cor primária do schema (borda, ícone e texto no outlined; fundo no filled).
  Color get _schemaColor => switch (schema) {
    ActionButtonSchema.primary   => AppTheme.primaryColor,
    ActionButtonSchema.secondary => AppTheme.secondaryColor,
    ActionButtonSchema.success   => const Color(0xFF059669),
    ActionButtonSchema.danger    => const Color(0xFFDC2626),
    ActionButtonSchema.ghost     => const Color(0xFF64748B),
  };

  /// Cor de fundo suave usada no outlined (tint leve).
  Color get _schemaTint => switch (schema) {
    ActionButtonSchema.primary   => AppTheme.primaryColor.withValues(alpha: 0.06),
    ActionButtonSchema.secondary => AppTheme.secondaryColor.withValues(alpha: 0.06),
    ActionButtonSchema.success   => const Color(0xFFECFDF5),
    ActionButtonSchema.danger    => const Color(0xFFFEF2F2),
    ActionButtonSchema.ghost     => const Color(0xFFF8FAFC),
  };

  /// Cor da borda no outlined.
  Color get _schemaBorder => switch (schema) {
    ActionButtonSchema.primary   => AppTheme.primaryColor.withValues(alpha: 0.5),
    ActionButtonSchema.secondary => AppTheme.secondaryColor.withValues(alpha: 0.5),
    ActionButtonSchema.success   => const Color(0xFFD1FAE5),
    ActionButtonSchema.danger    => const Color(0xFFFECACA),
    ActionButtonSchema.ghost     => const Color(0xFFE2E8F0),
  };

  BorderRadius get _borderRadiusObj => BorderRadius.circular(_borderRadiusValue);

  // ── child ─────────────────────────────────────────────────────────────────

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

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final color = _schemaColor;
    final effectiveOnPressed = isLoading ? null : onPressed;

    final textStyle = TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600,
      fontSize: _fontSize,
    );

    Widget button;

    if (outlined) {
      button = OutlinedButton(
        onPressed: effectiveOnPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          backgroundColor: _schemaTint,
          disabledForegroundColor: color.withValues(alpha: 0.45),
          disabledBackgroundColor: _schemaTint,
          side: BorderSide(color: _schemaBorder, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: _borderRadiusObj),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          textStyle: textStyle,
        ),
        child: _buildChild(effectiveOnPressed == null ? color.withValues(alpha: 0.45) : color),
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

    if (fullWidth) {
      return SizedBox(width: double.infinity, height: _height, child: button);
    }

    return SizedBox(height: _height, child: button);
  }
}
