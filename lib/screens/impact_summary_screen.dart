import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/earth_state_notifier.dart';
import '../services/share_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/share_card.dart';

class ImpactSummaryScreen extends ConsumerStatefulWidget {
  const ImpactSummaryScreen({super.key});

  @override
  ConsumerState<ImpactSummaryScreen> createState() => _ImpactSummaryScreenState();
}

class _ImpactSummaryScreenState extends ConsumerState<ImpactSummaryScreen> {
  final GlobalKey _shareKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(earthStateProvider);
    final impact = state.impact;
    final xp = state.userStats.totalXp;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.terracotta,
        onPressed: () => ShareService.captureAndShare(_shareKey),
        icon: const Icon(Icons.share, color: Colors.white, size: 20),
        label: const Text('SHARE IMPACT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ).animate().scale(delay: 800.ms),
      body: Stack(
        children: [
          // ── Hidden Content for Image Capture ───────────────
          // We use Offstage + RepaintBoundary to render the card
          // specifically for export without showing it in the main UI.
          Positioned(
            left: -2000, // Position way off-screen
            child: Offstage(
              offstage: false, // Must be false for RepaintBoundary to work
              child: RepaintBoundary(
                key: _shareKey,
                child: ShareCard(
                  rank: state.userStats.earthRank,
                  streak: state.userStats.currentStreak,
                  health: state.metrics.healthScore,
                ),
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Header ─────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 180,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.white,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'YOUR IMPACT',
                    style: AppTextStyles.display.copyWith(
                      color: AppColors.textDark,
                      fontSize: 18,
                      letterSpacing: 2,
                    ),
                  ),
                  centerTitle: true,
                  background: Container(
                    color: Colors.white,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Text(
                            '$xp XP Earned',
                            style: AppTextStyles.cardMeta.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Data Stories ───────────────────────────────────
              SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 20),
                  
                  // 1. Water Saved
                  _ImpactSection(
                    title: 'Water Saved',
                    value: '${impact.waterSavedLiters.toInt()} Liters',
                    description: 'Enough to sustain 10 families for a week.',
                    child: _WaterDropletGrid(liters: impact.waterSavedLiters),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

                  const SizedBox(height: 40),

                  // 2. Trees Planted
                  _ImpactSection(
                    title: 'Forest Grown',
                    value: '${impact.treesPlanted} Trees',
                    description: 'Removing CO₂ from the atmosphere every day.',
                    child: _TreeRowVisualizer(count: impact.treesPlanted),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),

                  const SizedBox(height: 40),

                  // 3. Plastic Recovered
                  _ImpactSection(
                    title: 'Plastic Recovered',
                    value: '${impact.plasticRecoveredKg.toInt()} kg',
                    description: 'Cleared from oceans and coastlines.',
                    child: _PlasticBlockVisualizer(kg: impact.plasticRecoveredKg),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),

                  const SizedBox(height: 100), // Extra space for FAB
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal UI components
// ─────────────────────────────────────────────────────────────────────────────

class _ImpactSection extends StatelessWidget {
  final String title;
  final String value;
  final String description;
  final Widget child;

  const _ImpactSection({
    required this.title,
    required this.value,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.cardMeta),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.display.copyWith(color: AppColors.textDark, fontSize: 32),
          ),
          const SizedBox(height: 4),
          Text(description, style: AppTextStyles.cardMeta),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

class _WaterDropletGrid extends StatelessWidget {
  final double liters;
  const _WaterDropletGrid({required this.liters});

  @override
  Widget build(BuildContext context) {
    final count = liters.toInt().clamp(0, 100);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F7FF),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: List.generate(count, (index) {
          return CustomPaint(
            size: const Size(16, 16),
            painter: _SingleDropletPainter(),
          ).animate()
           .fadeIn(delay: (index * 40).ms)
           .slideY(begin: -0.5, delay: (index * 40).ms, curve: Curves.easeOutBack);
        }),
      ),
    );
  }
}

class _SingleDropletPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF4A90E2);
    final center = Offset(size.width / 2, size.height / 2);
    final path = Path();
    path.moveTo(center.dx, center.dy - 6);
    path.quadraticBezierTo(center.dx + 5, center.dy + 2, center.dx, center.dy + 6);
    path.quadraticBezierTo(center.dx - 5, center.dy + 2, center.dx, center.dy - 6);
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(_SingleDropletPainter old) => false;
}

class _TreeRowVisualizer extends StatelessWidget {
  final int count;
  const _TreeRowVisualizer({required this.count});
  @override
  Widget build(BuildContext context) {
    final displayCount = count.clamp(0, 40);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: const Color(0xFFF1F9F1), borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.all(20),
      child: Wrap(
        spacing: 12, runSpacing: 12,
        children: List.generate(displayCount, (index) {
          return const Text('🌲', style: TextStyle(fontSize: 24))
            .animate()
            .scale(delay: (index * 80).ms, curve: Curves.elasticOut)
            .fadeIn(delay: (index * 80).ms);
        }),
      ),
    );
  }
}

class _PlasticBlockVisualizer extends StatelessWidget {
  final double kg;
  const _PlasticBlockVisualizer({required this.kg});
  @override
  Widget build(BuildContext context) {
    final count = kg.ceil().clamp(0, 50);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: const Color(0xFFF9F1F1), borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.all(20),
      child: Wrap(
        spacing: 8, runSpacing: 8,
        children: List.generate(count, (index) {
          return Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFD0021B).withValues(alpha: 0.15), 
              borderRadius: BorderRadius.circular(4)
            ),
            child: const Center(child: Text('♻️', style: TextStyle(fontSize: 14)))
          ).animate()
           .fadeIn(delay: (index * 60).ms)
           .slideX(begin: 0.3, delay: (index * 60).ms, curve: Curves.easeOut);
        }),
      ),
    );
  }
}
