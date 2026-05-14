import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/events/models/enums/organization_event_membership_status.dart';
import 'package:flutter/material.dart';

/// Seção de chips para filtrar por status da escala do membro.
class MembershipStatusFilterSection extends StatefulWidget {
  final List<OrganizationEventMembershipStatus>? selected;
  final ValueChanged<List<OrganizationEventMembershipStatus>?> onChanged;

  const MembershipStatusFilterSection({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<MembershipStatusFilterSection> createState() =>
      _MembershipStatusFilterSectionState();
}

class _MembershipStatusFilterSectionState
    extends State<MembershipStatusFilterSection> {
  late Set<OrganizationEventMembershipStatus> _selected;

  static const _options = <OrganizationEventMembershipStatus, String>{
    OrganizationEventMembershipStatus.pending:            'Aguardando Resposta',
    OrganizationEventMembershipStatus.awaitingAssignment: 'Aguardando Escalação',
    OrganizationEventMembershipStatus.awaitingDraw:       'Aguardando Sorteio',
    OrganizationEventMembershipStatus.assigned:           'Escalado',
    OrganizationEventMembershipStatus.notAssigned:        'Não Escalado',
  };

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selected ?? []);
  }

  void _toggle(OrganizationEventMembershipStatus status) {
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
      title: 'Status da Escala',
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
