// Agrupador de itens por seção com título e divisor. Anteriormente: TimelineGroup.
//
// Exemplo:
//   DSTimelineGroup(title: 'Março 2025', children: [EventCard(...)])
import 'package:flutter/material.dart';

import '../../tokens/ds_spacing.dart';

class DSTimelineGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const DSTimelineGroup({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
            ),
            const SizedBox(width: DSSpacing.md),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: DSSpacing.xs),
        ...children,
      ],
    );
  }
}
