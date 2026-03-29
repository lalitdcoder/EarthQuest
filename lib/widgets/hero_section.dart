import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/earth_state_notifier.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../screens/simulator_screen.dart';
import '../screens/impact_summary_screen.dart';
import 'planet_widget.dart';

/// The bespoke deep-earth hero at the top of the Home Screen.
class HeroSection extends ConsumerStatefulWidget {
  const HeroSection({super.key});

  @override
  ConsumerState<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends ConsumerState<HeroSection>
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
      decoration: const BoxDecoration(
        color: AppColors.heroDeep,
        borderRadius: BorderRadius.only(
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('EarthQuest', style: AppTextStyles.display),
                    const SizedBox(height: 2),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                      child: Text(
                        '${ref.watch(earthStateProvider.select((s) => s.userStats.earthRank))} · Level ${ref.watch(earthStateProvider.select((s) => s.userStats.currentLevel))}',
                        key: ValueKey(ref.watch(earthStateProvider.select((s) => s.userStats.earthRank + s.userStats.currentLevel.toString()))),
                        style: AppTextStyles.heroSub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent, width: 2),
                  color: AppColors.heroDeep,
                ),
                child: const Center(
                  child: Text('🌍', style: TextStyle(fontSize: 20)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // ── Planet (shared widget, 200 px) ────────────────
          Center(
            child: PlanetWidget(
              size: 200,
              orbitCtrl: _orbitCtrl,
              pulse: _pulse,
              healthScore: ref.watch(earthStateProvider.select((s) => s.metrics.healthScore)),
            ),
          ),

          const SizedBox(height: 28),

          // ── CTA → SimulatorScreen ─────────────────────────
          Center(
            child: TextButton(
              onPressed: () => Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, animation, __) =>
                      const SimulatorScreen(),
                  transitionsBuilder: (_, animation, __, child) =>
                      FadeTransition(opacity: animation, child: child),
                  transitionDuration: const Duration(milliseconds: 400),
                ),
              ),
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

          const SizedBox(height: 12),

          // ── Impact Button ─────────────────────────────────
          Center(
            child: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ImpactSummaryScreen()),
              ),
              child: Text(
                'View your impact  ›',
                style: AppTextStyles.cardMeta.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
