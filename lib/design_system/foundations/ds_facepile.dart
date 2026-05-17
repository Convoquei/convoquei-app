// Pilha de avatares sobrepostos com contador de excedentes.
//
// Exemplo:
//   DSFacepile(
//     items: assigned.map((p) => (name: p.name, avatarUrl: p.avatarUrl)).toList(),
//     max: 3,
//     size: 28,
//   )
import 'package:flutter/material.dart';

import '../theme/ds_context_extensions.dart';
import '../tokens/ds_typography.dart';
import 'ds_avatar.dart';

class DSFacepile extends StatelessWidget {
  const DSFacepile({
    super.key,
    required this.items,
    this.max = 3,
    this.size = 28,
  });

  final List<({String? avatarUrl, String name})> items;
  final int max;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final shown = items.length > max ? items.sublist(0, max - 1) : items;
    final overflow = items.length > max ? items.length - (max - 1) : 0;
    final totalSlots = shown.length + (overflow > 0 ? 1 : 0);
    final overlap = size * 0.28;
    final totalWidth = size + (totalSlots - 1) * (size - overlap);

    return SizedBox(
      width: totalWidth,
      height: size,
      child: Stack(
        children: [
          ...shown.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            return Positioned(
              left: idx * (size - overlap),
              child: _BorderedAvatar(
                name: item.name,
                avatarUrl: item.avatarUrl,
                size: size,
              ),
            );
          }),
          if (overflow > 0)
            Positioned(
              left: shown.length * (size - overlap),
              child: _OverflowCircle(count: overflow, size: size, context: context),
            ),
        ],
      ),
    );
  }
}

class _BorderedAvatar extends StatelessWidget {
  const _BorderedAvatar({
    required this.name,
    this.avatarUrl,
    required this.size,
  });

  final String name;
  final String? avatarUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(1.5),
      child: ClipOval(
        child: DSAvatar(
          name: name,
          avatarUrl: avatarUrl,
          radius: (size - 3) / 2,
        ),
      ),
    );
  }
}

class _OverflowCircle extends StatelessWidget {
  const _OverflowCircle({
    required this.count,
    required this.size,
    required this.context,
  });

  final int count;
  final double size;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ctx.colors.surfaceSubtle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Center(
        child: Text(
          '+$count',
          style: TextStyle(
            fontFamily: DSTypography.bodyFamily,
            fontSize: size * 0.32,
            fontWeight: FontWeight.w600,
            color: ctx.colors.textSecondary,
            height: 1,
          ),
        ),
      ),
    );
  }
}
