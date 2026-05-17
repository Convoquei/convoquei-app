import 'package:convoquei_app/design_system/ds.dart';
import 'package:convoquei_app/features/profile/providers/theme_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemePickerSheet extends DSBaseModal {
  const ThemePickerSheet({super.key});

  static Future<void> show(BuildContext context) async {
    await DSBaseModal.show(context, const ThemePickerSheet());
  }

  @override
  State<ThemePickerSheet> createState() => _ThemePickerSheetState();
}

class _ThemePickerSheetState extends DSBaseModalState<ThemePickerSheet> {
  @override
  String? get titleText => 'Aparência';

  @override
  List<Widget> buildBody(BuildContext context) {
    return [
      Consumer(
        builder: (context, ref, _) {
          final current = ref.watch(themeModeProvider);
          return Padding(
            padding: const EdgeInsets.fromLTRB(
              DSSpacing.lg,
              0,
              DSSpacing.lg,
              DSSpacing.lg,
            ),
            child: DSCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  DSSelectableTile(
                    title: 'Claro',
                    isSelected: current == ThemeMode.light,
                    onTap: () async {
                      await ref
                          .read(themeModeProvider.notifier)
                          .set(ThemeMode.light);
                      if (context.mounted) DSModal.hide(context);
                    },
                  ),
                  const DSDivider(),
                  DSSelectableTile(
                    title: 'Escuro',
                    isSelected: current == ThemeMode.dark,
                    onTap: () async {
                      await ref
                          .read(themeModeProvider.notifier)
                          .set(ThemeMode.dark);
                      if (context.mounted) DSModal.hide(context);
                    },
                  ),
                  const DSDivider(),
                  DSSelectableTile(
                    title: 'Automático (sistema)',
                    isSelected: current == ThemeMode.system,
                    onTap: () async {
                      await ref
                          .read(themeModeProvider.notifier)
                          .set(ThemeMode.system);
                      if (context.mounted) DSModal.hide(context);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ];
  }
}
