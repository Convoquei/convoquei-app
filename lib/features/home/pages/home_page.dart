import 'package:convoquei_app/app/router.dart';
import 'package:convoquei_app/core/network/exceptions/api_exception.dart';
import 'package:convoquei_app/core/services/user_feedback_service.dart';
import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/home/widgets/create_organization_modal.dart';
import 'package:convoquei_app/features/home/widgets/my_invite_card.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_invite_model.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_model.dart';
import 'package:convoquei_app/features/organizations/shared/providers/selected_organization_provider.dart';
import 'package:convoquei_app/features/organizations/shared/widgets/organization_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_providers.dart';
import '../../organizations/shared/providers/organization_providers.dart';
import '../widgets/perfil_header.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    if (user == null) {
      return const Scaffold(body: SizedBox.shrink());
    }
    final AsyncValue<List<OrganizationModel>> organizationsAsync = ref.watch(
      userOrganizationsProvider,
    );
    final AsyncValue<List<OrganizationInviteModel>> invitesAsync = ref.watch(
      findAllInvitesByUserProvider,
    );

    Future<void> handleCreateOrganization(String name, String type) async {
      try {
        await ref.read(createOrganizationProvider)(name, type);
        ref.invalidate(userOrganizationsProvider);
      } catch (e) {
        if (!context.mounted) return;
        if (e is ApiException) {
          UserFeedbackService.error(context, message: e.message);
          return;
        }
      }
    }

    Future<void> handleResponseInvite(
      OrganizationInviteModel invite,
      bool accept,
    ) async {
      try {
        await ref.read(responseInviteProvider)(invite.id, accept);
        ref.invalidate(findAllInvitesByUserProvider);
        ref.invalidate(userOrganizationsProvider);
        if (!context.mounted) return;
        UserFeedbackService.success(
          context,
          message: accept
              ? 'Convite de ${invite.organization} aceito!'
              : 'Convite de ${invite.organization} recusado.',
        );
      } catch (e) {
        if (!context.mounted) return;
        if (e is ApiException) {
          UserFeedbackService.error(context, message: e.message);
          return;
        }
        UserFeedbackService.error(
          context,
          message: 'Não foi possível responder ao convite.',
        );
      }
    }

    void acceptInvite(OrganizationInviteModel invite) =>
        handleResponseInvite(invite, true);

    void declineInvite(OrganizationInviteModel invite) =>
        handleResponseInvite(invite, false);

    Future<void> handleRefresh() async {
      ref.invalidate(userOrganizationsProvider);
      ref.invalidate(findAllInvitesByUserProvider);
      await Future.wait([
        ref.read(userOrganizationsProvider.future),
        ref.read(findAllInvitesByUserProvider.future),
      ]);
    }

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: PerfilHeader(user: user, onNotificationTap: () {}),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: DSSpacing.md),

                    // ── Invites ──────────────────────────────
                    invitesAsync.when(
                      data: (invites) => invites.isEmpty
                          ? const SizedBox.shrink()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SectionHeader(title: 'Convites Pendentes'),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: DSSpacing.lg,
                                  ),
                                  child: Column(
                                    children: [
                                      for (
                                        int i = 0;
                                        i < invites.length;
                                        i++
                                      ) ...[
                                        InviteCard(
                                          invite: invites[i],
                                          onAccept: () =>
                                              acceptInvite(invites[i]),
                                          onDecline: () =>
                                              declineInvite(invites[i]),
                                        ),
                                        if (i < invites.length - 1)
                                          const SizedBox(height: DSSpacing.md),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: DSSpacing.xl),
                              ],
                            ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    ),

                    // ── Aguardando Resposta ──────────────────────────────
                    _SectionHeader(title: 'Suas Pendências'),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: DSSpacing.lg),
                      child: _AllClearCard(),
                    ),
                    const SizedBox(height: DSSpacing.xl),

                    // ── Organizações ─────────────────────────────────────
                    _SectionHeader(title: 'Organizações'),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DSSpacing.lg,
                      ),
                      child: organizationsAsync.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: DSSpacing.xl,
                            ),
                            child: DSSpinner(size: 32),
                          ),
                        ),
                        error: (error, _) => DSErrorRetryState(
                          message:
                              'Não foi possível carregar as organizações.',
                          description:
                              'Verifique sua conexão e tente novamente.',
                          onRetry: () =>
                              ref.invalidate(userOrganizationsProvider),
                        ),
                        data: (organizations) => _OrganizationsGrid(
                          organizations: organizations,
                          onJoinWithLink: () {},
                          onCreateOrganization: () =>
                              CreateOrganizationModal.show(
                                context,
                                (name, type) =>
                                    handleCreateOrganization(name, type),
                              ),
                          onOrganizationTap: (org) {
                            ref
                                .read(selectedOrganizationProvider.notifier)
                                .select(org);
                            context.goNamed(
                              AppRoutes.orgHome,
                              pathParameters: {'orgId': org.id},
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: DSSpacing.xl),

                    // ── Sua Semana ───────────────────────────────────────
                    _SectionHeader(
                      title: 'Sua Semana',
                      trailing: TextButton(
                        onPressed: () {},
                        child: DSText(
                          'Ver calendário',
                          variant: DSTextVariant.labelSmall,
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: DSSpacing.lg),
                      child: _FreeWeekCard(),
                    ),
                    const SizedBox(height: DSSpacing.xxl),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DSSpacing.lg,
        0,
        DSSpacing.sm,
        DSSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DSText(title, variant: DSTextVariant.titleLarge),
          ?trailing,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// "Tudo em dia" card (mocked – no pending items)
// ─────────────────────────────────────────────────────────────────────────────

class _AllClearCard extends StatelessWidget {
  const _AllClearCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.successTint,
        borderRadius: DSRadius.allLg,
        border: Border.all(
          color: context.colors.success.withValues(alpha: 0.3),
        ),
        boxShadow: DSElevation.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.colors.success.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: context.colors.success,
              size: 26,
            ),
          ),
          const SizedBox(width: DSSpacing.lg),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DSText(
                'Tudo em dia!',
                variant: DSTextVariant.labelLarge,
                color: context.colors.success,
              ),
              const SizedBox(height: 2),
              DSText(
                'Você não possui pendências no momento.',
                variant: DSTextVariant.bodySmall,
                color: context.colors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Organizations grid
// ─────────────────────────────────────────────────────────────────────────────

class _OrganizationsGrid extends StatelessWidget {
  final List<OrganizationModel> organizations;
  final VoidCallback onJoinWithLink;
  final VoidCallback onCreateOrganization;
  final ValueChanged<OrganizationModel> onOrganizationTap;

  const _OrganizationsGrid({
    required this.organizations,
    required this.onJoinWithLink,
    required this.onCreateOrganization,
    required this.onOrganizationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...organizations.map(
          (org) => Padding(
            padding: const EdgeInsets.only(bottom: DSSpacing.md),
            child: _OrgListTile(
              organization: org,
              onTap: () => onOrganizationTap(org),
            ),
          ),
        ),

        Row(
          children: [
            Expanded(
              child: _ActionGridButton(
                icon: Icons.link_rounded,
                label: 'Entrar via Link',
                onTap: onJoinWithLink,
              ),
            ),
            const SizedBox(width: DSSpacing.md),
            Expanded(
              child: _ActionGridButton(
                icon: Icons.add,
                label: 'Nova Org',
                dashed: true,
                onTap: onCreateOrganization,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OrgListTile extends StatelessWidget {
  final OrganizationModel organization;
  final VoidCallback onTap;

  const _OrgListTile({required this.organization, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return DSCard(
      onTap: onTap,
      child: Row(
        children: [
          OrganizationAvatar(photoUrl: organization.photoUrl),
          const SizedBox(width: DSSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DSText(
                  organization.name,
                  variant: DSTextVariant.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: DSSpacing.xs),
                DSBadge(
                  label: 'Membro',
                  color: context.colors.textSecondary,
                  variant: DSBadgeVariant.soft,
                  size: DSBadgeSize.sm,
                ),
              ],
            ),
          ),
          DSIcon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

class _ActionGridButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool dashed;
  final VoidCallback onTap;

  const _ActionGridButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.dashed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: dashed ? context.colors.background : context.colors.surface,
      borderRadius: DSRadius.allLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: DSRadius.allLg,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: DSSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: DSRadius.allLg,
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: dashed
                      ? context.colors.surface
                      : context.colors.primaryTint,
                  shape: BoxShape.circle,
                  boxShadow: dashed ? DSElevation.sm : null,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: dashed
                      ? context.colors.textSecondary
                      : context.colors.primary,
                ),
              ),
              const SizedBox(height: DSSpacing.sm),
              DSText(
                label,
                variant: DSTextVariant.labelSmall,
                textAlign: TextAlign.center,
                color: dashed
                    ? context.colors.textSecondary
                    : context.colors.textPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// "Semana Livre" card (mocked – no scheduled events)
// ─────────────────────────────────────────────────────────────────────────────

class _FreeWeekCard extends StatelessWidget {
  const _FreeWeekCard();

  @override
  Widget build(BuildContext context) {
    return DSCard(
      padding: const EdgeInsets.symmetric(
        vertical: DSSpacing.xxl,
        horizontal: DSSpacing.xl,
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: context.colors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_today_rounded,
              color: context.colors.border,
              size: 28,
            ),
          ),
          const SizedBox(height: DSSpacing.lg),
          DSText(
            'Semana Livre',
            variant: DSTextVariant.labelLarge,
            color: context.colors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.xs),
          DSText(
            'Você não está escalado para nenhum evento nos próximos dias.',
            variant: DSTextVariant.bodySmall,
            textAlign: TextAlign.center,
            color: context.colors.textSecondary,
          ),
        ],
      ),
    );
  }
}
