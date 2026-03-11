import 'package:convoquei_app/core/utils/date_locale_pt.dart';
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
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF94A3B8),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(child: Divider(height: 1, color: Color(0xFFE2E8F0))),
      ],
    );
  }
}
