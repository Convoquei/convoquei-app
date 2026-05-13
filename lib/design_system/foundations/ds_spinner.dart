// Spinner animado com a identidade visual do Convoquei (logo via CustomPaint).
//
// Exemplo:
//   DSSpinner()          // tamanho padrão 96
//   DSSpinner(size: 48)  // menor
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/ds_context_extensions.dart';
import '../tokens/ds_colors_primitive.dart';

class DSSpinner extends StatefulWidget {
  final double size;

  const DSSpinner({super.key, this.size = 96});

  @override
  State<DSSpinner> createState() => _DSSpinnerState();
}

class _DSSpinnerState extends State<DSSpinner> with TickerProviderStateMixin {
  late final AnimationController _spinCtrl;
  late final AnimationController _drawCtrl;

  late final Animation<double> _rotation;
  late final Animation<double> _drawProgress;
  late final Animation<double> _glowOpacity;
  late final Animation<double> _glowScale;

  late final double _arc1Length;
  late final double _arc2Length;
  late final Path _arc1Path;
  late final Path _arc2Path;

  @override
  void initState() {
    super.initState();

    _arc1Path = Path()
      ..moveTo(66, 31)
      ..arcToPoint(
        const Offset(26.5, 41.5),
        radius: const Radius.circular(25),
        largeArc: false,
        clockwise: false,
      );

    _arc2Path = Path()
      ..moveTo(26.5, 58.5)
      ..arcToPoint(
        const Offset(66, 69),
        radius: const Radius.circular(25),
        largeArc: false,
        clockwise: false,
      );

    _arc1Length = _arc1Path.computeMetrics().first.length;
    _arc2Length = _arc2Path.computeMetrics().first.length;

    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _rotation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _spinCtrl, curve: Curves.fastOutSlowIn),
    );

    _glowOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.10, end: 0.25), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.25, end: 0.10), weight: 50),
    ]).animate(CurvedAnimation(parent: _spinCtrl, curve: Curves.easeInOut));

    _glowScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.1), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 0.9), weight: 50),
    ]).animate(CurvedAnimation(parent: _spinCtrl, curve: Curves.easeInOut));

    _drawCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _drawProgress = CurvedAnimation(parent: _drawCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    _drawCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _spinCtrl,
              builder: (_, child) => Transform.scale(
                scale: _glowScale.value,
                child: Opacity(opacity: _glowOpacity.value, child: child),
              ),
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: widget.size * 0.65,
                  height: widget.size * 0.65,
                  decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
                ),
              ),
            ),
          ),
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _spinCtrl,
              builder: (_, _) => Transform.rotate(
                angle: _rotation.value,
                child: AnimatedBuilder(
                  animation: _drawCtrl,
                  builder: (_, _) => CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _ArcsPainter(
                      progress1: _drawProgress.value,
                      progress2: 1.0 - _drawProgress.value,
                      arc1Path: _arc1Path,
                      arc2Path: _arc2Path,
                      arc1Length: _arc1Length,
                      arc2Length: _arc2Length,
                      primaryColor: primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcsPainter extends CustomPainter {
  final double progress1;
  final double progress2;
  final Path arc1Path;
  final Path arc2Path;
  final double arc1Length;
  final double arc2Length;
  final Color primaryColor;

  const _ArcsPainter({
    required this.progress1,
    required this.progress2,
    required this.arc1Path,
    required this.arc2Path,
    required this.arc1Length,
    required this.arc2Length,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;

    canvas.save();
    canvas.scale(scale, scale);
    canvas.translate(3, 0);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    paint.color = primaryColor;
    _drawArc(canvas, arc1Path, arc1Length, progress1, paint);

    paint.color = DSColorsPrimitive.blue300;
    _drawArc(canvas, arc2Path, arc2Length, progress2, paint);

    canvas.restore();
  }

  void _drawArc(Canvas canvas, Path path, double length, double progress, Paint paint) {
    if (progress <= 0) return;
    final metric = path.computeMetrics().first;
    final segment = metric.extractPath(0, length * progress.clamp(0.0, 1.0));
    canvas.drawPath(segment, paint);
  }

  @override
  bool shouldRepaint(_ArcsPainter old) =>
      old.progress1 != progress1 ||
      old.progress2 != progress2 ||
      old.primaryColor != primaryColor;
}
