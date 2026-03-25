// lib/widgets/planet_widget.dart
//
// Architecture:
//  • LottiePlanetWidget — the new health-reactive Lottie layer.
//    Drop your own Lottie file at assets/lottie/planet_health.json.
//    The animation is SCRUBBED (not played): value 0.0 = frame 0 (lush),
//    value 1.0 = final frame (degraded/arid). The Lottie AnimationController
//    is driven by a TweenAnimationBuilder so transitions are smooth.
//
//  • PlanetWidget — public API is UNCHANGED so every existing call site works.
//    Internally it composes LottiePlanetWidget + orbital satellite + ring.
//    An optional [healthScore] param (0–100) determines how far to scrub.
//    When healthScore is low the atmospheric glow colour shifts warm-orange.
//
//  • _SmogOverlay — a pure-Canvas overlay that paints a hazy vignette.
//    Opacity is 0 when health ≥ 70, ramps linearly to 0.45 at health = 0.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants
// ─────────────────────────────────────────────────────────────────────────────

/// Asset path for the bundled planet Lottie file.
/// Replace with your own file — this path is the only thing to change.
const _kLottieAsset = 'assets/lottie/planet_health.json';

/// Health score (0–100) above which there is zero smog.
const _kSmogThreshold = 70.0;

// ─────────────────────────────────────────────────────────────────────────────
// Public PlanetWidget — same API as before
// ─────────────────────────────────────────────────────────────────────────────

class PlanetWidget extends StatelessWidget {
  final double size;
  final AnimationController orbitCtrl;
  final Animation<double> pulse;
  final double rotationAngle;

  /// 0–100 composite health score from [EarthMetrics].
  /// 0 = arid/degraded (Lottie end-frame), 100 = lush (Lottie frame 0).
  /// Defaults to [EarthMetrics.initial.healthScore] (62).
  final double healthScore;

  const PlanetWidget({
    super.key,
    required this.size,
    required this.orbitCtrl,
    required this.pulse,
    this.rotationAngle = 0.0,
    this.healthScore = 62.0,
  });

