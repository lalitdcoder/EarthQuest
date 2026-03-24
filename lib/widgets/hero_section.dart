import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// The bespoke deep-earth hero at the top of the Home Screen.
class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with TickerProviderStateMixin {
  late final AnimationController _orbitCtrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _orbitCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.heroDeep,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top bar ──────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('EarthQuest', style: AppTextStyles.display),
                  const SizedBox(height: 2),
                  Text('Explore our solar system',
                      style: AppTextStyles.heroSub),
                ],
              ),
              // Avatar / profile chip
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: AppColors.accent, width: 2),
                  color: AppColors.heroDeep,
                ),
                child: const Center(
                  child: Text('🌍',
                      style: TextStyle(fontSize: 20)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ── Planet widget ─────────────────────────────────
          Center(child: _PlanetWidget(orbitCtrl: _orbitCtrl, pulse: _pulse)),

          const SizedBox(height: 28),

          // ── CTA button ────────────────────────────────────
          Center(
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🪐  ', style: TextStyle(fontSize: 16)),
                  Text(
                    'Open planet simulator',
                    style: AppTextStyles.cardTitle.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Planet widget — Stack + Opacity based
// ──────────────────────────────────────────────────────────────────────────────
class _PlanetWidget extends StatelessWidget {
  final AnimationController orbitCtrl;
  final Animation<double> pulse;

  const _PlanetWidget({required this.orbitCtrl, required this.pulse});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          ScaleTransition(
            scale: pulse,
            child: Opacity(
              opacity: 0.15,
              child: Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF6B9FFF),
                ),
              ),
            ),
          ),

          // Ring (ellipse behind planet)
          Opacity(
            opacity: 0.55,
            child: Container(
              width: 170,
              height: 52,
              decoration: BoxDecoration(
                border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.8),
                    width: 6),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),

          // Planet body
          ScaleTransition(
            scale: pulse,
            child: Container(
              width: 120,
              height: 120,
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
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Continent patches
                  Positioned(
                    top: 28,
                    left: 22,
                    child: Opacity(
                      opacity: 0.55,
                      child: Container(
                        width: 34,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 28,
                    right: 18,
                    child: Opacity(
                      opacity: 0.45,
                      child: Container(
                        width: 24,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  // Specular highlight
                  Positioned(
                    top: 14,
                    left: 18,
                    child: Opacity(
                      opacity: 0.35,
                      child: Container(
                        width: 32,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Orbiting satellite dot
          AnimatedBuilder(
            animation: orbitCtrl,
            builder: (context, _) {
              final angle = orbitCtrl.value * 2 * math.pi;
              const rx = 78.0, ry = 26.0;
              final dx = rx * math.cos(angle);
              final dy = ry * math.sin(angle);
              return Transform.translate(
                offset: Offset(dx, dy),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.6),
                        blurRadius: 6,
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
