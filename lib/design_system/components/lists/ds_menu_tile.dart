// Tile plano (sem borda nem raio próprios) projetado para viver dentro de
// [DSMenuSection]. Ícone em pílula colorida à esquerda, título + subtítulo
// e chevron à direita.
//
// Para tiles standalone (fora de uma seção agrupada), use [DSActionCard].
//
// Exemplo:
//   DSMenuTile(
//     icon: Icons.person_outline,
//     title: 'Dados pessoais',
//     subtitle: 'Nome, e-mail e contacto',
//     onTap: () => context.push(...),
//   )
import 'package:flutter/material.dart';

import '../../foundations/ds_icon.dart';
import '../../foundations/ds_text.dart';
import '../../theme/ds_context_extensions.dart';
import '../../tokens/ds_radius.dart';
import '../../tokens/ds_spacing.dart';

class DSMenuTile extends StatelessWidget {
  const DSMenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.iconColor,
    this.iconBackgroundColor,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  /// Cor do ícone. Default: [DSColors.primary].
  final Color? iconColor;

  /// Cor de fundo do "chip" do ícone. Default: [DSColors.primaryTint].
  final Color? iconBackgroundColor;

  /// Substitui o chevron padrão à direita.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fgIcon = iconColor ?? colors.primary;
    final bgIcon = iconBackgroundColor ?? colors.primaryTint;
    final enabled = onTap != null;

    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.lg,
              vertical: DSSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: bgIcon,
                    borderRadius: DSRadius.allMd,
                  ),
                  child: DSIcon(icon, color: fgIcon, size: DSIconSize.md),
                ),
                const SizedBox(width: DSSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DSText(title, variant: DSTextVariant.titleSmall),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        DSText(
                          subtitle!,
                          variant: DSTextVariant.bodySmall,
                          color: colors.textSecondary,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: DSSpacing.sm),
                trailing ??
                    DSIcon(
                      Icons.chevron_right_rounded,
                      color: colors.textSecondary,
                      size: DSIconSize.md,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
