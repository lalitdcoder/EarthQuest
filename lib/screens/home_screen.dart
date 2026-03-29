import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lesson_model.dart'; // To get total lessons
import '../providers/earth_state_notifier.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/hero_section.dart';
import '../widgets/act_card.dart';
import '../widgets/explore_grid.dart';
import '../widgets/topic_pill_row.dart';
import '../widgets/parallax_lesson_carousel.dart';
import '../widgets/custom_bottom_nav.dart';
import 'profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _navIndex = 0;

  // Lazily build only the active tab body.
  Widget _buildBody() {
    switch (_navIndex) {
      case 3:
        return const ProfileScreen();
      default:
        return _homeBody();
    }
  }

  Widget _homeBody() {
    final unlockedLessons = lessons.where((l) => !l.locked).length;
    
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Hero ──────────────────────────────────────────────
        const SliverToBoxAdapter(child: HeroSection()),

        // ── Today's Quest ─────────────────────────────────────
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text("Today's Quest",
                style: AppTextStyles.sectionTitle),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        const SliverToBoxAdapter(child: ActCard()),

        // ── Explore ───────────────────────────────────────────
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Explore', style: AppTextStyles.sectionTitle),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('See all',
                      style: AppTextStyles.cardMeta.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        const SliverToBoxAdapter(child: ExploreGrid()),

        // ── Topics ────────────────────────────────────────────
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('Topics', style: AppTextStyles.sectionTitle),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        const SliverToBoxAdapter(child: TopicPillRow()),

        // ── Lessons ───────────────────────────────────────────
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lessons', style: AppTextStyles.sectionTitle),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.learnTint,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('$unlockedLessons available',
                      style: AppTextStyles.cardMeta.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        const SliverToBoxAdapter(child: ParallaxLessonCarousel()),

        // bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(
          key: ValueKey(_navIndex),
          child: _buildBody(),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}
