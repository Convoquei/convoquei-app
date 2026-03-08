import 'package:flutter/material.dart';

class TimelineGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const TimelineGroup({super.key, required this.title, required this.children});

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
            const SizedBox(width: 12),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 4),
        ...children,
      ],
    );
  }
}
