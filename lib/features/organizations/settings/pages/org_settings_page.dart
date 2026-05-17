import 'package:convoquei_app/app/router.dart';
import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/settings/widgets/organization_header_card.dart';
import 'package:convoquei_app/features/organizations/settings/widgets/subscription_plan_card.dart';
import 'package:convoquei_app/features/organizations/shared/models/enums/organization_permission.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_my_member_profile_model.dart';
import 'package:convoquei_app/features/organizations/shared/providers/current_org_provider.dart';
import 'package:convoquei_app/features/organizations/shared/providers/organization_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrgSettingsPage extends ConsumerWidget {
  const OrgSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organization = ref.watch(currentOrgProvider);

    final OrganizationMyMemberProfile currentUser = ref
        .watch(currentUserMembershipOrganizationProvider(organization.id))
        .asData!
        .value;

    final canInviteMembers = currentUser.hasPermission(
      OrganizationPermissionEnum.inviteMembers,
    );
    final canManageRoles = currentUser.hasPermission(
      OrganizationPermissionEnum.owner,
    );
    final canManageSubscription = currentUser.hasPermission(
      OrganizationPermissionEnum.owner,
    );
    final canManageGroups = currentUser.hasPermission(
      OrganizationPermissionEnum.manageGroups,
    );
    final canManageFunctions = currentUser.hasPermission(
      OrganizationPermissionEnum.manageFunctions,
    );

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
            DSMenuSection(
              title: 'Membros',
              children: [
                DSMenuTile(
                  icon: Icons.group_outlined,
                  title: canInviteMembers ? 'Gerenciar Membros' : 'Membros',
                  subtitle: canInviteMembers
                      ? 'Adicione ou remova membros da organização'
                      : 'Veja a lista de membros da organização',
                  onTap: () => context.push(AppPaths.orgTeam),
                ),
                if (canManageFunctions)
                  DSMenuTile(
                    icon: Icons.music_note_outlined,
                    title: 'Gerenciar Funções',
                    subtitle:
                        'Crie e gerencie as funções dos membros da organização',
                    onTap: () => context.push(AppPaths.orgMinistryFunctions),
                  ),
                DSMenuTile(
                  icon: Icons.groups_outlined,
                  title: canManageGroups ? 'Gerenciar Grupos' : 'Grupos',
                  subtitle: canManageGroups
                      ? 'Crie e organize grupos para facilitar a gestão'
                      : 'Veja os grupos da organização',
                  onTap: () => context.push(AppPaths.orgMinistryGroups),
                ),
                DSMenuTile(
                  icon: Icons.shield_outlined,
                  title: 'Gerenciar Papéis',
                  subtitle: 'Gerencie os papéis da organização (Admin, Líder)',
                  onTap: canManageRoles
                      ? () => context.push(AppPaths.orgMinistryRoles)
                      : null,
                ),
                DSMenuTile(
                  icon: Icons.mail_outline_rounded,
                  title: 'Convites Pendentes',
                  subtitle: 'Veja quem ainda não aceitou entrar',
                  onTap: canInviteMembers ? () {} : null,
                ),
              ],
            ),
            const SizedBox(height: DSSpacing.xl),
            DSMenuSection(
              title: 'Eventos',
              children: [
                DSMenuTile(
                  icon: Icons.repeat_outlined,
                  title: 'Recorrências',
                  subtitle: 'Crie padrões de eventos de forma automática',
                  onTap: () {},
                ),
                DSMenuTile(
                  icon: Icons.event_outlined,
                  title: 'Todos os Eventos',
                  subtitle: 'Visualize e edite todo o histórico',
                  onTap: () {},
                ),
              ],
            ),
            if (canManageSubscription) ...[
              const SizedBox(height: DSSpacing.xl),
              DSMenuSection(
                title: 'Assinatura',
                children: [const SubscriptionPlanCard()],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
