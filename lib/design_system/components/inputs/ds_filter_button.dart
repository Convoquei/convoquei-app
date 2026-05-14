// Botão de filtro que abre um bottom-sheet com seções fornecidas pelo chamador.
// O builder é lazy — chamado no momento da abertura do sheet.
//
// Exemplo:
//   DSFilterButton(
//     isActive: _hasFilters,
//     title: 'Filtrar Eventos',
//     onClear: _clear,
//     onApply: _apply,
//     childrenBuilder: () => [
//       DSFilterSection(title: 'Status', child: Wrap(children: [...])),
//     ],
//   )
import 'package:flutter/material.dart';

import '../../theme/ds_context_extensions.dart';
import '../../tokens/ds_motion.dart';
import '../../tokens/ds_radius.dart';
import '../../tokens/ds_spacing.dart';
import '../buttons/ds_button.dart';

class DSFilterButton extends StatelessWidget {
  const DSFilterButton({
    super.key,
    required this.childrenBuilder,
    required this.onClear,
    required this.onApply,
    this.isActive = false,
    this.title = 'Filtros',
  });

  final List<Widget> Function() childrenBuilder;
  final bool isActive;
  final VoidCallback onClear;
  final VoidCallback onApply;
  final String title;

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DSFilterSheet(
        title: title,
        children: childrenBuilder(),
        onClear: () {
          onClear();
          Navigator.of(context).pop();
        },
        onApply: () {
          onApply();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: () => _openSheet(context),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive ? colors.primary.withValues(alpha: 0.08) : colors.surface,
          borderRadius: DSRadius.allMd,
          border: Border.all(
            color: isActive ? colors.primary : colors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.tune_rounded,
              size: 20,
              color: isActive ? colors.primary : colors.textSecondary,
            ),
            if (isActive)
              Positioned(
                top: 9,
                right: 9,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DSFilterSheet extends StatelessWidget {
  const _DSFilterSheet({
    required this.title,
    required this.children,
    required this.onClear,
    required this.onApply,
  });

  final String title;
  final List<Widget> children;
  final VoidCallback onClear;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: DSSpacing.md),
                child: Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  DSSpacing.xl,
                  0,
                  DSSpacing.lg,
                  DSSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: colors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: colors.textSecondary,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: colors.divider),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    DSSpacing.xl,
                    DSSpacing.lg,
                    DSSpacing.xl,
                    DSSpacing.sm,
                  ),
                  children: children
                      .expand((child) => [child, const SizedBox(height: DSSpacing.xl)])
                      .toList(),
                ),
              ),
              Divider(height: 1, color: colors.divider),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  DSSpacing.xl,
                  DSSpacing.md,
                  DSSpacing.xl,
                  DSSpacing.xxl,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 110,
                      child: DSButton(
                        label: 'Limpar',
                        outlined: true,
                        schema: DSButtonSchema.ghost,
                        onPressed: onClear,
                      ),
                    ),
                    const SizedBox(width: DSSpacing.md),
                    Expanded(
                      child: DSButton(label: 'Aplicar Filtros', onPressed: onApply),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Seção de filtro com título em caixa alta e conteúdo livre (chips, pickers, etc.).
class DSFilterSection extends StatelessWidget {
  const DSFilterSection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: context.textStyles.labelSmall.copyWith(
            color: context.colors.textSecondary,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: DSSpacing.sm + 2),
        child,
      ],
    );
  }
}

/// Chip selecionável para uso dentro de [DSFilterSection].
class DSFilterChip extends StatelessWidget {
  const DSFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: () => onSelected(!selected),
      child: AnimatedContainer(
        duration: DSMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.surface,
          borderRadius: DSRadius.all(20),
          border: Border.all(
            color: selected ? colors.primary : colors.border,
          ),
        ),
        child: Text(
          label,
          style: context.textStyles.labelMedium.copyWith(
            color: selected ? colors.onPrimary : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
