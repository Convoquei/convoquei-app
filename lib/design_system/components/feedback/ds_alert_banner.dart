// Banner de alerta com ícone e texto. Anteriormente: AlertBanner.
//
// Exemplo:
//   DSAlertBanner(text: 'Evento cancelado.', icon: Icons.warning_rounded, color: context.colors.danger)
import 'package:flutter/material.dart';

import '../../tokens/ds_radius.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';

class DSAlertBanner extends StatelessWidget {
  const DSAlertBanner({
    super.key,
    required this.text,
    required this.icon,
    required this.color,
  });

  final String text;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: DSRadius.allLg,
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: DSSpacing.md),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: DSTypography.bodyFamily,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: color.withValues(alpha: 0.85),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