  @override
  Widget build(BuildContext context) {
    final s = size / 200.0;

    final ringW     = 170.0 * s;
    final ringH     = 52.0  * s;
    final ringBorder = 6.0  * s;
    final orbitRx   = 78.0  * s;
    final orbitRy   = 26.0  * s;
    final dotSize   = 10.0  * s;

    // Smog opacity: 0 when health ≥ 70, maxes at 0.45 when health = 0
    final smogOpacity = healthScore >= _kSmogThreshold
        ? 0.0
        : ((_kSmogThreshold - healthScore) / _kSmogThreshold * 0.45)
            .clamp(0.0, 0.45);

    // Glow colour: lerp from cool blue → warm orange as health degrades
    final glowColor = Color.lerp(
      const Color(0xFF6B9FFF),
      const Color(0xFFE07B39),
      ((100 - healthScore) / 100).clamp(0.0, 1.0),
    )!;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Atmospheric glow (colour-shifts with health) ──
          ScaleTransition(
            scale: pulse,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: glowColor.withValues(alpha: 0.15),
              ),
            ),
          ),

          // ── Ring (behind planet) ──────────────────────────
          Opacity(
            opacity: 0.55,
            child: Container(
              width: ringW,
              height: ringH,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.8),
                  width: ringBorder,
                ),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),

          // ── Lottie planet (scrubbed by healthScore) ────────
          ScaleTransition(
            scale: pulse,
            child: ClipOval(
              child: SizedBox(
                width: size * 0.60,
                height: size * 0.60,
                child: Transform.rotate(
                  angle: rotationAngle,
                  child: LottiePlanet(
                    size: size * 0.60,
                    healthScore: healthScore,
                  ),
                ),
              ),
            ),
          ),

          // ── Smog overlay (orange vignette when unhealthy) ─
          if (smogOpacity > 0)
            ClipOval(
              child: SizedBox(
                width: size * 0.60,
                height: size * 0.60,
                child: CustomPaint(
                  painter: _SmogPainter(opacity: smogOpacity),
                ),
              ),
            ),

          // ── Orbiting satellite dot ────────────────────────
          AnimatedBuilder(
            animation: orbitCtrl,
            builder: (_, __) {
              final angle = orbitCtrl.value * 2 * math.pi;
              return Transform.translate(
                offset: Offset(
                  orbitRx * math.cos(angle),
                  orbitRy * math.sin(angle),
                ),
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.6),
                        blurRadius: 6 * s,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LottiePlanet — isolated StatefulWidget that owns the AnimationController
// and scrubs it based on [healthScore] via TweenAnimationBuilder.
// ─────────────────────────────────────────────────────────────────────────────

class LottiePlanet extends StatefulWidget {
  final double size;
  final double healthScore; // 0–100

  const LottiePlanet({
    super.key,
    required this.size,
    required this.healthScore,
  });

  @override
  State<LottiePlanet> createState() => _LottiePlanetState();
}

class _LottiePlanetState extends State<LottiePlanet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottieCtrl;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    // We manage the controller manually — we DON'T call repeat/forward.
    // Instead we set .value directly from healthScore during build.
    _lottieCtrl = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _lottieCtrl.dispose();
    super.dispose();
  }

  /// healthScore 100 → progress 0.0 (lush frame)
  /// healthScore 0   → progress 1.0 (arid frame)
  double get _targetProgress =>
      ((100.0 - widget.healthScore) / 100.0).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: _targetProgress, end: _targetProgress),
      // Smooth 600ms transition between health states
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, progress, _) {
        // Scrub the Lottie timeline — only if it's been loaded
        if (_loaded && _lottieCtrl.isAnimating == false) {
          _lottieCtrl.value = progress.clamp(0.0, 1.0);
        }
        return Lottie.asset(
          _kLottieAsset,
          controller: _lottieCtrl,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
          frameRate: FrameRate.max,
          onLoaded: (composition) {
            _lottieCtrl.duration = composition.duration;
            _lottieCtrl.value = _targetProgress.clamp(0.0, 1.0);
            setState(() => _loaded = true);
          },
          errorBuilder: (context, error, stack) {
            // Graceful fallback: render the procedural planet painter
            return CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _FallbackPlanetPainter(
                health: widget.healthScore / 100.0,
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fallback procedural planet — used if Lottie asset fails to load
// ─────────────────────────────────────────────────────────────────────────────

class _FallbackPlanetPainter extends CustomPainter {
  final double health; // 0.0–1.0

  const _FallbackPlanetPainter({required this.health});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Ocean: lerp blue → arid brown
    final oceanColor = Color.lerp(
      const Color(0xFF2E5DB3),
      const Color(0xFF5C3010),
      1.0 - health,
    )!;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.35),
          radius: 0.9,
          colors: [
            Color.lerp(const Color(0xFF5B8DEF), oceanColor, 1 - health)!,
            oceanColor,
            Color.lerp(oceanColor, Colors.black, 0.3)!,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );

    // Continents
    final landColor = Color.lerp(
      const Color(0xFF2D9E57), // lush green
      const Color(0xFF8A5020), // arid brown
      1.0 - health,
    )!;
    final landPaint = Paint()..color = landColor.withValues(alpha: 0.6);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - 22, center.dy - 15),
        width: size.width * 0.34,
        height: size.height * 0.22,
      ),
      landPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + 20, center.dy + 20),
        width: size.width * 0.24,
        height: size.height * 0.16,
      ),
      landPaint..color = landColor.withValues(alpha: 0.45),
    );

    // Specular
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - 18, center.dy - 18),
        width: size.width * 0.26,
        height: size.height * 0.16,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.28),
    );
  }

  @override
  bool shouldRepaint(_FallbackPlanetPainter old) => old.health != health;
}

// ─────────────────────────────────────────────────────────────────────────────
// Smog overlay — warm orange-brown vignette inside the planet sphere
// ─────────────────────────────────────────────────────────────────────────────

class _SmogPainter extends CustomPainter {
  final double opacity;
  const _SmogPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.9,
          colors: [
            Colors.transparent,
            const Color(0xFFE07B39).withValues(alpha: opacity),
          ],
          stops: const [0.4, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(_SmogPainter old) => old.opacity != opacity;
}
