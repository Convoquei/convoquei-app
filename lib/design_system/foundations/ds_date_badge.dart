// Tile de data compacta: abreviação do dia da semana + número do dia.
// DSDateBadge(date: event.startTime, color: context.colors.success)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/ds_context_extensions.dart';
import '../tokens/ds_radius.dart';

class DSDateBadge extends StatelessWidget {
  final DateTime date;

  /// Cor do texto e da borda. Padrão: context.colors.primary.
  final Color? color;

  const DSDateBadge({super.key, required this.date, this.color});

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? context.colors.primary;

    String dayName;
    try {
      dayName = DateFormat('EEE', 'pt_BR').format(date).toUpperCase();
    } catch (_) {
      dayName = DateFormat('EEE').format(date).toUpperCase();
    }

    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.12),
        borderRadius: DSRadius.allMd,
        border: Border.all(color: effectiveColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dayName,
            style: context.textStyles.labelSmall.copyWith(
              color: effectiveColor,
              fontSize: 9,
              letterSpacing: 0.8,
            ),
          ),
          Text(
            date.day.toString(),
            style: context.textStyles.displayMedium.copyWith(
              color: effectiveColor,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
