// Header padrão da aplicação — barra translúcida com identidade do usuário,
// rótulo do contexto atual (com seletor) e ações rápidas (configurações e
// notificações).
//
// Apresentacional: não conhece providers nem rotas. Receba os dados e fios
// callbacks; a feature wrapper (AppHeader em core/widgets) faz a integração.
//
// Exemplo:
//   DSAppHeader(
//     userName: 'João Silva',
//     userAvatarUrl: user.avatarUrl,
//     currentContextLabel: 'ICM Colina de Laranjeiras 1',
//     onProfileTap: _openProfile,
//     onContextTap: _openSwitcher,
//     onSettingsTap: _openSettings, // null esconde o botão
//     onNotificationsTap: _openNotifications,
//     hasNotifications: true,
//   )
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../foundations/ds_avatar.dart';
import '../../theme/ds_context_extensions.dart';
import '../../tokens/ds_radius.dart';
import '../../tokens/ds_spacing.dart';

class DSAppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final String? userAvatarUrl;
  final String currentContextLabel;
  final VoidCallback? onProfileTap;
  final VoidCallback? onContextTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onNotificationsTap;
  final bool hasNotifications;

  const DSAppHeader({
    super.key,
    required this.userName,
    required this.currentContextLabel,
    this.userAvatarUrl,
    this.onProfileTap,
    this.onContextTap,
    this.onSettingsTap,
    this.onNotificationsTap,
    this.hasNotifications = false,
  });

  /// Altura visível do header (não inclui safe area do status bar).
  static const double kPreferredHeight = 68;

  @override
  Size get preferredSize => const Size.fromHeight(kPreferredHeight);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Material(
          type: MaterialType.transparency,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.85),
              border: Border(
                bottom: BorderSide(color: colors.border, width: 1),
              ),
            ),
            child: SafeArea(
              top: true,
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  DSSpacing.lg,
                  DSSpacing.sm,
                  DSSpacing.sm,
                  DSSpacing.md,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _Identity(
                        userName: userName,
                        userAvatarUrl: userAvatarUrl,
                        currentContextLabel: currentContextLabel,
                        onProfileTap: onProfileTap,
                        onContextTap: onContextTap,
                      ),
                    ),
                    if (onSettingsTap != null)
                      _HeaderAction(
                        icon: Icons.settings_rounded,
                        onPressed: onSettingsTap,
                        tooltip: 'Configurações',
                      ),
                    _HeaderAction(
                      icon: Icons.notifications_rounded,
                      onPressed: onNotificationsTap,
                      tooltip: 'Notificações',
                      hasIndicator: hasNotifications,
                      indicatorColor: colors.warning,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Identity extends StatelessWidget {
  final String userName;
  final String? userAvatarUrl;
  final String currentContextLabel;
  final VoidCallback? onProfileTap;
  final VoidCallback? onContextTap;

  const _Identity({
    required this.userName,
    required this.userAvatarUrl,
    required this.currentContextLabel,
    required this.onProfileTap,
    required this.onContextTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Row(
      children: [
        GestureDetector(
          onTap: onProfileTap,
          behavior: HitTestBehavior.opaque,
          child: DSAvatar(
            name: userName,
            avatarUrl: userAvatarUrl,
            radius: 20,
          ),
        ),
        const SizedBox(width: DSSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: onProfileTap,
                borderRadius: DSRadius.allSm,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyles.titleSmall,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              InkWell(
                onTap: onContextTap,
                borderRadius: DSRadius.allSm,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.xs,
                    vertical: 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          currentContextLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textStyles.labelSmall.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: DSSpacing.xs),
                      Icon(
                        Icons.unfold_more_rounded,
                        size: 14,
                        color: colors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final bool hasIndicator;
  final Color? indicatorColor;

  const _HeaderAction({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.hasIndicator = false,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: Icon(icon, size: 22),
            color: colors.textSecondary,
            tooltip: tooltip,
            onPressed: onPressed,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 40, height: 40),
          ),
          if (hasIndicator)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: indicatorColor ?? colors.warning,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.surface, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
