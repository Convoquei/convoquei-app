import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ToggleTabs<T> extends StatelessWidget {
  final T selected;
  final ValueChanged<T> onChanged;
  final List<T> values;
  final String Function(T) labelBuilder;

  const ToggleTabs({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.values,
    required this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: values.map((value) {
          final selectedItem = value == selected;

          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selectedItem
                      ? const Color(0xFFEFF6FF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  labelBuilder(value),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight:
                    selectedItem ? FontWeight.w700 : FontWeight.w500,
                    color: selectedItem
                        ? AppTheme.primaryColor
                        : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}