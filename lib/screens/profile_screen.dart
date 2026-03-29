import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/earth_state_notifier.dart';
import '../services/share_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/share_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data
// ─────────────────────────────────────────────────────────────────────────────
class _ImpactStat {
  final String emoji;
  final String label;
  final String value;
  final String sub;
  final Color iconBg;
  final Color accentColor;
  const _ImpactStat(this.emoji, this.label, this.value, this.sub,
      this.iconBg, this.accentColor);
}

const _impactStats = [
  _ImpactStat('🌱', 'Carbon Saved', '124 kg', 'CO₂ offset',
      AppColors.learnTint, AppColors.success),
  _ImpactStat('🌳', 'Trees Planted', '3', 'via rewards',
      AppColors.actTint, Color(0xFF4A8C3F)),
  _ImpactStat('📖', 'Lessons Done', '12', 'completed',
      AppColors.playTint, AppColors.accent),
  _ImpactStat('🔥', 'Streak', '7 days', 'personal best: 14',
      Color(0xFFFFF0E0), Color(0xFFE07B39)),
];

class _Achievement {
  final String emoji;
  final String title;
  final String desc;
  final bool earned;
  const _Achievement(this.emoji, this.title, this.desc,
      {this.earned = true});
}

const _achievements = [
  _Achievement('🌍', 'First Step', 'Complete your first lesson'),
  _Achievement('🔥', 'On Fire', 'Maintain a 7-day streak'),
  _Achievement('🌊', 'Deep Diver', 'Finish the Oceans topic'),
  _Achievement('🧠', 'Earth Scholar', 'Score 100% on any quiz',
      earned: false),
  _Achievement('🌱', 'Green Thumb', 'Plant 5 trees via rewards',
      earned: false),
  _Achievement('☄️', 'Space Cadet', 'Unlock the Space topic',
      earned: false),
];

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final GlobalKey _shareKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(earthStateProvider);
    final stats = state.userStats;
    final impact = state.impact;
    final completedLessons = stats.lessonProgress.where((p) => p.fraction >= 1.0).length;

    final impactItems = [
      _ImpactStat('🌱', 'Carbon Saved', '${(stats.totalXp * 0.18).toStringAsFixed(1)} kg', 'CO₂ offset',
          AppColors.learnTint, AppColors.success),
      _ImpactStat('🌳', 'Trees Planted', '${impact.treesPlanted}', 'via rewards',
          AppColors.actTint, const Color(0xFF4A8C3F)),
      _ImpactStat('📖', 'Lessons Done', '$completedLessons', 'completed',
          AppColors.playTint, AppColors.accent),
      _ImpactStat('🔥', 'Streak', '${stats.currentStreak} days', 'personal best: ${stats.highestStreak}',
          const Color(0xFFFFF0E0), const Color(0xFFE07B39)),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.terracotta,
        onPressed: () => ShareService.captureAndShare(_shareKey),
        icon: const Icon(Icons.share, color: Colors.white, size: 20),
        label: const Text('SHARE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          // ── Hidden Content for Image Capture ───────────────
          Positioned(
            left: -2000,
            child: Offstage(
              offstage: false,
              child: RepaintBoundary(
                key: _shareKey,
                child: ShareCard(
                  rank: stats.earthRank,
                  streak: stats.currentStreak,
                  health: state.metrics.healthScore,
                ),
              ),
            ),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
          // ── Profile hero header ─────────────────────────────
          const SliverToBoxAdapter(child: _ProfileHeader()),

          // ── Streak showcase ─────────────────────────────────
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Streak', style: AppTextStyles.sectionTitle),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          const SliverToBoxAdapter(child: _StreakShowcase()),

          // ── Impact grid ─────────────────────────────────────
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Your Impact', style: AppTextStyles.sectionTitle),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // 2 × 2 grid — SliverGrid matching ExploreGrid style
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) => _ImpactCard(stat: impactItems[i]),
                childCount: impactItems.length,
              ),
            ),
          ),

          // ── Weekly progress card ─────────────────────────────
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('This Week', style: AppTextStyles.sectionTitle),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          const SliverToBoxAdapter(child: _WeeklyProgressCard()),

          // ── Achievements ─────────────────────────────────────
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Achievements', style: AppTextStyles.sectionTitle),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.learnTint,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$completedLessons / 6 earned',
                      style: AppTextStyles.cardMeta.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.88,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) =>
                    _AchievementBadge(achievement: _achievements[i], earned: i < completedLessons),
                childCount: _achievements.length,
              ),
            ),
          ),

          // ── Settings row ─────────────────────────────────────
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
          const SliverToBoxAdapter(child: _SettingsBlock()),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 100)), // Extra padding for FAB
        ],
      ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Profile Header
