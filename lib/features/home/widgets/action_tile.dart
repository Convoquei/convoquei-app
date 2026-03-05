import 'package:convoquei_app/core/theme/app_theme.dart' show AppTheme;
import 'package:flutter/material.dart';

class ActionTile extends StatelessWidget {
  final String title;
  final String? description;

  /// Passe só o ícone. O tile cuida do “círculo” e do padding.
  final IconData icon;

  /// Cor do ícone (e estado destrutivo)
  final Color? iconColor;
  final Color? iconBgColor;

  /// Ação destrutiva (ex: remover)
  final bool destructive;

  /// Chevron opcional (se null usa o padrão)
  final Widget? trailing;

  final VoidCallback? onTap;

  const ActionTile({
    super.key,
    required this.title,
    required this.icon,
    this.description,
    this.iconColor,
    this.iconBgColor,
    this.destructive = false,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final baseTitleStyle = theme.textTheme.titleSmall!;
    final baseDescStyle = theme.textTheme.bodySmall!;

    final titleStyle = baseTitleStyle.copyWith(
      color: destructive ? const Color(0xFFDC2626) : AppTheme.textPrimary,
      fontWeight: FontWeight.w700,
      height: 1.15,
    );

    final descStyle = baseDescStyle.copyWith(
      color: destructive ? const Color(0xFFF87171) : AppTheme.textSecondary,
      height: 1.25,
    );

    final effectiveIconColor = iconColor ??
        (destructive ? const Color(0xFFDC2626) : AppTheme.primaryColor);

    final effectiveIconBg = iconBgColor ??
        (destructive ? const Color(0xFFFEE2E2) : const Color(0xFFEFF6FF));

    final chevron = trailing ??
        Icon(
          Icons.chevron_right_rounded,
          color: AppTheme.textSecondary.withValues(alpha: 0.35),
          size: 22,
        );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Leading “pill” clean (sem width/height explícitos na API do componente)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: effectiveIconBg,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(icon, color: effectiveIconColor, size: 20),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: titleStyle,
                    ),
                    if (description != null && description!.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: descStyle,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 12),
              chevron,
            ],
          ),
        ),
      ),
    );
  }
}