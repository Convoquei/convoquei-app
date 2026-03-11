import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Banner informativo com ícone, label em negrito e sublabel menor.
///
/// Diferente do [AlertBanner] (que exibe apenas um único texto),
/// [InfoBanner] estrutura a mensagem em dois níveis (label + sublabel)
/// e aceita cores de fundo/borda completamente customizáveis.
class InfoBanner extends StatelessWidget {
  final Color bgColor;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String sublabel;
  final Color? labelColor;

  const InfoBanner({
    super.key,
    required this.bgColor,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.sublabel,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: labelColor ?? AppTheme.textPrimary,
                        fontSize: 11,
                      ),
                ),
                Text(
                  sublabel,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
