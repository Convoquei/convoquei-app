// Bloco com animação shimmer para estados de carregamento (skeleton loading).
//
// Exemplo:
//   DSSkeleton(height: 48, borderRadius: DSRadius.md)
//   DSSkeleton(width: 120, height: 14)
import 'package:flutter/material.dart';

import '../tokens/ds_radius.dart';
import '../theme/ds_context_extensions.dart';

class DSSkeleton extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const DSSkeleton({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = DSRadius.md,
  });

  @override
  State<DSSkeleton> createState() => _DSSkeletonState();
}

class _DSSkeletonState extends State<DSSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = context.colors.surfaceSubtle;
    final highlight = context.colors.border;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(base, highlight, _ctrl.value),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}
