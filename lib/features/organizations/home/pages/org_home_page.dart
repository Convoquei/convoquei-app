import 'package:convoquei_app/app/router.dart';
import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/events/models/orgnaization_event_membership_model.dart';
import 'package:convoquei_app/features/organizations/events/providers/answer_availability_provider.dart';
import 'package:convoquei_app/features/organizations/home/providers/next_assigned_event_provider.dart';
import 'package:convoquei_app/features/organizations/home/providers/next_pending_availability_event_provider.dart';
import 'package:convoquei_app/features/organizations/members/widgets/modals/invite_member_by_email_modal.dart';
import 'package:convoquei_app/features/organizations/shared/models/enums/organization_permission.dart';
import 'package:convoquei_app/features/organizations/shared/providers/organization_providers.dart';
import 'package:convoquei_app/features/organizations/shared/providers/selected_organization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class OrgHomePage extends ConsumerStatefulWidget {
  const OrgHomePage({super.key});

  @override
  ConsumerState<OrgHomePage> createState() => _OrgHomePageState();
}

class _OrgHomePageState extends ConsumerState<OrgHomePage> {
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _showContent = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orgId = ref.watch(selectedOrganizationProvider)!.id;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(nextPendingAvailabilityEventProvider(orgId));
        ref.invalidate(nextAssignedEventProvider(orgId));
        ref.invalidate(currentUserMembershipOrganizationProvider(orgId));
        await Future.wait([
          ref
              .read(nextPendingAvailabilityEventProvider(orgId).future)
              .catchError((_) => null),
          ref
              .read(nextAssignedEventProvider(orgId).future)
              .catchError((_) => null),
        ]);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          DSSpacing.lg,
          DSSpacing.lg,
          DSSpacing.lg,
          DSSpacing.huge,
        ),
        children: _showContent
            ? [
                _AvailabilityHeroCard(orgId: orgId),
                const SizedBox(height: DSSpacing.xl),
                _QuickMenu(orgId: orgId),
                // const _BirthdaysSection(),
                // const SizedBox(height: DSSpacing.xl),
                const SizedBox(height: DSSpacing.xl),
                const _NoticesSection(),
                const SizedBox(height: DSSpacing.xl),
                _NextAssignedSection(orgId: orgId),
              ]
            : [
                const _AvailabilityCardSkeleton(),
                const SizedBox(height: DSSpacing.xl),
                const _QuickMenuSkeleton(),
                // const SizedBox(height: DSSpacing.xl),
                // const _BirthdaysSectionSkeleton(),
                const SizedBox(height: DSSpacing.xl),
                const _NoticesSectionSkeleton(),
                const SizedBox(height: DSSpacing.xl),
                const _NextAssignedSectionSkeleton(),
              ],
      ),
    );
  }
}

// ── Skeletons ────────────────────────────────────────────────────────────────

class _AvailabilityCardSkeleton extends StatelessWidget {
  const _AvailabilityCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: DSRadius.allLg,
        border: Border.all(color: context.colors.border),
      ),
      child: const Row(
        children: [
          DSSkeleton(height: 40, width: 40, borderRadius: DSRadius.md),
          SizedBox(width: DSSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DSSkeleton(height: 14, width: 100),
                SizedBox(height: 4),
                DSSkeleton(height: 12, width: double.infinity),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickMenuSkeleton extends StatelessWidget {
  const _QuickMenuSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (_) {
        return Expanded(
          child: Column(
            children: const [
              DSSkeleton(height: 56, width: 56, borderRadius: DSRadius.lg),
              SizedBox(height: DSSpacing.xs),
              DSSkeleton(height: 10, width: 40),
            ],
          ),
        );
      }),
    );
  }
}

