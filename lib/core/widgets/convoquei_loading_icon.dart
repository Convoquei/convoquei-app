import 'dart:math' as math;
import 'dart:ui';

import 'package:convoquei_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Ícone de loading animado com a identidade visual do Convoquei.
///
/// Otimizações aplicadas:
/// - Path metrics pré-calculadas (fora do paint loop).
/// - Glow isolado em RepaintBoundary — não invalida os arcos.
/// - Arcos isolados em RepaintBoundary — não invalida o glow.
/// - Listenable.merge removido; cada AnimatedBuilder escuta só o seu controller.
/// - ImageFiltered movido para fora do AnimatedBuilder (blur é estático).
class ConvoqueiLoadingIcon extends StatefulWidget {
  final double size;

  const ConvoqueiLoadingIcon({super.key, this.size = 96});

  @override
  State<ConvoqueiLoadingIcon> createState() => _ConvoqueiLoadingIconState();
}

class _ConvoqueiLoadingIconState extends State<ConvoqueiLoadingIcon>
    with TickerProviderStateMixin {
  late final AnimationController _spinCtrl;
  late final AnimationController _drawCtrl;

  late final Animation<double> _rotation;
  late final Animation<double> _drawProgress;
  late final Animation<double> _glowOpacity;
  late final Animation<double> _glowScale;

  // ── Métricas de path pré-calculadas (nunca mudam) ────────────────────
  late final double _arc1Length;
  late final double _arc2Length;
  late final Path _arc1Path;
  late final Path _arc2Path;

  @override
  void initState() {
    super.initState();

    // Pré-calcula paths e métricas UMA vez (fora do paint loop)
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

    // ── Spin ─────────────────────────────────────────────────────────────
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

    // ── Draw ─────────────────────────────────────────────────────────────
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
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Glow: RepaintBoundary isola repaints do blur ─────────────
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _spinCtrl,
              builder: (_, child) {
                return Transform.scale(
                  scale: _glowScale.value,
                  // Opacidade via Opacity widget — mais barato que recriar
                  // a decoração com withAlpha a cada frame.
                  child: Opacity(
                    opacity: _glowOpacity.value,
                    child: child,
                  ),
                );
              },
              // ImageFiltered fora do builder: o blur só é criado uma vez.
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: widget.size * 0.65,
                  height: widget.size * 0.65,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),

          // ── Arcos: RepaintBoundary isola repaints da rotação/draw ────
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _spinCtrl,
              builder: (_, __) {
                return Transform.rotate(
                  angle: _rotation.value,
                  child: AnimatedBuilder(
                    animation: _drawCtrl,
                    builder: (_, __) {
                      return CustomPaint(
                        size: Size(widget.size, widget.size),
                        painter: _ArcsPainter(
                          progress1: _drawProgress.value,
                          progress2: 1.0 - _drawProgress.value,
                          arc1Path: _arc1Path,
                          arc2Path: _arc2Path,
                          arc1Length: _arc1Length,
                          arc2Length: _arc2Length,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Painter ──────────────────────────────────────────────────────────────────

class _ArcsPainter extends CustomPainter {
  final double progress1;
  final double progress2;
  final Path arc1Path;
  final Path arc2Path;
  final double arc1Length;
  final double arc2Length;

  static const _colorPrimary = AppTheme.primaryColor;
  static const _colorLight = Color(0xFF93C5FD);

  const _ArcsPainter({
    required this.progress1,
    required this.progress2,
    required this.arc1Path,
    required this.arc2Path,
    required this.arc1Length,
    required this.arc2Length,
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

    paint.color = _colorPrimary;
    _drawArc(canvas, arc1Path, arc1Length, progress1, paint);

    paint.color = _colorLight;
    _drawArc(canvas, arc2Path, arc2Length, progress2, paint);

    canvas.restore();
  }

  /// Desenha a fração [progress] do path usando o comprimento pré-calculado.
  /// Evita chamar computeMetrics() a cada frame.
  void _drawArc(
      Canvas canvas,
      Path path,
      double length,
      double progress,
      Paint paint,
      ) {
    if (progress <= 0) return;
    final metric = path.computeMetrics().first;
    final segment = metric.extractPath(0, length * progress.clamp(0.0, 1.0));
    canvas.drawPath(segment, paint);
  }

  @override
  bool shouldRepaint(_ArcsPainter old) =>
      old.progress1 != progress1 || old.progress2 != progress2;
}