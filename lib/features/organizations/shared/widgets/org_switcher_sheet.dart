import 'package:convoquei_app/app/router.dart';
import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/organizations/shared/models/organization_model.dart';
import 'package:convoquei_app/features/organizations/shared/providers/organization_providers.dart';
import 'package:convoquei_app/features/organizations/shared/providers/selected_organization_provider.dart';
import 'package:convoquei_app/features/organizations/shared/widgets/organization_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Bottom sheet de troca de contexto: Visão Global (home) ou uma das
/// organizações do usuário. Sempre mostra onde o usuário está no momento.
class OrgSwitcherSheet extends DSBaseModal {
  /// Localização atual do roteador (ex.: `/orgs/abc/events/123`).
  /// Usada para manter a seção ativa ao trocar de organização.
  final String currentLocation;

  const OrgSwitcherSheet({super.key, required this.currentLocation});

  @override
  State<OrgSwitcherSheet> createState() => _OrgSwitcherSheetState();
}

class _OrgSwitcherSheetState extends DSBaseModalState<OrgSwitcherSheet> {
  @override
  String? get titleText => 'Trocar de Espaço';

  @override
  List<Widget> buildBody(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(
          DSSpacing.lg,
          0,
          DSSpacing.lg,
          DSSpacing.xl,
        ),
        child: Consumer(
          builder: (context, ref, _) {
            final selected = ref.watch(selectedOrganizationProvider);
            final orgsAsync = ref.watch(userOrganizationsProvider);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _HomeOption(isCurrent: selected == null),
                const SizedBox(height: DSSpacing.md),
                _SectionLabel('As suas organizações'),
                const SizedBox(height: DSSpacing.sm),
                orgsAsync.when(
                  data: (orgs) {
                    if (orgs.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: DSSpacing.xl,
                        ),
                        child: DSText(
                          'Você ainda não participa de nenhuma organização.',
                          variant: DSTextVariant.bodySmall,
                          color: context.colors.textSecondary,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final org in orgs) ...[
                          _OrgOption(
                            organization: org,
                            isCurrent: selected?.id == org.id,
                            currentLocation: widget.currentLocation,
                          ),
                          if (org != orgs.last)
                            const SizedBox(height: DSSpacing.sm),
                        ],
                      ],
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: DSSpacing.xxl),
                    child: Center(child: DSSpinner(size: 48)),
                  ),
                  error: (_, _) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: DSSpacing.lg),
                    child: DSErrorRetryState(
                      message: 'Não foi possível carregar as suas organizações.',
                      description: 'Verifique sua conexão e tente novamente.',
                      onRetry: () => ref.invalidate(userOrganizationsProvider),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ];
  }
}

/// Mapeia a localização atual para o caminho-base da mesma seção na nova org.
/// Garante que trocar de org mantém o contexto (eventos → eventos, etc.).
String _resolveTargetPath(String currentLocation, String newOrgId) {
  final match = RegExp(r'^/orgs/[^/]+/([^/]+)').firstMatch(currentLocation);
  return switch (match?.group(1)) {
    'events' => AppPaths.orgEvents(newOrgId),
    'scales' => AppPaths.orgScales(newOrgId),
    'team' => AppPaths.orgTeam(newOrgId),
    _ => AppPaths.orgHome(newOrgId),
  };
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DSSpacing.xs),
      child: Text(
        label.toUpperCase(),
        style: context.textStyles.labelSmall.copyWith(
          color: context.colors.textSecondary,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _HomeOption extends ConsumerWidget {
  final bool isCurrent;
  const _HomeOption({required this.isCurrent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SwitcherTile(
      isCurrent: isCurrent,
      leading: _LeadingIcon(
        icon: Icons.home_rounded,
        isCurrent: isCurrent,
      ),
      title: 'Visão Global',
      subtitle: 'Tela inicial do aplicativo',
      onTap: () {
        DSBaseModal.hide(context);
        ref.read(selectedOrganizationProvider.notifier).clear();
        context.goNamed(AppRoutes.home);
      },
    );
  }
}

class _OrgOption extends ConsumerWidget {
  final OrganizationModel organization;
  final bool isCurrent;
  final String currentLocation;

  const _OrgOption({
    required this.organization,
    required this.isCurrent,
    required this.currentLocation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SwitcherTile(
      isCurrent: isCurrent,
      leading: OrganizationAvatar(
        photoUrl: organization.photoUrl,
        size: 40,
      ),
      title: organization.name,
      subtitle: '${organization.totalMembers} membros',
      onTap: () {
        DSBaseModal.hide(context);
        ref.read(selectedOrganizationProvider.notifier).select(organization);
        context.go(_resolveTargetPath(currentLocation, organization.id));
      },
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  final IconData icon;
  final bool isCurrent;
  const _LeadingIcon({required this.icon, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isCurrent ? colors.primary : colors.surfaceSubtle,
        borderRadius: DSRadius.allMd,
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 20,
        color: isCurrent ? colors.onPrimary : colors.textSecondary,
      ),
    );
  }
}

class _SwitcherTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final bool isCurrent;
  final VoidCallback onTap;

  const _SwitcherTile({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: DSRadius.allLg,
        child: Ink(
          decoration: BoxDecoration(
            color: isCurrent ? colors.primaryTint : colors.surface,
            borderRadius: DSRadius.allLg,
            border: Border.all(
              color: isCurrent ? colors.primary : colors.border,
              width: isCurrent ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.all(DSSpacing.lg),
          child: Row(
            children: [
              leading,
              const SizedBox(width: DSSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DSText(
                      title,
                      variant: DSTextVariant.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    DSText(
                      subtitle,
                      variant: DSTextVariant.bodySmall,
                      color: colors.textSecondary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isCurrent) ...[
                const SizedBox(width: DSSpacing.sm),
                _HereBadge(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HereBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: DSRadius.allSm,
        border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.place_rounded, size: 12, color: colors.primary),
          const SizedBox(width: 4),
          Text(
            'ESTOU AQUI',
            style: context.textStyles.labelSmall.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
