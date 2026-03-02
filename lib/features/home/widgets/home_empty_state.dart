import 'package:convoquei_app/core/widgets/action_card.dart';
import 'package:convoquei_app/core/widgets/label_divider.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class HomeEmptyState extends StatelessWidget {
  final VoidCallback? onJoinWithCode;
  final VoidCallback? onCreateOrganization;

  const HomeEmptyState({
    super.key,
    this.onJoinWithCode,
    this.onCreateOrganization,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.groups_rounded,
                      size: 52,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Bem-vindo ao Convoquei!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Você ainda não faz parte de nenhuma organização. O que você gostaria de fazer primeiro?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ActionCard(
                icon: Icons.confirmation_number_outlined,
                title: 'Tenho um convite',
                subtitle: 'Entrar com um código de acesso',
                onTap: onJoinWithCode,
                outlined: true,
              ),

              LabelDivider(label: "OU"),

              ActionCard(
                icon: Icons.add_circle_rounded,
                title: 'Criar Organização',
                subtitle: 'Cadastrar minha equipe agora',
                onTap: onCreateOrganization,
                outlined: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
