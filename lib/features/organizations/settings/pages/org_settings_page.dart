import 'package:convoquei_app/app/router.dart';
import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/features/home/widgets/action_tile.dart';
import 'package:convoquei_app/features/organizations/settings/widgets/organization_header_card.dart';
import 'package:convoquei_app/features/organizations/settings/widgets/section_buttons_organization_settings.dart';
import 'package:convoquei_app/features/organizations/settings/widgets/subscription_plan_card.dart';
import 'package:convoquei_app/features/organizations/shared/models/enums/organization_permission.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_model.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_my_member_profile_model.dart';
import 'package:convoquei_app/features/organizations/shared/providers/organization_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrgSettingsPage extends ConsumerWidget {
  final OrganizationModel organization;

  const OrgSettingsPage({
    super.key,
    required this.organization,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    OrganizationMyMemberProfile currentUser = ref
        .watch(currentUserMembershipOrganizationProvider(organization.id))
        .asData!
        .value;

    bool canPermissionInviteMembers = currentUser.hasPermission(
      OrganizationPermissionEnum.inviteMembers,
    );
    bool canPermissionManageRoles = currentUser.hasPermission(
      OrganizationPermissionEnum.owner,
    );
    bool canPermissionManageSubscription = currentUser.hasPermission(
      OrganizationPermissionEnum.owner,
    );
    bool canPermissionManageGroups = currentUser.hasPermission(
      OrganizationPermissionEnum.manageGroups,
    );
    bool canPermissionManageFunctions = currentUser.hasPermission(
      OrganizationPermissionEnum.manageFunctions,
    );

    final orgId = organization.id;

    return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              OrganizationHeaderCard(
                organization: organization,
                totalEvents: 1123,
                monthEvents: 223,
              ),

              const SizedBox(height: 24),

              SectionButtonsOrganizationSettings(
                title: "Membros",
                widgets: [
                  ActionTile(
                    title: 'Gerenciar Papéis',
                    description:
                        'Gerencie os papéis da organização (Admin, Líder)',
                    icon: Icons.shield_outlined,
                    iconColor: const Color(0xFF9333EA),
                    onTap: () {
                      if (canPermissionManageRoles) {
                        context.pushNamed(
                          AppRoutes.orgSettingsRoles,
                          pathParameters: {'orgId': orgId},
                        );
                      }
                    },
                    visible: canPermissionManageRoles,
                  ),
                  ActionTile(
                    title: 'Convites Pendentes',
                    description: 'Veja quem ainda não aceitou entrar',
                    icon: Icons.mail_outline_rounded,
                    iconColor: AppTheme.secondaryColor,
                    onTap: () {},
                    visible: canPermissionInviteMembers,
                  ),
                  ActionTile(
                    title: canPermissionInviteMembers
                        ? 'Gerenciar Membros'
                        : 'Membros',
                    description: canPermissionInviteMembers
                        ? 'Adicione ou remova membros da organização'
                        : 'Veja a lista de membros da organização',
                    icon: Icons.group_outlined,
                    onTap: () {
                      context.goNamed(
                        AppRoutes.orgTeam,
                        pathParameters: {'orgId': orgId},
                      );
                    },
                  ),
                  ActionTile(
                    title: canPermissionManageGroups
                        ? 'Gerenciar Grupos'
                        : 'Grupos',
                    description: canPermissionManageGroups
                        ? 'Crie e organize grupos para facilitar a gestão'
                        : 'Veja os grupos da organização',
                    icon: Icons.groups_outlined,
                    iconColor: const Color(0xFF0D9488),
                    onTap: () {
                      context.goNamed(
                        AppRoutes.orgTeam,
                        pathParameters: {'orgId': orgId},
                      );
                    },
                  ),
                  ActionTile(
                    title: 'Gerenciar Funções',
                    description:
                        'Crie e gerencie as funções dos membros da organização',
                    icon: Icons.music_note_outlined,
                    iconColor: const Color(0xFFEA580C),
                    onTap: () {
                      context.pushNamed(
                        AppRoutes.orgSettingsFunctions,
                        pathParameters: {'orgId': orgId},
                      );
                    },
                    visible: canPermissionManageFunctions,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              SectionButtonsOrganizationSettings(
                title: "EVENTOS",
                widgets: [
                  ActionTile(
                    title: 'Recorrências',
                    description: 'Crie padrões de eventos de forma automática',
                    icon: Icons.repeat_outlined,
                    iconColor: AppTheme.primaryColor,
                    onTap: () {},
                  ),
                  ActionTile(
                    title: 'Todos os Eventos',
                    description: 'Visualize e edite todo o histórico',
                    icon: Icons.event_outlined,
                    iconColor: AppTheme.primaryColor,
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 24),

              SectionButtonsOrganizationSettings(
                title: "ASSINATURA",
                widgets: [SubscriptionPlanCard()],
                visible: canPermissionManageSubscription,
              ),
            ],
          ),
        ),
      );
  }
}

