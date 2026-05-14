import 'package:convoquei_app/design_system/ds.dart';
import 'package:flutter/material.dart';

class DateRangeFilterSection extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final void Function(DateTime? start, DateTime? end) onChanged;

  const DateRangeFilterSection({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onChanged,
  });

  @override
  State<DateRangeFilterSection> createState() => _DateRangeFilterSectionState();
}

class _DateRangeFilterSectionState extends State<DateRangeFilterSection> {
  DateTime? _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    _start = widget.startDate;
    _end = widget.endDate;
  }

  Future<void> _pickRange() async {
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: (_start != null && _end != null)
          ? DateTimeRange(start: _start!, end: _end!)
          : null,
    );
    if (result == null) return;
    setState(() {
      _start = result.start;
      _end = result.end;
    });
    widget.onChanged(_start, _end);
  }

  void _clear() {
    setState(() {
      _start = null;
      _end = null;
    });
    widget.onChanged(null, null);
  }

  String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    final hasRange = _start != null && _end != null;
    return DSFilterSection(
      title: 'Período',
      child: InkWell(
        onTap: _pickRange,
        borderRadius: DSRadius.allMd,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.lg,
            vertical: DSSpacing.md,
          ),
          decoration: BoxDecoration(
            color: hasRange
                ? context.colors.primary.withValues(alpha: 0.06)
                : context.colors.surface,
            borderRadius: DSRadius.allMd,
            border: Border.all(
              color: hasRange ? context.colors.primary : context.colors.border,
            ),
          ),
          child: Row(
            children: [
              DSIcon(
                Icons.date_range_rounded,
                size: DSIconSize.sm,
                color: hasRange
                    ? context.colors.primary
                    : context.colors.textSecondary,
              ),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: Text(
                  hasRange
                      ? '${_fmt(_start!)}  →  ${_fmt(_end!)}'
                      : 'Selecionar período',
                  style: context.textStyles.labelMedium.copyWith(
                    color: hasRange
                        ? context.colors.primary
                        : context.colors.textSecondary,
                    fontWeight:
                        hasRange ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (hasRange)
                GestureDetector(
                  onTap: _clear,
                  child: DSIcon(
                    Icons.close_rounded,
                    size: DSIconSize.sm,
                    color: context.colors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
