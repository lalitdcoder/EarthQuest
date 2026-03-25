// lib/widgets/act_card.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/earth_metrics.dart';
import '../providers/earth_state_notifier.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Particle system
// ─────────────────────────────────────────────────────────────────────────────

/// A single leaf/spark particle emitted on habit completion.
class _Particle {
  Offset position;
  Offset velocity;
  double radius;
  Color color;
  double life; // 0.0 – 1.0, decrements per frame
  double decay;

  _Particle({
    required this.position,
    required this.velocity,
    required this.radius,
    required this.color,
    required this.life,
    required this.decay,
  });
}

class _ParticlesPainter extends CustomPainter {
  final List<_Particle> particles;
  _ParticlesPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.life.clamp(0, 1))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p.position, p.radius * p.life, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlesPainter old) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// ActCard
// ─────────────────────────────────────────────────────────────────────────────

/// "Today's Quest" card — live data from [earthStateProvider], animated
/// progress bar, pulsing streak badge at streak > 7, particle burst on
/// habit completion.
class ActCard extends ConsumerStatefulWidget {
  const ActCard({super.key});

  @override
  ConsumerState<ActCard> createState() => _ActCardState();
}

class _ActCardState extends ConsumerState<ActCard>
    with TickerProviderStateMixin {
  // ── Streak badge glow pulse ──────────────────────────────────────────────
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  // ── Card press ──────────────────────────────────────────────────────────
  bool _pressed = false;

  // ── Particle system ─────────────────────────────────────────────────────
  late final AnimationController _particleCtrl;
  final List<_Particle> _particles = [];
  final _rng = math.Random();

  // ── Check-mark reveal ───────────────────────────────────────────────────
  late final AnimationController _checkCtrl;
  late final Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..addListener(_tickParticles);

    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _checkScale = CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _particleCtrl.dispose();
    _checkCtrl.dispose();
    super.dispose();
  }

  // ── Particle helpers ─────────────────────────────────────────────────────

  static const _particleColors = [
    AppColors.success,
    AppColors.accent,
    Color(0xFF7EC8A4),
    Color(0xFFFFD580),
    Color(0xFFA8E6CF),
  ];

  void _spawnParticles(Offset origin) {
    _particles.clear();
    for (var i = 0; i < 28; i++) {
      final angle = _rng.nextDouble() * 2 * math.pi;
      final speed = 1.5 + _rng.nextDouble() * 3.5;
      _particles.add(_Particle(
        position: origin,
        velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed - 2),
        radius: 3 + _rng.nextDouble() * 4,
        color: _particleColors[_rng.nextInt(_particleColors.length)],
        life: 1.0,
        decay: 0.018 + _rng.nextDouble() * 0.012,
      ));
    }
    _particleCtrl
      ..reset()
      ..forward();
  }

  void _tickParticles() {
    setState(() {
      for (final p in _particles) {
        p.position += p.velocity;
        p.velocity = Offset(p.velocity.dx * 0.95, p.velocity.dy + 0.12);
        p.life -= p.decay;
      }
      _particles.removeWhere((p) => p.life <= 0);
    });
  }

  // ── Action ───────────────────────────────────────────────────────────────

  Future<void> _onTap(bool alreadyDone, Offset tapOrigin) async {
    if (alreadyDone) return;
    HapticFeedback.heavyImpact();
    _spawnParticles(tapOrigin);
    await Future.delayed(const Duration(milliseconds: 80));
    HapticFeedback.mediumImpact();
    _checkCtrl.forward(from: 0);
    await ref.read(earthStateProvider.notifier).completeDailyHabit();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(earthStateProvider);
    final stats = state.userStats;
    final health = state.metrics.healthScore;
    final streak = stats.currentStreak;
    final done = state.dailyHabitDone;

    // Progress value: map health score 62 → 100 → 0.0 → 1.0
    final progress = ((health - EarthMetrics.initial.healthScore) /
            (100 - EarthMetrics.initial.healthScore))
        .clamp(0.0, 1.0);

    final hotStreak = streak > 7;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Main card ──────────────────────────────────────────
        GestureDetector(
          onTapDown: (d) {
            if (!done) setState(() => _pressed = true);
          },
          onTapUp: (d) {
            setState(() => _pressed = false);
            final box = context.findRenderObject() as RenderBox;
            final local = box.globalToLocal(d.globalPosition);
            _onTap(done, local);
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.975 : 1.0,
            duration: const Duration(milliseconds: 110),
            curve: Curves.easeOut,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: done
                    ? AppColors.learnTint
                    : AppColors.cardLight,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: done
                      ? AppColors.success.withValues(alpha: 0.35)
                      : AppColors.border,
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: done
                        ? AppColors.success.withValues(alpha: 0.12)
                        : AppColors.heroDeep.withValues(alpha: 0.06),
                    blurRadius: done ? 18 : 10,
                    spreadRadius: done ? 2 : 1,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Icon / done check ─────────────────────
                    _IconBox(done: done, checkScale: _checkScale),

                    const SizedBox(width: 14),

                    // ── Content ───────────────────────────────
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                done
                                    ? "Today's Quest"
                                    : "Today's Quest",
                                style: AppTextStyles.sectionTitle,
                              ),
                              if (done) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.success
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '+25 XP',
                                    style: AppTextStyles.cardMeta.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ]
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            done
                                ? 'Completed · +25 XP earned'
                                : 'Plate tectonics · Tap to complete',
                            style: AppTextStyles.cardMeta,
                          ),
                          const SizedBox(height: 9),

                          // ── Animated progress bar ──────────
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: progress),
                            duration: const Duration(milliseconds: 900),
                            curve: Curves.easeOutCubic,
                            builder: (context, val, _) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Stack(
                                      children: [
                                        // Track
                                        Container(
                                          height: 6,
                                          color: AppColors.border,
                                        ),
                                        // Fill
                                        FractionallySizedBox(
                                          widthFactor: val,
                                          child: Container(
                                            height: 6,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  AppColors.success,
                                                  const Color(0xFF52C07F),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    done
                                        ? 'Earth health: ${health.toStringAsFixed(0)}%'
                                        : '${(val * 100).toStringAsFixed(0)}% earth health restored',
                                    style: AppTextStyles.sectionSub,
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 14),

                    // ── Streak badge ──────────────────────────
                    _StreakBadge(
                      streak: streak,
                      hotStreak: hotStreak,
                      glowAnim: _glowAnim,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Particle overlay ──────────────────────────────────
        if (_particles.isNotEmpty)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _ParticlesPainter(List.of(_particles)),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Icon / checkmark box
// ─────────────────────────────────────────────────────────────────────────────
class _IconBox extends StatelessWidget {
  final bool done;
  final Animation<double> checkScale;

  const _IconBox({required this.done, required this.checkScale});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: done
            ? AppColors.success.withValues(alpha: 0.12)
            : AppColors.playTint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: done
              ? AppColors.success.withValues(alpha: 0.4)
              : AppColors.border,
          width: 0.5,
        ),
      ),
      child: Center(
        child: done
            ? ScaleTransition(
                scale: checkScale,
                child: const Text('✅', style: TextStyle(fontSize: 24)),
              )
            : const Text('🌋', style: TextStyle(fontSize: 26)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Streak badge with optional pulsing glow
// ─────────────────────────────────────────────────────────────────────────────
class _StreakBadge extends StatelessWidget {
  final int streak;
  final bool hotStreak;
  final Animation<double> glowAnim;

  const _StreakBadge({
    required this.streak,
    required this.hotStreak,
    required this.glowAnim,
  });

  @override
  Widget build(BuildContext context) {
    if (!hotStreak) {
      return _BadgeBox(streak: streak, glowIntensity: 0);
    }
    // Pulsing glow when streak > 7
    return AnimatedBuilder(
      animation: glowAnim,
      builder: (_, __) => _BadgeBox(
        streak: streak,
        glowIntensity: glowAnim.value,
      ),
    );
  }
}

class _BadgeBox extends StatelessWidget {
  final int streak;
  final double glowIntensity; // 0–1

  const _BadgeBox({required this.streak, required this.glowIntensity});

  @override
  Widget build(BuildContext context) {
    final glowColor = const Color(0xFFE07B39);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: glowIntensity > 0
                  ? glowColor.withValues(alpha: 0.4 + glowIntensity * 0.3)
                  : AppColors.border,
              width: 0.5,
            ),
            boxShadow: glowIntensity > 0
                ? [
                    BoxShadow(
                      color: glowColor.withValues(
                          alpha: 0.15 + glowIntensity * 0.25),
                      blurRadius: 8 + glowIntensity * 10,
                      spreadRadius: glowIntensity * 3,
                    ),
                  ]
                : const [],
          ),
          child: Column(
            children: [
              Text(
                streak > 7 ? '🔥' : '🔥',
                style: TextStyle(
                  fontSize: 18 + glowIntensity * 2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$streak',
                style: AppTextStyles.sectionTitle.copyWith(
                  fontSize: 16,
                  color: streak > 7
                      ? const Color(0xFFE07B39)
                      : AppColors.accent,
                ),
              ),
              Text(
                'streak',
                style: AppTextStyles.sectionSub.copyWith(fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
