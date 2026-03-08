import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

// ================================================================
// CustomCalendar
//
// Uso:
//   CustomCalendar(
//     events: {
//       DateTime(2026, 11, 14): ['evento'],
//       DateTime(2026, 11, 21): ['pendente'],
//     },
//     onDaySelected: (selected, deselected) { ... },
//     onPageChanged: (firstDayOfPeriod) { ... },
//   )
// ================================================================
class CustomCalendar extends StatefulWidget {
  /// Dias marcados com bolinha. O valor da lista pode ser qualquer coisa —
  /// só importa que não esteja vazia para mostrar o indicador.
  final Map<DateTime, List<dynamic>> events;

  /// Chamado quando o usuário toca num dia.
  /// [selected] = dia tocado. [deselected] = dia anterior (pode ser null).
  final void Function(DateTime selected, DateTime? deselected)? onDaySelected;

  /// Chamado quando o usuário navega para outro mês ou semana.
  /// Recebe o primeiro dia visível do novo período.
  final void Function(DateTime firstDayOfPeriod)? onPageChanged;

  /// Chamado quando o intervalo visível muda — tanto por navegação
  /// de página quanto por troca de formato (semana ↔ mês).
  /// Recebe o primeiro e o último dia visíveis no calendário.
  final void Function(DateTime first, DateTime last)? onRangeChanged;

  const CustomCalendar({
    super.key,
    this.events = const {},
    this.onDaySelected,
    this.onPageChanged,
    this.onRangeChanged,
  });

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  CalendarFormat _format = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  bool _hasEvent(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return (widget.events[key]?.isNotEmpty) ?? false;
  }

  static const _monthNames = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  String _formatMonthYear(DateTime day) {
    final name = _monthNames[day.month - 1];
    return '${name[0].toUpperCase()}${name.substring(1)} de ${day.year}';
  }

