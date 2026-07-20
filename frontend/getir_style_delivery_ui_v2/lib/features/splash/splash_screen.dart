import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/getir_style_delivery_ui_logo_mark.dart';

/// Getir-style launch splash — full purple screen with a bouncing brand mark.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entry;
  late final AnimationController _pulse;
  late final AnimationController _exit;
  late final AnimationController _heart;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final Animation<double> _exitFade;
  late final Animation<double> _exitScale;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _exit = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _heart = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _scale = Tween<double>(begin: 0.35, end: 1).animate(
      CurvedAnimation(parent: _entry, curve: Curves.elasticOut),
    );
    _fade = CurvedAnimation(
      parent: _entry,
      curve: const Interval(0, 0.55, curve: Curves.easeOut),
    );
    _exitFade = CurvedAnimation(parent: _exit, curve: Curves.easeIn);
    _exitScale = Tween<double>(begin: 1, end: 1.12).animate(
      CurvedAnimation(parent: _exit, curve: Curves.easeInCubic),
    );

    _entry.forward();
  }

  /// Stroke reveal 0→1, brief hold, then erase 1→0 before the next loop.
  static double _heartStrokeProgress(double t) {
    const drawEnd = 0.38;
    const holdEnd = 0.46;
    if (t <= drawEnd) {
      return Curves.easeInOutCubic.transform(t / drawEnd);
    }
    if (t <= holdEnd) return 1;
    final erase = (t - holdEnd) / (1 - holdEnd);
    return 1 - Curves.easeInCubic.transform(erase);
  }

  static double _heartOpacity(double t) {
    const holdEnd = 0.46;
    if (t <= holdEnd) return 1;
    final fade = (t - holdEnd) / (1 - holdEnd);
    return 1 - Curves.easeIn.transform(fade);
  }

  /// Zoom-fade out before revealing the main app.
  Future<void> playExit() => _exit.forward();

  @override
  void dispose() {
    _entry.dispose();
    _pulse.dispose();
    _exit.dispose();
    _heart.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tagline = AppLocalizations.of(context).appTagline;

    return Material(
      color: GetirStyleDeliveryUiColors.primary,
      child: AnimatedBuilder(
        animation: Listenable.merge([_entry, _exit, _pulse, _heart]),
        builder: (context, child) {
          final entryOpacity = _fade.value * (1 - _exitFade.value);
          final scale = _scale.value * _exitScale.value;
          final heartT = _heart.value;
          final heartProgress = _heartStrokeProgress(heartT);
          final heartOpacity =
              _heartOpacity(heartT) * (1 - _exitFade.value).clamp(0.0, 1.0);

          return Opacity(
            opacity: 1 - _exitFade.value,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _SplashBackdrop(pulse: _pulse.value),
                _HeartLineOverlay(
                  progress: heartProgress,
                  opacity: heartOpacity,
                ),
                Center(
                  child: Opacity(
                    opacity: entryOpacity.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: scale,
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        child: GetirStyleDeliveryUiLogoMark(
          showTagline: true,
          tagline: tagline,
        ),
      ),
    );
  }
}

class _SplashBackdrop extends StatelessWidget {
  const _SplashBackdrop({required this.pulse});

  final double pulse;

  @override
  Widget build(BuildContext context) {
    final glow = 0.10 + pulse * 0.06;
    return Stack(
      children: [
        Positioned(
          top: -120,
          right: -90,
          child: _GlowBlob(
            size: 300,
            color: GetirStyleDeliveryUiColors.secondaryContainer.withValues(alpha: glow),
          ),
        ),
        Positioned(
          bottom: -80,
          left: -60,
          child: _GlowBlob(
            size: 220,
            color: GetirStyleDeliveryUiColors.primaryContainer.withValues(alpha: 0.35),
          ),
        ),
        Positioned(
          top: MediaQuery.sizeOf(context).height * 0.18,
          left: -40,
          child: Transform.rotate(
            angle: -math.pi / 7,
            child: _GlowBlob(
              size: 140,
              color: GetirStyleDeliveryUiColors.onPrimary.withValues(alpha: 0.04 + pulse * 0.02),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

/// Yellow stroke heart that sweeps across the splash — Getir-style accent line.
class _HeartLineOverlay extends StatelessWidget {
  const _HeartLineOverlay({
    required this.progress,
    required this.opacity,
  });

  final double progress;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    if (opacity <= 0.001 || progress <= 0.001) {
      return const SizedBox.expand();
    }

    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: CustomPaint(
          painter: _HeartLinePainter(progress: progress),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _HeartLinePainter extends CustomPainter {
  _HeartLinePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.001) return;

    final scale = math.max(size.width, size.height) * 0.72;
    final cx = size.width * 0.48;
    final cy = size.height * 0.5;
    final top = cy - scale * 0.18;

    final heart = Path()
      ..moveTo(cx, top + scale * 0.30)
      ..cubicTo(
        cx - scale * 0.52,
        top - scale * 0.02,
        cx - scale * 0.54,
        top + scale * 0.40,
        cx,
        top + scale * 0.64,
      )
      ..cubicTo(
        cx + scale * 0.54,
        top + scale * 0.40,
        cx + scale * 0.52,
        top - scale * 0.02,
        cx,
        top + scale * 0.30,
      )
      ..close();

    canvas.save();
    canvas.translate(size.width * 0.03, size.height * 0.02);
    canvas.rotate(-0.22);

    final metrics = heart.computeMetrics();
    final drawn = Path();
    for (final metric in metrics) {
      drawn.addPath(
        metric.extractPath(0, metric.length * progress),
        Offset.zero,
      );
    }

    final stroke = math.max(3.5, size.shortestSide * 0.011);
    canvas.drawPath(
      drawn,
      Paint()
        ..color = GetirStyleDeliveryUiColors.secondaryContainer
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HeartLinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
