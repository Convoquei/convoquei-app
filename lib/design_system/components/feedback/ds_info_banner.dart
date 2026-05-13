// Banner informativo com dois níveis de texto (label + sublabel).
// Anteriormente: InfoBanner.
//
// Exemplo:
//   DSInfoBanner(
//     bgColor: context.colors.infoTint,
//     borderColor: context.colors.info,
//     icon: Icons.info_rounded,
//     iconColor: context.colors.info,
//     label: 'Atenção',
//     sublabel: 'Este evento já começou.',
//   )
import 'package:flutter/material.dart';

import '../../theme/ds_context_extensions.dart';
import '../../tokens/ds_spacing.dart';

class DSInfoBanner extends StatelessWidget {
  final Color bgColor;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String sublabel;
  final Color? labelColor;

  const DSInfoBanner({
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
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.sm + 2, vertical: DSSpacing.sm),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: DSSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: labelColor ?? context.colors.textPrimary,
                        fontSize: 11,
                      ),
                ),
                Text(
                  sublabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
