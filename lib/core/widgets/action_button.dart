import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Schema de cor do botão.
enum ActionButtonSchema { primary, secondary }

/// Botão de ação reutilizável que encapsula:
/// - variante **filled** (padrão) ou **outlined**
/// - estado de **loading** com spinner automático
/// - suporte a **ícone** opcional à esquerda do label
/// - esquema de cores **primary** / **secondary** baseado em [AppTheme]
///
/// Exemplo — filled primário com loading:
/// ```dart
/// ActionButton(
///   label: 'Entrar',
///   isLoading: _isLoading,
///   onPressed: _submit,
/// )
/// ```
///
/// Exemplo — outlined secundário com ícone:
/// ```dart
/// ActionButton(
///   label: 'Cancelar',
///   outlined: true,
///   icon: Icons.close,
///   schema: ActionButtonSchema.secondary,
///   onPressed: _cancel,
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
    this.fullWidth = true,
    this.height = 52,
    this.borderRadius = 16,
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

  /// Esquema de cores: [ActionButtonSchema.primary] usa [AppTheme.primaryColor],
  /// [ActionButtonSchema.secondary] usa [AppTheme.secondaryColor].
  final ActionButtonSchema schema;

  /// Quando `true`, o botão ocupa a largura máxima disponível.
  final bool fullWidth;

  /// Altura fixa do botão.
  final double height;

  /// Raio de arredondamento das bordas.
  final double borderRadius;

  // ── helpers ────────────────────────────────────────────────────────────────

  Color get _schemaColor => schema == ActionButtonSchema.primary
      ? AppTheme.primaryColor
      : AppTheme.secondaryColor;

  BorderRadius get _borderRadius => BorderRadius.circular(borderRadius);

  Widget _buildChild(Color foreground) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: foreground,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: 8),
          Text(label),
        ],
      );
    }

    return Text(label);
  }

  @override
  Widget build(BuildContext context) {
    final color = _schemaColor;
    final effectiveOnPressed = isLoading ? null : onPressed;

    Widget button;

    if (outlined) {
      button = OutlinedButton(
        onPressed: effectiveOnPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: _borderRadius),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        child: _buildChild(color),
      );
    } else {
      button = FilledButton(
        onPressed: effectiveOnPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withValues(alpha: 0.6),
          disabledForegroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: _borderRadius),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        child: _buildChild(Colors.white),
      );
    }

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: button,
      );
    }

    return SizedBox(height: height, child: button);
  }
}