// ─────────────────────────────────────────────────────────────────────────────
class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(earthStateProvider.select((s) => s.userStats));
    final topPad = MediaQuery.of(context).padding.top;
    
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.heroDeep,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      padding: EdgeInsets.fromLTRB(24, topPad + 20, 24, 32),
      child: Column(
        children: [
          // Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent, width: 2.5),
                  color: AppColors.heroDeep,
                ),
                child: const Center(
                  child: Text('🌍', style: TextStyle(fontSize: 42)),
                ),
              ),
              // Online indicator
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: AppColors.heroDeep, width: 2.5),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text('Alex Rivera', // Note: Name could be from DB too, but UserStats doesn't have it yet.
              style: AppTextStyles.display.copyWith(fontSize: 22)),
          const SizedBox(height: 4),
          
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              '${stats.earthRank} · Level ${stats.currentLevel}',
              key: ValueKey('${stats.earthRank}_${stats.currentLevel}'),
              style: AppTextStyles.heroSub,
            ),
          ),

          const SizedBox(height: 24),

          // XP progress bar
          _XpBar(
            xp: stats.currentLevelXpProgress, 
            nextLevelXp: 100, // Every 100 XP is a level in our math
            currentLevel: stats.currentLevel,
          ),

          const SizedBox(height: 24),

          // Quick stat chips row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatChip('🏅', '${stats.totalXp} XP'),
              const SizedBox(width: 10),
              _StatChip('📍', 'Level ${stats.currentLevel}'),
              const SizedBox(width: 10),
              const _StatChip('👥', '12 Friends'),
            ],
          ),
        ],
      ),
    );
  }
}

class _XpBar extends StatelessWidget {
  final int xp;
  final int nextLevelXp;
  final int currentLevel;
  
