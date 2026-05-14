// Card expansível com header clicável (leading + title + description + chevron)
// e body animado com children e actions.
//
// Exemplo:
//   DSExpandableCard(
//     leading: DSAvatar(name: 'João'),
//     title: 'João Silva',
//     description: '3 eventos',
//     children: [MyContent()],
//     actions: [DSButton(label: 'Editar', onPressed: _edit)],
//   )
import 'package:flutter/material.dart';

import '../../foundations/ds_icon.dart';
import '../../theme/ds_context_extensions.dart';
import '../../tokens/ds_elevation.dart';
import '../../tokens/ds_motion.dart';
import '../../tokens/ds_radius.dart';
import '../../tokens/ds_spacing.dart';

class DSExpandableCard extends StatefulWidget {
  const DSExpandableCard({
    super.key,
    required this.leading,
    required this.title,
    this.description,
    this.descriptionWidget,
    this.children = const [],
    this.actions = const [],
    this.initiallyExpanded = false,
    this.onExpand,
  });

  final Widget leading;
  final String title;

  /// Texto exibido abaixo do título. Ignorado se [descriptionWidget] for fornecido.
  final String? description;

  /// Substitui [description] quando fornecido. Útil para tags, badges, etc.
  final Widget? descriptionWidget;

  final List<Widget> children;

  /// Widgets placed in a [Row] at the bottom of the expanded body.
  final List<Widget> actions;
  final bool initiallyExpanded;

  /// Called every time the card is expanded.
  final VoidCallback? onExpand;

  @override
  State<DSExpandableCard> createState() => _DSExpandableCardState();
}

class _DSExpandableCardState extends State<DSExpandableCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    if (_expanded) widget.onExpand?.call();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) widget.onExpand?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: DSRadius.allLg,
        border: Border.all(color: colors.border),
        boxShadow: DSElevation.sm,
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Header(
            leading: widget.leading,
            title: widget.title,
            description: widget.description,
            descriptionWidget: widget.descriptionWidget,
            expanded: _expanded,
            onTap: _toggle,
          ),
          AnimatedSize(
            duration: DSMotion.normal,
            curve: DSMotion.standard,
            child: _expanded
                ? _Body(actions: widget.actions, children: widget.children)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.leading,
    required this.title,
    this.description,
    required this.expanded,
    required this.onTap,
    this.descriptionWidget,
  });

  final Widget leading;
  final String title;
  final String? description;
  final Widget? descriptionWidget;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.lg,
            vertical: 14,
          ),
          child: Row(
            children: [
              leading,
              const SizedBox(width: DSSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textStyles.titleSmall.copyWith(
                        color: colors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    if (descriptionWidget != null || description != null) ...[
                      const SizedBox(height: DSSpacing.xs),
                      descriptionWidget ??
                          Text(
                            description!,
                            style: textStyles.labelSmall.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                    ],
                  ],
                ),
              ),
              AnimatedRotation(
                turns: expanded ? 0.5 : 0.0,
                duration: DSMotion.normal,
                child: DSIcon(Icons.keyboard_arrow_down_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({required this.children, required this.actions});

  final List<Widget> children;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...children,
          if (actions.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            Row(children: actions),
          ],
        ],
      ),
    );
  }
}
