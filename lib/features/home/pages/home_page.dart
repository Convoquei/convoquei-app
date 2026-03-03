import 'package:convoquei_app/core/network/exceptions/api_exception.dart';
import 'package:convoquei_app/core/services/user_feedback_service.dart';
import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:convoquei_app/features/home/widgets/create_organization_modal.dart';
import 'package:convoquei_app/features/home/widgets/my_invite_card.dart';
import 'package:convoquei_app/features/organizations/models/organization_invite_model.dart';
import 'package:convoquei_app/features/organizations/models/organization_model.dart';
import 'package:convoquei_app/features/organizations/pages/organization_shell.dart';
import 'package:convoquei_app/features/organizations/providers/selected_organization_provider.dart';
import 'package:convoquei_app/features/organizations/widgets/organization_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../../organizations/providers/organization_providers.dart';
import '../widgets/perfil_header.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user!;
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
          message: 'Erro ao responder o convite.',
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
                    const SizedBox(height: 12),

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
                                    horizontal: 16,
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
                                          const SizedBox(height: 12),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),

                    // ── Aguardando Resposta ──────────────────────────────
                    _SectionHeader(title: 'Suas Pendências'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _AllClearCard(),
                    ),
                    const SizedBox(height: 24),

                    // ── Organizações ─────────────────────────────────────
                    _SectionHeader(title: 'Organizações'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: organizationsAsync.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (error, _) => Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                error.toString(),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: () =>
                                    ref.invalidate(userOrganizationsProvider),
                                child: const Text('Tentar novamente'),
                              ),
                            ],
                          ),
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
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    OrganizationShell(organization: org),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Sua Semana ───────────────────────────────────────
                    _SectionHeader(
                      title: 'Sua Semana',
                      trailing: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Ver calendário',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _FreeWeekCard(),
                    ),
                    const SizedBox(height: 32),
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
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
          if (trailing != null) trailing!,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFECFDF5), Color(0xFFF0FDF4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD1FAE5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFD1FAE5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF059669),
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tudo em dia!',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF065F46),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Você não possui pendências no momento.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF059669).withValues(alpha: 0.8),
                ),
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
        // Real organization cards (each full-width)
        ...organizations.map(
          (org) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _OrgListTile(
              organization: org,
              onTap: () => onOrganizationTap(org),
            ),
          ),
        ),

        // Action buttons row
        Row(
          children: [
            Expanded(
              child: _ActionGridButton(
                icon: Icons.link_rounded,
                label: 'Entrar via Link',
                onTap: onJoinWithLink,
              ),
            ),
            const SizedBox(width: 12),
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              OrganizationAvatar(photoUrl: organization.photoUrl),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      organization.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Membro',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
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
      color: dashed ? const Color(0xFFF8FAFC) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: dashed
                ? Border.all(
                    color: const Color(0xFFCBD5E1),
                    strokeAlign: BorderSide.strokeAlignInside,
                    style: BorderStyle.solid,
                    width: 1.5,
                  )
                : Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: dashed ? Colors.white : const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                  boxShadow: dashed
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: dashed
                      ? const Color(0xFF94A3B8)
                      : AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: dashed
                      ? const Color(0xFF475569)
                      : const Color(0xFF334155),
                ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: Color(0xFFCBD5E1),
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Semana Livre',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Você não está escalado para nenhum evento nos próximos dias.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Color(0xFF94A3B8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