  const _XpBar({
    required this.xp, 
    required this.nextLevelXp,
    required this.currentLevel,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (xp / nextLevelXp).clamp(0.0, 1.0);
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$xp / $nextLevelXp XP',
                style: AppTextStyles.cardMeta
                    .copyWith(color: AppColors.accent, fontWeight: FontWeight.w600)),
            Text('To Level ${currentLevel + 1}',
                style: AppTextStyles.cardMeta
                    .copyWith(color: Colors.white38, fontSize: 10)),
          ],
        ),
        const SizedBox(height: 10),
        // Custom premium progress bar
        Stack(
          children: [
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return FractionallySizedBox(
                  widthFactor: value,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, Color(0xFFD4A574)],
                      ),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String emoji;
  final String label;
  const _StatChip(this.emoji, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.12), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 5),
          Text(label,
              style: AppTextStyles.cardMeta.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Streak showcase — large badge + weekly day dots
// ─────────────────────────────────────────────────────────────────────────────
class _StreakShowcase extends ConsumerWidget {
  const _StreakShowcase();

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(earthStateProvider.select((s) => s.userStats));
    
    // For now, we use dummy "done" indicators for the week, 
    // but the main badge is real.
    final List<bool> doneIndicators = [true, true, stats.currentStreak > 0, false, false, false, false];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.heroDeep.withValues(alpha: 0.06),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Large streak badge ──────────────────────────
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 30)),
                const SizedBox(height: 4),
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: stats.currentStreak),
                  duration: const Duration(milliseconds: 1000),
                  builder: (context, value, child) {
                    return Text(
                      '$value',
                      style: AppTextStyles.display.copyWith(
                        color: AppColors.accent,
                        fontSize: 28,
                      ),
                    );
                  },
                ),
                Text(
                  'day streak',
                  style: AppTextStyles.sectionSub.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),

          const SizedBox(width: 18),

          // ── Day-of-week dots ────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keep it going!',
                  style: AppTextStyles.cardTitle
                      .copyWith(fontSize: 15),
                ),
                const SizedBox(height: 3),
                Text(
                  'Personal best: ${stats.highestStreak} days',
                  style: AppTextStyles.cardMeta,
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _days.asMap().entries.map((e) {
                    final done = doneIndicators[e.key];
                    return Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: done
                                ? AppColors.success
                                : AppColors.border
                                    .withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: done
                                  ? AppColors.success
                                  : AppColors.border,
                              width: 0.5,
                            ),
                          ),
                          child: Center(
                            child: done
                                ? const Icon(
                                    CupertinoIcons.checkmark_alt,
                                    size: 13,
                                    color: Colors.white,
                                  )
                                : Text(
                                    e.value,
                                    style: AppTextStyles.cardMeta
                                        .copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(e.value,
                            style: AppTextStyles.cardMeta
                                .copyWith(fontSize: 9)),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Impact card — mirrors ExploreCard visually
// ─────────────────────────────────────────────────────────────────────────────
class _ImpactCard extends StatefulWidget {
  final _ImpactStat stat;
  const _ImpactCard({required this.stat});

  @override
  State<_ImpactCard> createState() => _ImpactCardState();
}

class _ImpactCardState extends State<_ImpactCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {},
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border, width: 0.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.heroDeep.withValues(alpha: 0.05),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon box
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: widget.stat.iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(widget.stat.emoji,
                      style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 10),
              // Value + label
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.stat.value,
                      style: AppTextStyles.sectionTitle.copyWith(
                        color: widget.stat.accentColor,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(widget.stat.label,
                        style: AppTextStyles.cardTitle
                            .copyWith(fontSize: 12)),
                    Text(widget.stat.sub,
                        style: AppTextStyles.cardMeta
                            .copyWith(fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Weekly progress card — bar chart of lessons per day
// ─────────────────────────────────────────────────────────────────────────────
class _WeeklyProgressCard extends StatelessWidget {
  const _WeeklyProgressCard();

  // lessons done per day (Mon–Sun)
  static const _data = [2, 3, 1, 4, 2, 3, 0];
  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _maxVal = 4;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.heroDeep.withValues(alpha: 0.06),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Lessons this week',
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.learnTint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '15 total',
                  style: AppTextStyles.cardMeta.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Bar chart
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _data.asMap().entries.map((entry) {
                final i = entry.key;
                final val = entry.value;
                final fraction = val / _maxVal;
                final isToday = i == 5; // Saturday = today
                return Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (val > 0)
                          Text(
                            '$val',
                            style: AppTextStyles.cardMeta.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: isToday
                                  ? AppColors.accent
                                  : AppColors.textLight,
                            ),
                          ),
                        const SizedBox(height: 3),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutCubic,
                          width: double.infinity,
                          height: fraction * 58,
                          decoration: BoxDecoration(
                            color: isToday
                                ? AppColors.accent
                                : AppColors.success
                                    .withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(_days[i],
                            style: AppTextStyles.cardMeta.copyWith(
                              fontSize: 10,
                              fontWeight: isToday
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isToday
                                  ? AppColors.accent
                                  : AppColors.textLight,
                            )),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Achievement badge cell
// ─────────────────────────────────────────────────────────────────────────────
class _AchievementBadge extends StatelessWidget {
  final _Achievement achievement;
  final bool earned;
  const _AchievementBadge({required this.achievement, required this.earned});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: earned ? Colors.white : AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: earned ? AppColors.border : AppColors.border.withValues(alpha: 0.5),
          width: 0.5,
        ),
        boxShadow: earned
            ? [
                BoxShadow(
                  color: AppColors.heroDeep.withValues(alpha: 0.05),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: earned
                      ? AppColors.learnTint
                      : AppColors.border.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                achievement.emoji,
                style: TextStyle(
                  fontSize: 22,
                  color: earned ? null : const Color(0x00000000),
                ),
              ),
              if (!earned)
                const Icon(CupertinoIcons.lock_fill,
                    size: 18, color: AppColors.textLight),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            achievement.title,
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: 11,
              color: earned ? AppColors.textDark : AppColors.textLight,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            achievement.desc,
            style: AppTextStyles.cardMeta.copyWith(fontSize: 9),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Settings block
// ─────────────────────────────────────────────────────────────────────────────
class _SettingsBlock extends StatelessWidget {
  const _SettingsBlock();

  static const _items = [
    (CupertinoIcons.bell, 'Notifications', AppColors.learnTint),
    (CupertinoIcons.globe, 'Language', AppColors.playTint),
    (CupertinoIcons.lock_shield, 'Privacy', AppColors.actTint),
    (CupertinoIcons.question_circle, 'Help & Support', Color(0xFFF0EAF8)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: _items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final isLast = i == _items.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: item.$3,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.$1,
                          size: 17, color: AppColors.textDark),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(item.$2,
                          style: AppTextStyles.lessonTitle),
                    ),
                    const Icon(CupertinoIcons.chevron_right,
                        size: 14, color: AppColors.textLight),
                  ],
                ),
              ),
              if (!isLast)
                Container(
                  height: 0.5,
                  margin: const EdgeInsets.only(left: 66),
                  color: AppColors.border,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
