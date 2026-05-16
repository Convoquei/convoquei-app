import 'package:convoquei_app/design_system/ds.dart';
import 'package:flutter/material.dart';

class NoFunctionsEmptyState extends StatelessWidget {
  const NoFunctionsEmptyState({super.key, this.onCreateFunction});

  final VoidCallback? onCreateFunction;

  @override
  Widget build(BuildContext context) {
    return DSEmptyState(
      icon: Icons.music_note_outlined,
      title: 'Nenhuma função criada ainda',
      description: 'Funções ajudam a identificar a atividade de cada membro dentro da organização.',
      actionLabel: onCreateFunction != null ? 'Criar primeira função' : null,
      onAction: onCreateFunction,
    );
  }
}
