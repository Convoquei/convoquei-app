import 'package:convoquei_app/features/organizations/events/widgets/create_event_shared_widgets.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────────────────────────────────────

class CreateEventStep1Data {
  final String name;
  final String location;
  final String description;
  final DateTime? startAt;
  final DateTime? endAt;

  const CreateEventStep1Data({
    this.name = '',
    this.location = '',
    this.description = '',
    this.startAt,
    this.endAt,
  });

  bool get isValid =>
      name.trim().isNotEmpty &&
      location.trim().isNotEmpty &&
      startAt != null &&
      endAt != null;

  CreateEventStep1Data copyWith({
    String? name,
    String? location,
    String? description,
    DateTime? startAt,
    DateTime? endAt,
    bool clearStartAt = false,
    bool clearEndAt = false,
  }) {
    return CreateEventStep1Data(
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      startAt: clearStartAt ? null : startAt ?? this.startAt,
      endAt: clearEndAt ? null : endAt ?? this.endAt,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class CreateEventStep1BasicInfo extends StatefulWidget {
  final CreateEventStep1Data data;
  final ValueChanged<CreateEventStep1Data> onChanged;

  const CreateEventStep1BasicInfo({
    super.key,
    required this.data,
    required this.onChanged,
  });

  @override
  State<CreateEventStep1BasicInfo> createState() =>
      _CreateEventStep1BasicInfoState();
}

class _CreateEventStep1BasicInfoState
    extends State<CreateEventStep1BasicInfo> {
  late final TextEditingController _nameCtr;
  late final TextEditingController _locationCtr;
  late final TextEditingController _descCtr;

  @override
  void initState() {
    super.initState();
    _nameCtr = TextEditingController(text: widget.data.name);
    _locationCtr = TextEditingController(text: widget.data.location);
    _descCtr = TextEditingController(text: widget.data.description);
  }

  @override
  void dispose() {
    _nameCtr.dispose();
    _locationCtr.dispose();
    _descCtr.dispose();
    super.dispose();
  }

  void _notifyText() => widget.onChanged(
        widget.data.copyWith(
          name: _nameCtr.text,
          location: _locationCtr.text,
          description: _descCtr.text,
        ),
      );

  Future<void> _pickDateTime({required bool isStart}) async {
    final now = DateTime.now();
    // Earliest selectable moment: right now (no past dates).
    final todayStart = DateTime(now.year, now.month, now.day);

    // For end picker, first selectable day is the start day (or today).
    final firstDate = !isStart && widget.data.startAt != null
        ? DateTime(widget.data.startAt!.year, widget.data.startAt!.month,
            widget.data.startAt!.day)
        : todayStart;

    // Sensible initial value for the picker.
    DateTime initial;
    if (isStart) {
      initial = widget.data.startAt ?? DateTime(now.year, now.month, now.day, now.hour + 1);
    } else {
      // Default end = start + 1 hour, or now + 2 hours if start not set.
      initial = widget.data.endAt ??
          (widget.data.startAt != null
              ? widget.data.startAt!.add(const Duration(hours: 1))
              : DateTime(now.year, now.month, now.day, now.hour + 2));
    }

    // Clamp initial so it is never before firstDate.
    if (initial.isBefore(firstDate)) initial = firstDate;

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !mounted) return;

    // For the time picker: clamp initial time so past times on today are avoided.
    TimeOfDay initialTime = TimeOfDay.fromDateTime(initial);
    if (isStart) {
      final selectedDay =
          DateTime(date.year, date.month, date.day);
      final isToday = selectedDay.isAtSameMomentAs(todayStart);
      if (isToday) {
        // Ensure the default time is at least "now + 1 min" so user doesn't
        // accidentally pick a past time without noticing.
        final minTime = TimeOfDay(hour: now.hour, minute: now.minute);
        if (_timeToMinutes(initialTime) <= _timeToMinutes(minTime)) {
          initialTime = TimeOfDay(
              hour: (now.hour + 1) % 24, minute: now.minute);
        }
      }
    }

    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (time == null || !mounted) return;

    DateTime combined =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);

    // Guard: start must not be in the past.
    if (isStart && combined.isBefore(now)) {
      combined = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    }

    // Guard: end must not be before or equal to start.
    if (!isStart && widget.data.startAt != null &&
        !combined.isAfter(widget.data.startAt!)) {
      combined = widget.data.startAt!.add(const Duration(hours: 1));
    }

    if (isStart) {
      final needsEndPick = widget.data.endAt == null ||
          !widget.data.endAt!.isAfter(combined);
      widget.onChanged(widget.data.copyWith(startAt: combined));
      if (needsEndPick && mounted) {
        await _pickDateTime(isStart: false);
      }
    } else {
      widget.onChanged(widget.data.copyWith(endAt: combined));
    }
  }

  int _timeToMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StepCard(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FieldLabel(label: 'Nome do Evento *'),
                TextField(
                  controller: _nameCtr,
                  onChanged: (_) => _notifyText(),
                  decoration: const InputDecoration(
                    hintText: 'Digite o nome do evento',
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FieldLabel(label: 'Local *'),
                TextField(
                  controller: _locationCtr,
                  onChanged: (_) => _notifyText(),
                  decoration: const InputDecoration(
                    hintText: 'Digite o local do evento',
                    prefixIcon: Icon(Icons.location_on_rounded, size: 18),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FieldLabel(label: 'Descrição (Opcional)'),
                TextField(
                  controller: _descCtr,
                  onChanged: (_) => _notifyText(),
                  maxLines: 2,
                  minLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Digite a descrição do evento',
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        StepCard(
          children: [
            Text('Quando?', style: theme.titleSmall),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel(label: 'Início *'),
                      DateTimePickerButton(
                        value: widget.data.startAt,
                        onTap: () => _pickDateTime(isStart: true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FieldLabel(label: 'Fim *'),
                      DateTimePickerButton(
                        value: widget.data.endAt,
                        onTap: () => _pickDateTime(isStart: false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
