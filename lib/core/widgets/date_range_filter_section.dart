import 'package:convoquei_app/core/widgets/filter_button.dart';
import 'package:flutter/material.dart';

/// Seção de filtro de período para uso dentro de um [FilterButton].
///
/// Abre o [showDateRangePicker] nativo do Flutter ao ser tocado e
/// exibe as datas selecionadas formatadas. Um botão de limpar aparece
/// quando há um intervalo ativo.
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
    _end   = widget.endDate;
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
      _end   = result.end;
    });
    widget.onChanged(_start, _end);
  }

  void _clear() {
    setState(() {
      _start = null;
      _end   = null;
    });
    widget.onChanged(null, null);
  }

  String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    final hasRange = _start != null && _end != null;
    return FilterSection(
      title: 'Período',
      child: InkWell(
        onTap: _pickRange,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: hasRange
                ? const Color(0xFF1D4ED8).withValues(alpha: 0.06)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasRange
                  ? const Color(0xFF1D4ED8)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.date_range_rounded,
                size: 18,
                color: hasRange
                    ? const Color(0xFF1D4ED8)
                    : const Color(0xFF64748B),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hasRange
                      ? '${_fmt(_start!)}  →  ${_fmt(_end!)}'
                      : 'Selecionar período',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: hasRange
                        ? const Color(0xFF1D4ED8)
                        : const Color(0xFF64748B),
                    fontWeight:
                        hasRange ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (hasRange)
                GestureDetector(
                  onTap: _clear,
                  child: const Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
