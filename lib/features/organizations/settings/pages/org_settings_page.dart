import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/features/home/widgets/action_tile.dart';
import 'package:convoquei_app/features/organizations/members/pages/org_members_page.dart'
    show OrgMembersTab;
import 'package:convoquei_app/features/organizations/settings/pages/manage_roles_page.dart';
import 'package:convoquei_app/features/organizations/settings/widgets/organization_header_card.dart';
import 'package:convoquei_app/features/organizations/settings/widgets/section_buttons_organization_settings.dart';
import 'package:convoquei_app/features/organizations/settings/widgets/subscription_plan_card.dart';
import 'package:convoquei_app/features/organizations/shared/models/enums/organization_permission.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_model.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_my_member_profile_model.dart';
import 'package:convoquei_app/features/organizations/shared/providers/organization_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrgSettingsPage extends ConsumerWidget {
  final OrganizationModel organization;
  final void Function(OrgMembersTab)? onNavigateToMembersTab;

  const OrgSettingsPage({
    super.key,
    required this.organization,
    this.onNavigateToMembersTab,
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            settings: const RouteSettings(name: 'Gerenciar Papéis'),
                            builder: (context) => ManageRolesPage(
                              organization: organization,
                            ),
                          ),
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
                    //showBadge: true,
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
                    onTap: () =>
                        onNavigateToMembersTab?.call(OrgMembersTab.membros),
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
                    // teal
                    onTap: () =>
                        onNavigateToMembersTab?.call(OrgMembersTab.grupos),
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
                    //showBadge: true,
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
