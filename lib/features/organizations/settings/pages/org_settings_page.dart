import 'package:convoquei_app/app/router.dart';
import 'package:convoquei_app/design_system/ds.dart';
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

  const OrgSettingsPage({super.key, required this.organization});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final OrganizationMyMemberProfile currentUser = ref
        .watch(currentUserMembershipOrganizationProvider(organization.id))
        .asData!
        .value;

    final canInviteMembers = currentUser.hasPermission(OrganizationPermissionEnum.inviteMembers);
    final canManageRoles = currentUser.hasPermission(OrganizationPermissionEnum.owner);
    final canManageSubscription = currentUser.hasPermission(OrganizationPermissionEnum.owner);
    final canManageGroups = currentUser.hasPermission(OrganizationPermissionEnum.manageGroups);
    final canManageFunctions = currentUser.hasPermission(OrganizationPermissionEnum.manageFunctions);

    final orgId = organization.id;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(DSSpacing.lg),
        child: Column(
          children: [
            OrganizationHeaderCard(
              organization: organization,
              totalEvents: 1123,
              monthEvents: 223,
            ),
            const SizedBox(height: DSSpacing.xl),
            SectionButtonsOrganizationSettings(
              title: 'Membros',
              widgets: [
                DSActionCard(
                  icon: Icons.shield_outlined,
                  title: 'Gerenciar Papéis',
                  subtitle: 'Gerencie os papéis da organização (Admin, Líder)',
                  outlined: true,
                  onTap: canManageRoles
                      ? () => context.pushNamed(AppRoutes.orgSettingsRoles, pathParameters: {'orgId': orgId})
                      : null,
                ),
                DSActionCard(
                  icon: Icons.mail_outline_rounded,
                  title: 'Convites Pendentes',
                  subtitle: 'Veja quem ainda não aceitou entrar',
                  outlined: true,
                  onTap: canInviteMembers ? () {} : null,
                ),
                DSActionCard(
                  icon: Icons.group_outlined,
                  title: canInviteMembers ? 'Gerenciar Membros' : 'Membros',
                  subtitle: canInviteMembers
                      ? 'Adicione ou remova membros da organização'
                      : 'Veja a lista de membros da organização',
                  outlined: true,
                  onTap: () => context.goNamed(AppRoutes.orgTeam, pathParameters: {'orgId': orgId}),
                ),
                DSActionCard(
                  icon: Icons.groups_outlined,
                  title: canManageGroups ? 'Gerenciar Grupos' : 'Grupos',
                  subtitle: canManageGroups
                      ? 'Crie e organize grupos para facilitar a gestão'
                      : 'Veja os grupos da organização',
                  outlined: true,
                  onTap: () => context.pushNamed(AppRoutes.orgSettingsGroups, pathParameters: {'orgId': orgId}),
                ),
                if (canManageFunctions)
                  DSActionCard(
                    icon: Icons.music_note_outlined,
                    title: 'Gerenciar Funções',
                    subtitle: 'Crie e gerencie as funções dos membros da organização',
                    outlined: true,
                    onTap: () => context.pushNamed(AppRoutes.orgSettingsFunctions, pathParameters: {'orgId': orgId}),
                  ),
              ],
            ),
            const SizedBox(height: DSSpacing.xl),
            SectionButtonsOrganizationSettings(
              title: 'EVENTOS',
              widgets: [
                DSActionCard(
                  icon: Icons.repeat_outlined,
                  title: 'Recorrências',
                  subtitle: 'Crie padrões de eventos de forma automática',
                  outlined: true,
                  onTap: () {},
                ),
                DSActionCard(
                  icon: Icons.event_outlined,
                  title: 'Todos os Eventos',
                  subtitle: 'Visualize e edite todo o histórico',
                  outlined: true,
                  onTap: () {},
                ),
              ],
            ),
            if (canManageSubscription) ...[
              const SizedBox(height: DSSpacing.xl),
              SectionButtonsOrganizationSettings(
                title: 'ASSINATURA',
                widgets: [SubscriptionPlanCard()],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
