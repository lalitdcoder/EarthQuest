import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/earth_state_notifier.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// The 3-card "Explore" grid: Learn · Play · Act
class ExploreGrid extends ConsumerWidget {
  const ExploreGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(earthStateProvider.select((s) => s.userStats));
    
    // Calculate real counts from lessonProgress
    final completedLessons = stats.lessonProgress.where((p) => p.fraction >= 1.0).length;
    final totalLessons = 24; // Hardcoded for now until we have a proper lesson list provider/config
    
    final items = [
      _ExploreItem('Learn', '📚', AppColors.learnTint, AppColors.success, '$completedLessons / $totalLessons done'),
      const _ExploreItem('Play', '🎮', AppColors.playTint, AppColors.accent, '6 games'),
      const _ExploreItem('Act', '🌿', AppColors.actTint, Color(0xFF4A8C3F), '3 challenges'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: i == 0 ? 0 : 6,
                right: i == 2 ? 0 : 6,
              ),
              child: _ExploreCard(item: item),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ExploreCard extends StatefulWidget {
  final _ExploreItem item;
  const _ExploreCard({required this.item});

  @override
  State<_ExploreCard> createState() => _ExploreCardState();
}

class _ExploreCardState extends State<_ExploreCard> {
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
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
          child: Column(
            children: [
              // Icon box
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: widget.item.iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(widget.item.emoji,
                      style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(height: 10),
              Text(widget.item.label, style: AppTextStyles.cardTitle),
              const SizedBox(height: 3),
              Text(
                widget.item.sub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.cardMeta.copyWith(
                  color: widget.item.accentColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExploreItem {
  final String label;
  final String emoji;
  final Color iconBg;
  final Color accentColor;
  final String sub;
  const _ExploreItem(
      this.label, this.emoji, this.iconBg, this.accentColor, this.sub);
}
