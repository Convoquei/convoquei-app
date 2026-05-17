import 'package:convoquei_app/core/services/toast_feedback_service.dart';
import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/auth/providers/auth_providers.dart';
import 'package:convoquei_app/features/profile/providers/app_version_provider.dart';
import 'package:convoquei_app/features/profile/providers/theme_mode_provider.dart';
import 'package:convoquei_app/features/profile/widgets/profile_header.dart';
import 'package:convoquei_app/features/profile/widgets/theme_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final versionAsync = ref.watch(appVersionProvider);
    final themeMode = ref.watch(themeModeProvider);

    if (user == null) {
      return const Scaffold(
        body: DSLoadingScreen(
          label: 'Carregando perfil...',
          description: 'Buscando seus dados',
          skeleton: DSLoadingSkeleton.details,
        ),
      );
    }

    final themeModeLabel = switch (themeMode) {
      ThemeMode.light => 'Claro',
      ThemeMode.dark => 'Escuro',
      ThemeMode.system => 'Automático',
    };

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(DSSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ProfileHeader(user: user),
              const SizedBox(height: DSSpacing.xxl),

              // ── A sua conta ─────────────────────────────────────────────
              DSMenuSection(
                title: 'A sua conta',
                children: [
                  DSMenuTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Dados pessoais',
                    subtitle: 'Edite seus dados pessoais',
                    onTap: () => _stub(context),
                  ),
                  DSMenuTile(
                    icon: Icons.link_rounded,
                    title: 'Contas vinculadas',
                    subtitle: 'Google, Apple e outros',
                    onTap: () => _stub(context),
                  ),
                  DSMenuTile(
                    icon: Icons.credit_card_rounded,
                    title: 'Assinaturas e planos',
                    subtitle: 'Gerencie seus planos ativos',
                    onTap: () => _stub(context),
                  ),
                ],
              ),
              const SizedBox(height: DSSpacing.xl),

              // ── Preferências ────────────────────────────────────────────
              DSMenuSection(
                title: 'Preferências',
                children: [
                  DSMenuTile(
                    icon: Icons.event_busy_rounded,
                    title: 'Indisponibilidades',
                    subtitle: 'Marque dias em que você não pode participar',
                    onTap: () => _stub(context),
                  ),
                  DSMenuTile(
                    icon: Icons.brightness_medium_rounded,
                    title: 'Aparência',
                    subtitle: 'Claro, escuro ou automático',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DSText(
                          themeModeLabel,
                          variant: DSTextVariant.bodySmall,
                          color: context.colors.textSecondary,
                        ),
                        const SizedBox(width: DSSpacing.xs),
                        DSIcon(
                          Icons.chevron_right_rounded,
                          color: context.colors.textSecondary,
                          size: DSIconSize.md,
                        ),
                      ],
                    ),
                    onTap: () => ThemePickerSheet.show(context),
                  ),
                ],
              ),
              const SizedBox(height: DSSpacing.xl),

              // ── Sobre ───────────────────────────────────────────────────
              DSMenuSection(
                title: 'Sobre',
                children: [
                  DSMenuTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Central de ajuda',
                    subtitle: 'Tire suas dúvidas',
                    onTap: () => _stub(context),
                  ),
                  DSMenuTile(
                    icon: Icons.lightbulb_outline_rounded,
                    title: 'Sugerir melhoria',
                    subtitle: 'Mande sua ideia para a gente',
                    onTap: () => _stub(context),
                  ),
                  DSMenuTile(
                    icon: Icons.star_outline_rounded,
                    title: 'Avaliar o app',
                    subtitle: 'Sua opinião conta muito',
                    onTap: () => _stub(context),
                  ),
                  DSMenuTile(
                    icon: Icons.description_outlined,
                    title: 'Termos de uso',
                    onTap: () => _stub(context),
                  ),
                  DSMenuTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Política de privacidade',
                    onTap: () => _stub(context),
                  ),
                ],
              ),
              const SizedBox(height: DSSpacing.xxl),

              // ── Sair ────────────────────────────────────────────────────
              DSButton(
                label: 'Sair da conta',
                schema: DSButtonSchema.danger,
                outlined: true,
                fullWidth: true,
                onPressed: () => _confirmLogout(context, ref),
              ),
              const SizedBox(height: DSSpacing.xl),

              // ── Versão ──────────────────────────────────────────────────
              versionAsync.when(
                data: (v) => DSText(
                  'Convoquei • Versão $v',
                  variant: DSTextVariant.labelSmall,
                  color: context.colors.textSecondary,
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: DSSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  void _stub(BuildContext context) {
    ToastFeedbackService.showToast(
      context,
      'Em breve. Estamos preparando essa funcionalidade.',
      ToastType.info,
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    DSBaseModal.show(
      context,
      _LogoutConfirmModal(onConfirm: () async {
        await ref.read(authProvider.notifier).logout();
      }),
    );
  }
}

class _LogoutConfirmModal extends DSBaseModal {
  const _LogoutConfirmModal({required this.onConfirm});

  final Future<void> Function() onConfirm;

  @override
  State<_LogoutConfirmModal> createState() => _LogoutConfirmModalState();
}

class _LogoutConfirmModalState extends DSBaseModalState<_LogoutConfirmModal> {
  @override
  bool get showCloseButton => false;

  @override
  bool get showDragHandle => false;

  @override
  List<Widget> buildBody(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(
          DSSpacing.xl,
          DSSpacing.sm,
          DSSpacing.xl,
          DSSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: context.colors.dangerTint,
                borderRadius: DSRadius.allLg,
              ),
              child: DSIcon(
                Icons.logout_rounded,
                color: context.colors.danger,
                size: DSIconSize.lg,
              ),
            ),
            const SizedBox(height: DSSpacing.lg),
            DSText('Sair da conta?', variant: DSTextVariant.titleMedium),
            const SizedBox(height: DSSpacing.sm),
            DSText(
              'Você precisará entrar novamente para acessar suas organizações.',
              variant: DSTextVariant.bodyMedium,
              color: context.colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DSSpacing.xl),
            DSButton(
              label: 'Sim, sair',
              schema: DSButtonSchema.danger,
              fullWidth: true,
              onPressed: () async {
                DSModal.hide(context);
                await widget.onConfirm();
              },
            ),
            const SizedBox(height: DSSpacing.sm),
            DSButton(
              label: 'Cancelar',
              schema: DSButtonSchema.ghost,
              outlined: true,
              fullWidth: true,
              onPressed: () => DSModal.hide(context),
            ),
          ],
        ),
      ),
    ];
  }
}
