// lib/screens/impact_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/earth_state_notifier.dart';
import '../services/share_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

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
                child: _ShareCard(
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
// The High-Res Share Card (Hidden from User)
// ─────────────────────────────────────────────────────────────────────────────

class _ShareCard extends StatelessWidget {
  final String rank;
  final int streak;
  final double health;

  const _ShareCard({
    required this.rank,
    required this.streak,
    required this.health,
  });

  @override
  Widget build(BuildContext context) {
    // Hidden export target layout
    return Container(
      width: 1080,
      height: 1350, // 4:5 Instagram Ratio
      padding: const EdgeInsets.all(80),
      decoration: const BoxDecoration(
        color: AppColors.cream,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('EARTHQUEST',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: AppColors.heroDeep,
                letterSpacing: 8,
              )),
          const SizedBox(height: 20),
          Container(height: 6, width: 120, color: AppColors.terracotta),
          const Spacer(),
          Text('Rank: $rank',
              style: const TextStyle(
                fontSize: 98,
                fontWeight: FontWeight.bold,
                color: AppColors.terracotta,
                letterSpacing: -3,
              )),
          const SizedBox(height: 60),
          _ShareStat(label: 'DAILY STREAK', value: '$streak DAYS', icon: '🔥'),
          const SizedBox(height: 30),
          _ShareStat(label: 'PLANET HEALTH', value: '${health.toInt()}%', icon: '🌍'),
          const Spacer(),
          const Text('Join the quest. Save the world.',
              style: TextStyle(fontSize: 34, color: AppColors.textMid, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('www.earthquest.app',
              style: TextStyle(fontSize: 24, color: AppColors.textLight)),
        ],
      ),
    );
  }
}

class _ShareStat extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _ShareStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 40, offset: const Offset(0, 15)),
        ],
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 54)),
          const SizedBox(width: 40),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 24, letterSpacing: 2, color: AppColors.textLight, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: AppColors.heroDeep)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal UI components (Same as before)
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
          Text(value, style: AppTextStyles.display.copyWith(color: AppColors.textDark, fontSize: 32)),
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
    final count = (liters / 100).ceil().clamp(0, 80);
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F7FF),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: CustomPaint(painter: _DropletPainter(count: count)),
    );
  }
}

class _DropletPainter extends CustomPainter {
  final int count;
  _DropletPainter({required this.count});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF4A90E2);
    final spacing = 20.0;
    final cols = (size.width / spacing).floor();
    for (int i = 0; i < count; i++) {
        final row = i ~/ cols;
        final col = i % cols;
        final center = Offset(col * spacing + 10, row * spacing + 10);
        final path = Path();
        path.moveTo(center.dx, center.dy - 6);
        path.quadraticBezierTo(center.dx + 5, center.dy + 2, center.dx, center.dy + 6);
        path.quadraticBezierTo(center.dx - 5, center.dy + 2, center.dx, center.dy - 6);
        canvas.drawPath(path, paint);
    }
  }
  @override
  bool shouldRepaint(_DropletPainter old) => old.count != count;
}

class _TreeRowVisualizer extends StatelessWidget {
  final int count;
  const _TreeRowVisualizer({required this.count});
  @override
  Widget build(BuildContext context) {
    final displayCount = count.clamp(0, 30);
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(color: const Color(0xFFF1F9F1), borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.all(20),
      child: Wrap(
        spacing: 12, runSpacing: 12,
        children: List.generate(displayCount, (index) => const Text('🌲', style: TextStyle(fontSize: 24))),
      ),
    );
  }
}

class _PlasticBlockVisualizer extends StatelessWidget {
  final double kg;
  const _PlasticBlockVisualizer({required this.kg});
  @override
  Widget build(BuildContext context) {
    final count = kg.ceil().clamp(0, 40);
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(color: const Color(0xFFF9F1F1), borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10, crossAxisSpacing: 8, mainAxisSpacing: 8),
        itemCount: count,
        itemBuilder: (context, i) => Container(
            decoration: BoxDecoration(color: const Color(0xFFD0021B).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
            child: const Center(child: Text('♻️', style: TextStyle(fontSize: 10)))),
      ),
    );
  }
}
