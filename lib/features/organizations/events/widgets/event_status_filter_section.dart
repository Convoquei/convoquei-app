import 'package:convoquei_app/core/widgets/filter_button.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_status.dart';
import 'package:flutter/material.dart';

/// Seção de chips para filtrar por status do evento.
class EventStatusFilterSection extends StatefulWidget {
  final List<OrganizationEventStatus>? selected;
  final ValueChanged<List<OrganizationEventStatus>?> onChanged;

  const EventStatusFilterSection({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<EventStatusFilterSection> createState() =>
      _EventStatusFilterSectionState();
}

class _EventStatusFilterSectionState extends State<EventStatusFilterSection> {
  late Set<OrganizationEventStatus> _selected;

  static const _options = <OrganizationEventStatus, String>{
    OrganizationEventStatus.scheduled:  'Agendado',
    OrganizationEventStatus.inProgress: 'Em Andamento',
    OrganizationEventStatus.completed:  'Concluído',
    OrganizationEventStatus.canceled:   'Cancelado',
  };

  @override
  void initState() {
    super.initState();
    _selected = Set.from(
      widget.selected ??
          [OrganizationEventStatus.scheduled, OrganizationEventStatus.inProgress],
    );
  }

  void _toggle(OrganizationEventStatus status) {
    setState(() {
      if (_selected.contains(status)) {
        _selected.remove(status);
      } else {
        _selected.add(status);
      }
    });
    widget.onChanged(_selected.isEmpty ? null : _selected.toList());
  }

  @override
  Widget build(BuildContext context) {
    return FilterSection(
      title: 'Status do Evento',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _options.entries.map((e) {
          return FilterOptionChip(
            label: e.value,
            selected: _selected.contains(e.key),
            onSelected: (_) => _toggle(e.key),
          );
        }).toList(),
      ),
    );
  }
}
