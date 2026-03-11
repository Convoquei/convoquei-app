import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/core/widgets/convoquei_loading_icon.dart';
import 'package:flutter/material.dart';

/// Widget de informação de carregamento: ícone animado + título + descrição.
///
/// Componente autônomo — pode ser usado standalone dentro de qualquer
/// superfície (overlay, modal, centro de tela) ou composto na [AppLoadingScreen].
///
/// Exemplo:
/// ```dart
/// AppLoadingInfo(
///   label: 'Carregando evento...',
///   description: 'Buscando detalhes e participantes',
/// )
/// ```
class AppLoadingInfo extends StatelessWidget {
  final String label;
  final String description;
  final double iconSize;

  const AppLoadingInfo({
    super.key,
    required this.label,
    required this.description,
    this.iconSize = 96,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConvoqueiLoadingIcon(size: iconSize),
        const SizedBox(height: 24),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }
}
