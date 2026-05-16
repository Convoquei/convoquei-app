import 'package:convoquei_app/design_system/ds.dart';
import 'package:flutter/material.dart';

class NoGroupsEmptyState extends StatelessWidget {
  const NoGroupsEmptyState({super.key, this.onCreateGroup});

  final VoidCallback? onCreateGroup;

  @override
  Widget build(BuildContext context) {
    return DSEmptyState(
      icon: Icons.groups_outlined,
      title: 'Nenhum grupo criado ainda',
      description: 'Grupos ajudam a organizar membros para escalar e convocar mais rápido.',
      actionLabel: onCreateGroup != null ? 'Criar primeiro grupo' : null,
      onAction: onCreateGroup,
    );
  }
}
