import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_availability_status.dart';
import 'package:flutter/material.dart';

/// Seção de chips para filtrar por status de disponibilidade do participante.
class AvailabilityStatusFilterSection extends StatefulWidget {
  final List<OrganizationEventMembershipAvailabilityStatus>? selected;
  final ValueChanged<List<OrganizationEventMembershipAvailabilityStatus>?> onChanged;

  const AvailabilityStatusFilterSection({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<AvailabilityStatusFilterSection> createState() =>
      _AvailabilityStatusFilterSectionState();
}

class _AvailabilityStatusFilterSectionState
    extends State<AvailabilityStatusFilterSection> {
  late Set<OrganizationEventMembershipAvailabilityStatus> _selected;

  static const _options =
      <OrganizationEventMembershipAvailabilityStatus, String>{
    OrganizationEventMembershipAvailabilityStatus.notAnswered: 'Não Respondido',
    OrganizationEventMembershipAvailabilityStatus.available:   'Disponível',
    OrganizationEventMembershipAvailabilityStatus.unavailable: 'Indisponível',
  };

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selected ?? []);
  }

  void _toggle(OrganizationEventMembershipAvailabilityStatus status) {
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
    return DSFilterSection(
      title: 'Disponibilidade',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _options.entries.map((e) {
          return DSFilterChip(
            label: e.value,
            selected: _selected.contains(e.key),
            onSelected: (_) => _toggle(e.key),
          );
        }).toList(),
      ),
    );
  }
}
