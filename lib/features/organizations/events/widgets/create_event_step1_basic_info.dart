import 'package:convoquei_app/design_system/ds.dart';
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
  late final TextEditingController _startCtr;
  late final TextEditingController _endCtr;

  static String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$day/$month  $hour:$min';
  }

  @override
  void initState() {
    super.initState();
    _nameCtr = TextEditingController(text: widget.data.name);
    _locationCtr = TextEditingController(text: widget.data.location);
    _descCtr = TextEditingController(text: widget.data.description);
    _startCtr = TextEditingController(
      text: widget.data.startAt != null ? _formatDateTime(widget.data.startAt!) : '',
    );
    _endCtr = TextEditingController(
      text: widget.data.endAt != null ? _formatDateTime(widget.data.endAt!) : '',
    );
  }

  @override
  void didUpdateWidget(CreateEventStep1BasicInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.startAt != widget.data.startAt) {
      _startCtr.text = widget.data.startAt != null ? _formatDateTime(widget.data.startAt!) : '';
    }
    if (oldWidget.data.endAt != widget.data.endAt) {
      _endCtr.text = widget.data.endAt != null ? _formatDateTime(widget.data.endAt!) : '';
    }
  }

  @override
  void dispose() {
    _nameCtr.dispose();
    _locationCtr.dispose();
    _descCtr.dispose();
    _startCtr.dispose();
    _endCtr.dispose();
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
    final todayStart = DateTime(now.year, now.month, now.day);

    final firstDate = !isStart && widget.data.startAt != null
        ? DateTime(widget.data.startAt!.year, widget.data.startAt!.month,
            widget.data.startAt!.day)
        : todayStart;

    DateTime initial;
    if (isStart) {
      initial = widget.data.startAt ?? DateTime(now.year, now.month, now.day, now.hour + 1);
    } else {
      initial = widget.data.endAt ??
          (widget.data.startAt != null
              ? widget.data.startAt!.add(const Duration(hours: 1))
              : DateTime(now.year, now.month, now.day, now.hour + 2));
    }

    if (initial.isBefore(firstDate)) initial = firstDate;

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 5),
      helpText: isStart ? 'DATA DE INÍCIO' : 'DATA DE FIM',
      confirmText: 'PRÓXIMO',
    );
    if (date == null || !mounted) return;

    TimeOfDay initialTime = TimeOfDay.fromDateTime(initial);
    if (isStart) {
      final selectedDay = DateTime(date.year, date.month, date.day);
      final isToday = selectedDay.isAtSameMomentAs(todayStart);
      if (isToday) {
        final minTime = TimeOfDay(hour: now.hour, minute: now.minute);
        if (_timeToMinutes(initialTime) <= _timeToMinutes(minTime)) {
          initialTime = TimeOfDay(hour: (now.hour + 1) % 24, minute: now.minute);
        }
      }
    }

    TimeOfDay? time;
    while (true) {
      time = await showTimePicker(
        context: context,
        initialTime: initialTime,
        helpText: isStart ? 'HORÁRIO DE INÍCIO' : 'HORÁRIO DE FIM',
        confirmText: 'CONFIRMAR',
      );
      if (time == null || !mounted) return;

      final combined = DateTime(date.year, date.month, date.day, time.hour, time.minute);

      if (isStart && combined.isBefore(now)) {
        initialTime = TimeOfDay(hour: (now.hour + 1) % 24, minute: now.minute);
        _showTimeError('Selecione um horário a partir de agora.');
        continue;
      }

      if (!isStart && widget.data.startAt != null && !combined.isAfter(widget.data.startAt!)) {
        final start = widget.data.startAt!;
        initialTime = TimeOfDay(hour: (start.hour + 1) % 24, minute: start.minute);
        _showTimeError(
          'O horário de fim deve ser após '
          '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}.',
        );
        continue;
      }

      if (isStart) {
        widget.onChanged(widget.data.copyWith(startAt: combined));
      } else {
        widget.onChanged(widget.data.copyWith(endAt: combined));
      }
      break;
    }
  }

  void _showTimeError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.colors.danger,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  int _timeToMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  @override
  Widget build(BuildContext context) {
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
            Text('Quando?', style: context.textStyles.titleSmall),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FieldLabel(label: 'Início *'),
                TextFormField(
                  controller: _startCtr,
                  readOnly: true,
                  showCursor: false,
                  onTap: () => _pickDateTime(isStart: true),
                  decoration: const InputDecoration(
                    hintText: 'Toque para selecionar',
                    prefixIcon: Icon(Icons.play_circle_outline_rounded, size: 20),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FieldLabel(label: 'Fim *'),
                TextFormField(
                  controller: _endCtr,
                  readOnly: true,
                  showCursor: false,
                  onTap: () => _pickDateTime(isStart: false),
                  decoration: const InputDecoration(
                    hintText: 'Toque para selecionar',
                    prefixIcon: Icon(Icons.stop_circle_outlined, size: 20),
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
