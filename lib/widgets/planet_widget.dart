import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Shared planet widget used by [HeroSection] (small) and
/// [SimulatorScreen] (large, draggable).
///
/// [size]          — outer bounding box side length.
/// [orbitCtrl]     — drives the satellite's elliptical orbit.
/// [pulse]         — drives the subtle breathe/scale animation.
/// [rotationAngle] — rotates the planet surface (continent patches)
///                   around the Y-axis (simulated via Transform.rotate).
class PlanetWidget extends StatelessWidget {
  final double size;
  final AnimationController orbitCtrl;
  final Animation<double> pulse;
  final double rotationAngle; // radians — surface rotation

  const PlanetWidget({
    super.key,
    required this.size,
    required this.orbitCtrl,
    required this.pulse,
    this.rotationAngle = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    // Scale all internal measurements proportionally from the 200px reference.
    final s = size / 200.0;

    final planetDiameter = 120.0 * s;
    final ringW = 170.0 * s;
    final ringH = 52.0 * s;
    final ringBorder = 6.0 * s;
    final orbitRx = 78.0 * s;
    final orbitRy = 26.0 * s;
    final dotSize = 10.0 * s;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Outer atmospheric glow ────────────────────────
          ScaleTransition(
            scale: pulse,
            child: Opacity(
              opacity: 0.15,
              child: Container(
                width: size,
                height: size,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF6B9FFF),
                ),
              ),
            ),
          ),

          // ── Ring (ellipse, behind planet) ─────────────────
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

          // ── Planet body with surface rotation ─────────────
          ScaleTransition(
            scale: pulse,
            child: Container(
              width: planetDiameter,
              height: planetDiameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  center: Alignment(-0.35, -0.35),
                  radius: 0.9,
                  colors: [
                    Color(0xFF5B8DEF),
                    Color(0xFF2E5DB3),
                    Color(0xFF1A3A7A),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E5DB3).withValues(alpha: 0.5),
                    blurRadius: 24 * s,
                    spreadRadius: 2 * s,
                  ),
                ],
              ),
              // ClipOval keeps continent patches inside the sphere.
              child: ClipOval(
                child: Stack(
                  children: [
                    // Continent group — rotated around centre
                    Positioned.fill(
                      child: Transform.rotate(
                        angle: rotationAngle,
                        child: Stack(
                          children: [
                            // Continent A
                            Positioned(
                              top: 28 * s,
                              left: 22 * s,
                              child: Opacity(
                                opacity: 0.57,
                                child: Container(
                                  width: 34 * s,
                                  height: 22 * s,
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    borderRadius:
                                        BorderRadius.circular(10 * s),
                                  ),
                                ),
                              ),
                            ),
                            // Continent B
                            Positioned(
                              bottom: 28 * s,
                              right: 18 * s,
                              child: Opacity(
                                opacity: 0.47,
                                child: Container(
                                  width: 24 * s,
                                  height: 16 * s,
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    borderRadius:
                                        BorderRadius.circular(8 * s),
                                  ),
                                ),
                              ),
                            ),
                            // Continent C (extra detail for large view)
                            Positioned(
                              top: 60 * s,
                              right: 24 * s,
                              child: Opacity(
                                opacity: 0.35,
                                child: Container(
                                  width: 18 * s,
                                  height: 28 * s,
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    borderRadius:
                                        BorderRadius.circular(6 * s),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Specular highlight — fixed (doesn't rotate)
                    Positioned(
                      top: 14 * s,
                      left: 18 * s,
                      child: Opacity(
                        opacity: 0.35,
                        child: Container(
                          width: 32 * s,
                          height: 20 * s,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20 * s),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Orbiting satellite dot ────────────────────────
          AnimatedBuilder(
            animation: orbitCtrl,
            builder: (context, _) {
              final angle = orbitCtrl.value * 2 * math.pi;
              final dx = orbitRx * math.cos(angle);
              final dy = orbitRy * math.sin(angle);
              return Transform.translate(
                offset: Offset(dx, dy),
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
