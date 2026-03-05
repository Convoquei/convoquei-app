import 'package:flutter/material.dart';

class OrgTab {
  final String label;
  final IconData icon;

  const OrgTab({required this.label, required this.icon});
}

const List<OrgTab> kOrgTabs = [
  OrgTab(label: 'Início', icon: Icons.home_rounded),
  OrgTab(label: 'Eventos', icon: Icons.event_rounded),
  OrgTab(label: 'Escalas', icon: Icons.assignment_rounded),
  OrgTab(label: 'Equipe', icon: Icons.group_rounded),
];
