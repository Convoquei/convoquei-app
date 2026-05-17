import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/profile/providers/theme_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeModeProvider);

    return Row(
      children: [
        Expanded(
          child: _ThemeOption(
            mode: ThemeMode.light,
            icon: Icons.wb_sunny_rounded,
            label: 'Claro',
            current: current,
            onTap: () => ref.read(themeModeProvider.notifier).set(ThemeMode.light),
          ),
        ),
        const SizedBox(width: DSSpacing.sm),
        Expanded(
          child: _ThemeOption(
            mode: ThemeMode.dark,
            icon: Icons.nightlight_round,
            label: 'Escuro',
            current: current,
            onTap: () => ref.read(themeModeProvider.notifier).set(ThemeMode.dark),
          ),
        ),
        const SizedBox(width: DSSpacing.sm),
        Expanded(
          child: _ThemeOption(
            mode: ThemeMode.system,
            icon: Icons.phone_android_rounded,
            label: 'Padrão',
            current: current,
            onTap: () => ref.read(themeModeProvider.notifier).set(ThemeMode.system),
          ),
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.mode,
    required this.icon,
    required this.label,
    required this.current,
    required this.onTap,
  });

  final ThemeMode mode;
  final IconData icon;
  final String label;
  final ThemeMode current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = current == mode;
    final color = isSelected ? context.colors.primary : context.colors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: DSMotion.fast,
        curve: DSMotion.standard,
        padding: const EdgeInsets.symmetric(vertical: DSSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.primaryTint : context.colors.surface,
          borderRadius: DSRadius.allMd,
          border: Border.all(
            color: isSelected ? context.colors.primary : context.colors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DSIcon(icon, color: color, size: DSIconSize.md),
            const SizedBox(height: DSSpacing.xs),
            DSText(label, variant: DSTextVariant.labelSmall, color: color),
          ],
        ),
      ),
    );
  }
}
