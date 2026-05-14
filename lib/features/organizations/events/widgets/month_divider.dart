import 'package:convoquei_app/core/utils/date_locale_pt.dart';
import 'package:convoquei_app/design_system/ds.dart';
import 'package:flutter/material.dart';

/// Divisor de seção com nome do mês e linha separadora.
class MonthDivider extends StatelessWidget {
  final DateTime month;

  static const _months = DateLocalePt.monthNames;

  const MonthDivider({super.key, required this.month});

  @override
  Widget build(BuildContext context) {
    final name = _months[month.month - 1];
    final label =
        '${name[0].toUpperCase()}${name.substring(1)} ${month.year}';
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: context.textStyles.labelSmall?.copyWith(
            color: context.colors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Divider(height: 1, color: context.colors.border)),
      ],
    );
  }
}
