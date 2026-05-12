import 'package:flutter/material.dart';

class ExpandedCard extends StatefulWidget {
  const ExpandedCard({
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
  State<ExpandedCard> createState() => _ExpandedCardState();
}

class _ExpandedCardState extends State<ExpandedCard> {
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                        height: 1.2,
                      ),
                    ),
                    if (descriptionWidget != null || description != null) ...[
                      const SizedBox(height: 4),
                      descriptionWidget ??
                          Text(
                            description!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                    ],
                  ],
                ),
              ),
              AnimatedRotation(
                turns: expanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF94A3B8),
                ),
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
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...children,
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(children: actions),
          ],
        ],
      ),
    );
  }
}