  void _notifyRange(DateTime focused, CalendarFormat format) {
    if (widget.onRangeChanged == null) return;

    final DateTime first;
    final DateTime last;

    if (format == CalendarFormat.month) {
      first = DateTime(focused.year, focused.month, 1);
      last = DateTime(focused.year, focused.month + 1, 0); // último dia do mês
    } else {
      // Semana começa no domingo
      final weekday = focused.weekday % 7; // dom=0, seg=1, ..., sáb=6
      first = focused.subtract(Duration(days: weekday));
      last = first.add(const Duration(days: 6));
    }

    widget.onRangeChanged!(
      DateTime(first.year, first.month, first.day),
      DateTime(last.year, last.month, last.day),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isMonth = _format == CalendarFormat.month;

    return Stack(
      children: [
        // Card visível apenas no modo mensal
        if (isMonth)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: colorScheme.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),

        // Calendário
        ClipRRect(
          borderRadius: isMonth ? BorderRadius.circular(28) : BorderRadius.zero,
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            locale: 'pt_BR',
            calendarFormat: _format,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            availableGestures: AvailableGestures.horizontalSwipe,
            availableCalendarFormats: const {
              CalendarFormat.month: 'Mês',
              CalendarFormat.week: 'Semana',
            },
            rowHeight: isMonth ? 48 : 76,

            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

            onDaySelected: (selected, focused) {
              final previous = _selectedDay;
              setState(() {
                // Toque no mesmo dia = desseleciona
                _selectedDay = isSameDay(selected, _selectedDay)
                    ? null
                    : selected;
                _focusedDay = focused;
              });
              widget.onDaySelected?.call(
                selected,
                isSameDay(selected, previous) ? previous : previous,
              );
            },

            onFormatChanged: (format) {
              setState(() => _format = format);
              _notifyRange(_focusedDay, format);
            },

            onPageChanged: (focused) {
              _focusedDay = focused;
              widget.onPageChanged?.call(focused);
              _notifyRange(focused, _format);
            },

            // ── Cabeçalho customizado ──────────────────────────────
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              leftChevronVisible: false,
              rightChevronVisible: false,
              titleCentered: false,
              headerPadding: EdgeInsets.zero,
              decoration: BoxDecoration(color: Colors.transparent),
            ),

            // ── Labels dos dias da semana ─────────────────────────
            daysOfWeekHeight: 28,
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: textTheme.labelSmall!.copyWith(letterSpacing: 0.5),
              weekendStyle: textTheme.labelSmall!.copyWith(
                color: Colors.red[300],
                letterSpacing: 0.5,
              ),
            ),

            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              cellMargin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            ),

            calendarBuilders: CalendarBuilders(
              headerTitleBuilder: (context, day) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatMonthYear(day), style: textTheme.titleSmall),
                    GestureDetector(
                      onTap: () {
                        final next = _format == CalendarFormat.month
                            ? CalendarFormat.week
                            : CalendarFormat.month;
                        setState(() => _format = next);
                        _notifyRange(_focusedDay, next);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),

                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isMonth
                                  ? Icons.view_week_rounded
                                  : Icons.calendar_month_rounded,
                              size: 13,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              isMonth ? 'Ver semana' : 'Ver mês',
                              style: textTheme.labelSmall!.copyWith(
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              defaultBuilder: (context, day, _) => isMonth
                  ? _MonthDayCell(day: day, hasEvent: _hasEvent(day))
                  : _WeekDayChip(day: day, hasEvent: _hasEvent(day)),

              todayBuilder: (context, day, _) => isMonth
                  ? _MonthDayCell(
                      day: day,
                      isToday: true,
                      hasEvent: _hasEvent(day),
                    )
                  : _WeekDayChip(
                      day: day,
                      isToday: true,
                      hasEvent: _hasEvent(day),
                    ),

              selectedBuilder: (context, day, _) => isMonth
                  ? _MonthDayCell(
                      day: day,
                      isSelected: true,
                      isToday: isSameDay(day, DateTime.now()),
                      hasEvent: _hasEvent(day),
                    )
                  : _WeekDayChip(
                      day: day,
                      isSelected: true,
                      isToday: isSameDay(day, DateTime.now()),
                      hasEvent: _hasEvent(day),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

// ================================================================
// Célula mensal
// ================================================================
class _MonthDayCell extends StatelessWidget {
  final DateTime day;
  final bool isSelected;
  final bool isToday;
  final bool hasEvent;

  const _MonthDayCell({
    required this.day,
    this.isSelected = false,
    this.isToday = false,
    this.hasEvent = false,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SizedBox(
        width: 36,
        height: 44,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? primary : Colors.transparent,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: primary.withOpacity(0.28),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isSelected && hasEvent)
                    Positioned(
                      top: 1,
                      right: 1,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: secondary,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  Text(
                    '${day.day}',
                    style: textTheme.labelMedium!.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                ],
              ),
            ),

            if (hasEvent && !isSelected)
              Positioned(
                bottom: 0,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// Chip semanal
// ================================================================
class _WeekDayChip extends StatelessWidget {
  final DateTime day;
  final bool isSelected;
  final bool isToday;
  final bool hasEvent;

  const _WeekDayChip({
    required this.day,
    this.isSelected = false,
    this.isToday = false,
    this.hasEvent = false,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? primary : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? primary.withOpacity(0.8)
              : Theme.of(context).colorScheme.outlineVariant,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? primary.withOpacity(0.28)
                : Colors.black.withOpacity(0.04),
            blurRadius: isSelected ? 10 : 4,
            offset: Offset(0, isSelected ? 4 : 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (hasEvent)
            Positioned(
              top: 5,
              right: 5,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? secondary : primary,
                ),
              ),
            ),
          Center(
            child: Text(
              '${day.day}',
              style: textTheme.titleMedium!.copyWith(
                color: isSelected ? Colors.white : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
