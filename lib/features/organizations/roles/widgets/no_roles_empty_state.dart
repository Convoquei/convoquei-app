import 'package:convoquei_app/design_system/ds.dart';
import 'package:flutter/material.dart';

class NoRolesEmptyState extends StatelessWidget {
  const NoRolesEmptyState({super.key, this.onCreateRole});

  final VoidCallback? onCreateRole;

  @override
  Widget build(BuildContext context) {
    return DSEmptyState(
      icon: Icons.shield_outlined,
      title: 'O que são Papéis?',
      description: 'Em vez de dar permissões pessoa por pessoa, crie papéis como "Administrador". Defina os acessos e atribua rapidamente à sua equipe.',
      actionLabel: onCreateRole != null ? 'Criar o primeiro papel' : null,
      onAction: onCreateRole,
    );
  }
}