class _BirthdaysSectionSkeleton extends StatelessWidget {
  const _BirthdaysSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            DSSkeleton(height: 18, width: 18, borderRadius: DSRadius.sm),
            SizedBox(width: DSSpacing.xs),
            DSSkeleton(height: 16, width: 160),
          ],
        ),
        const SizedBox(height: DSSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            children: [
              for (int i = 0; i < 5; i++) ...[
                Column(
                  children: const [
                    DSSkeleton(height: 56, width: 56, borderRadius: 28),
                    SizedBox(height: DSSpacing.md),
                    DSSkeleton(height: 10, width: 40),
                  ],
                ),
                if (i < 4) const SizedBox(width: DSSpacing.xl),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _NoticesSectionSkeleton extends StatelessWidget {
  const _NoticesSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2),
          child: DSSkeleton(height: 16, width: 140),
        ),
        const SizedBox(height: DSSpacing.md),
        DSCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: const [
              _NoticeItemSkeleton(),
              DSDivider(indent: DSSpacing.lg, endIndent: DSSpacing.lg),
              _NoticeItemSkeleton(),
            ],
          ),
        ),
      ],
    );
  }
}

class _NoticeItemSkeleton extends StatelessWidget {
  const _NoticeItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(DSSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DSSkeleton(height: 40, width: 40, borderRadius: DSRadius.md),
          SizedBox(width: DSSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DSSkeleton(height: 10, width: 50),
                    DSSkeleton(height: 10, width: 40),
                  ],
                ),
                SizedBox(height: 4),
                DSSkeleton(height: 13, width: double.infinity),
                SizedBox(height: 4),
                DSSkeleton(height: 12, width: 180),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NextAssignedSectionSkeleton extends StatelessWidget {
  const _NextAssignedSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DSSkeleton(height: 16, width: 160),
            DSSkeleton(height: 12, width: 50),
          ],
        ),
        const SizedBox(height: DSSpacing.md),
        DSCard(
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(DSSpacing.lg),
            child: Row(
              children: const [
                DSSkeleton(height: 56, width: 48, borderRadius: DSRadius.md),
                SizedBox(width: DSSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DSSkeleton(height: 14, width: double.infinity),
                      SizedBox(height: 4),
                      DSSkeleton(height: 12, width: 120),
                      SizedBox(height: 6),
                      DSSkeleton(
                        height: 20,
                        width: 100,
                        borderRadius: DSRadius.sm,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: DSSpacing.sm),
                DSSkeleton(height: 18, width: 18, borderRadius: DSRadius.sm),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Availability Hero Card ───────────────────────────────────────────────────

class _AvailabilityHeroCard extends ConsumerWidget {
  final String orgId;
  const _AvailabilityHeroCard({required this.orgId});

  Future<void> _answer(WidgetRef ref, String eventId, bool available) async {
    await ref
        .read(answerAvailabilityProvider.notifier)
        .answer(organizationId: orgId, eventId: eventId, available: available);
    ref.invalidate(nextPendingAvailabilityEventProvider(orgId));
    ref.invalidate(nextAssignedEventProvider(orgId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(nextPendingAvailabilityEventProvider(orgId));
    final isLoading = ref.watch(answerAvailabilityProvider).isLoading;

    return async.when(
      loading: () => const _AvailabilityCardSkeleton(),
      error: (_, _) => const _AllClearCard(),
      data: (event) {
        if (event == null) return const _AllClearCard();
        return _PendingEventCard(
          event: event,
          isLoading: isLoading,
          onAvailable: () => _answer(ref, event.id, true),
          onUnavailable: () => _answer(ref, event.id, false),
        );
      },
    );
  }
}

class _AllClearCard extends StatelessWidget {
  const _AllClearCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        color: colors.successTint,
        borderRadius: DSRadius.allLg,
        border: Border.all(color: colors.success.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.success.withValues(alpha: 0.15),
              borderRadius: DSRadius.allMd,
            ),
            child: Icon(
              Icons.check_circle_outline_rounded,
              color: colors.success,
              size: 22,
            ),
          ),
          const SizedBox(width: DSSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DSText('Tudo em dia!', variant: DSTextVariant.titleSmall),
                const SizedBox(height: 2),
                DSText(
                  'Você respondeu todos os eventos pendentes.',
                  variant: DSTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingEventCard extends StatelessWidget {
  final OrganizationEventMembershipModel event;
  final bool isLoading;
  final VoidCallback onAvailable;
  final VoidCallback onUnavailable;

  const _PendingEventCard({
    required this.event,
    required this.isLoading,
    required this.onAvailable,
    required this.onUnavailable,
  });

  String _formatDate(DateTime dt) {
    try {
      return DateFormat("EEE, dd 'de' MMM • HH'h'mm", 'pt_BR').format(dt);
    } catch (_) {
      return DateFormat("EEE, dd MMM • HH:mm").format(dt);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(DSSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.warningTint, colors.surface],
        ),
        borderRadius: DSRadius.allLg,
        border: Border.all(color: colors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.warning,
                  borderRadius: DSRadius.allSm,
                ),
                child: Text(
                  'AÇÃO NECESSÁRIA',
                  style: context.textStyles.labelSmall.copyWith(
                    color: Colors.white,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 12,
                    color: colors.warning,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Expira em breve',
                    style: context.textStyles.labelSmall.copyWith(
                      color: colors.warning,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          DSText(event.name, variant: DSTextVariant.titleMedium),
          const SizedBox(height: 4),
          DSText(
            _formatDate(event.startTime),
            variant: DSTextVariant.bodySmall,
            color: colors.textSecondary,
          ),
          const SizedBox(height: DSSpacing.lg),
          Row(
            children: [
              Expanded(
                child: DSButton(
                  label: 'Disponível',
                  schema: DSButtonSchema.success,
                  icon: Icons.check_rounded,
                  size: DSButtonSize.sm,
                  isLoading: isLoading,
                  onPressed: isLoading ? null : onAvailable,
                ),
              ),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: DSButton(
                  label: 'Não posso',
                  schema: DSButtonSchema.ghost,
                  outlined: true,
                  size: DSButtonSize.sm,
                  onPressed: isLoading ? null : onUnavailable,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Quick Menu ───────────────────────────────────────────────────────────────

class _QuickMenu extends ConsumerWidget {
  final String orgId;
  const _QuickMenu({required this.orgId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberAsync = ref.watch(
      currentUserMembershipOrganizationProvider(orgId),
    );
    final member = memberAsync.asData?.value;

    final canManageEvents =
        member?.hasPermission(OrganizationPermissionEnum.manageEvents) ?? false;
    final canInvite =
        member?.hasPermission(OrganizationPermissionEnum.inviteMembers) ??
        false;

    final items = <({IconData icon, String label, VoidCallback onTap})>[
      if (canManageEvents)
        (
          icon: Icons.calendar_today_rounded,
          label: 'Novo Evento',
          onTap: () => context.pushNamed(
            AppRoutes.orgCreateEvent,
            pathParameters: {'orgId': orgId},
          ),
        ),
      if (canInvite)
        (
          icon: Icons.person_add_rounded,
          label: 'Convidar',
          onTap: () => InviteMemberByEmailModal.show(context, orgId),
        ),
      (
        icon: Icons.list_alt_rounded,
        label: 'Escalas',
        onTap: () => context.goNamed(
          AppRoutes.orgScales,
          pathParameters: {'orgId': orgId},
        ),
      ),
      (
        icon: Icons.people_rounded,
        label: 'Equipe',
        onTap: () => context.pushNamed(
          AppRoutes.orgTeam,
          pathParameters: {'orgId': orgId},
        ),
      ),
    ];

    return Row(
      children: [
        for (final item in items)
          Expanded(
            child: DSQuickMenuItem(
              icon: item.icon,
              label: item.label,
              onTap: item.onTap,
            ),
          ),
      ],
    );
  }
}

// ── Birthdays ────────────────────────────────────────────────────────────────

class _BirthdaysSection extends StatelessWidget {
  const _BirthdaysSection();

  static const _mocks = [
    (name: 'Mariana', dateLabel: '14 Mai'),
    (name: 'Ricardo', dateLabel: '18 Mai'),
    (name: 'Ana Paula', dateLabel: '22 Mai'),
    (name: 'João', dateLabel: '24 Mai'),
    (name: 'Beatriz', dateLabel: '29 Mai'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.celebration_rounded,
              color: context.colors.primary,
              size: 18,
            ),
            const SizedBox(width: DSSpacing.xs),
            const DSText(
              'Aniversariantes do Mês',
              variant: DSTextVariant.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int i = 0; i < _mocks.length; i++) ...[
                _BirthdayItem(
                  name: _mocks[i].name,
                  dateLabel: _mocks[i].dateLabel,
                ),
                if (i < _mocks.length - 1) const SizedBox(width: DSSpacing.xl),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _BirthdayItem extends StatelessWidget {
  final String name;
  final String dateLabel;
  const _BirthdayItem({required this.name, required this.dateLabel});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            DSAvatar(name: name, radius: 22),
            Positioned(
              bottom: -6,
              right: -10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: DSRadius.allSm,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  dateLabel,
                  style: context.textStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.md),
        DSText(name.split(' ').first, variant: DSTextVariant.labelSmall),
      ],
    );
  }
}

// ── Notices ──────────────────────────────────────────────────────────────────

class _NoticesSection extends StatelessWidget {
  const _NoticesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2),
          child: DSText('Mural de Avisos', variant: DSTextVariant.titleMedium),
        ),
        const SizedBox(height: DSSpacing.md),
        DSCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _NoticeItem(
                category: 'Geral',
                date: 'Hoje',
                title: 'Camisas do ministério chegaram!',
                description:
                    'Já estão disponíveis para retirada na secretaria.',
              ),
              const DSDivider(indent: DSSpacing.lg, endIndent: DSSpacing.lg),
              _NoticeItem(
                category: 'Lembrete',
                date: 'Ontem',
                title: 'Reunião de líderes na sexta-feira',
                description: 'Confirmem presença até quinta-feira, às 18h.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NoticeItem extends StatelessWidget {
  final String category;
  final String date;
  final String title;
  final String description;
  const _NoticeItem({
    required this.category,
    required this.date,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(DSSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.infoTint,
              borderRadius: DSRadius.allMd,
            ),
            child: Icon(Icons.campaign_rounded, color: colors.info, size: 20),
          ),
          const SizedBox(width: DSSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DSText(
                      category.toUpperCase(),
                      variant: DSTextVariant.labelSmall,
                      color: colors.info,
                    ),
                    DSText(
                      date,
                      variant: DSTextVariant.labelSmall,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                DSText(
                  title,
                  variant: DSTextVariant.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                DSText(
                  description,
                  variant: DSTextVariant.bodySmall,
                  color: colors.textSecondary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Next Assigned Event ──────────────────────────────────────────────────────

class _NextAssignedSection extends ConsumerWidget {
  final String orgId;
  const _NextAssignedSection({required this.orgId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(nextAssignedEventProvider(orgId));

    return async.when(
      loading: () => const _NextAssignedSectionSkeleton(),
      error: (_, _) => const SizedBox.shrink(),
      data: (event) {
        if (event == null) return const SizedBox.shrink();
        return _NextAssignedCard(orgId: orgId, event: event);
      },
    );
  }
}

class _NextAssignedCard extends StatelessWidget {
  final String orgId;
  final OrganizationEventMembershipModel event;
  const _NextAssignedCard({required this.orgId, required this.event});

  String _formatTime(DateTime dt, String location) {
    final time = DateFormat("HH'h'mm").format(dt);
    return location.isNotEmpty ? '$time • $location' : time;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const DSText(
              'Sua Próxima Escala',
              variant: DSTextVariant.titleMedium,
            ),
            GestureDetector(
              onTap: () => context.goNamed(
                AppRoutes.orgScales,
                pathParameters: {'orgId': orgId},
              ),
              child: DSText(
                'Ver todas',
                variant: DSTextVariant.labelSmall,
                color: colors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: DSSpacing.md),
        DSCard(
          padding: EdgeInsets.zero,
          onTap: () => context.pushNamed(
            AppRoutes.orgEventDetail,
            pathParameters: {'orgId': orgId, 'eventId': event.id},
          ),
          child: Padding(
            padding: const EdgeInsets.all(DSSpacing.lg),
            child: Row(
              children: [
                DSDateBadge(
                  date: event.startTime,
                  color: context.colors.success,
                ),
                const SizedBox(width: DSSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DSText(
                        event.name,
                        variant: DSTextVariant.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      DSText(
                        _formatTime(event.startTime, event.location),
                        variant: DSTextVariant.bodySmall,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(height: 6),
                      DSBadge(
                        label: event.membershipFunctionName != null
                            ? 'Escalado como ${event.membershipFunctionName}'
                            : 'Escalado',
                        color: colors.success,
                        variant: DSBadgeVariant.soft,
                        size: DSBadgeSize.sm,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: DSSpacing.sm),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.textSecondary.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
