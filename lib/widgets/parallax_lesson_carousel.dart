// lib/widgets/parallax_lesson_carousel.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lesson_model.dart';
import '../providers/earth_state_notifier.dart';
import '../screens/lesson_detail_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ParallaxLessonCarousel extends ConsumerStatefulWidget {
  const ParallaxLessonCarousel({super.key});

  @override
  ConsumerState<ParallaxLessonCarousel> createState() => _ParallaxLessonCarouselState();
}

class _ParallaxLessonCarouselState extends ConsumerState<ParallaxLessonCarousel> {
  late final PageController _pageCtrl;
  double _page = 0.0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(viewportFraction: 0.88);
    _pageCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    setState(() {
      _page = _pageCtrl.page ?? 0;
    });
  }

  @override
  void dispose() {
    _pageCtrl.removeListener(_onScroll);
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userStats = ref.watch(earthStateProvider.select((s) => s.userStats));
    final lessonProgressMap = {
      for (var p in userStats.lessonProgress) p.lessonId: p.fraction
    };

    return SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _pageCtrl,
        itemCount: lessons.length,
        onPageChanged: (_) => HapticFeedback.selectionClick(),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final lesson = lessons[index];
          final progress = lessonProgressMap[lesson.id] ?? 0.0;
          
          // Calculate individual page offset for parallax
          final delta = index - _page; // -1 to 1 range typically
          
          return _ParallaxCard(
            lesson: lesson,
            progress: progress,
            parallaxOffset: delta,
          );
        },
      ),
    );
  }
}

class _ParallaxCard extends StatelessWidget {
  final LessonModel lesson;
  final double progress;
  final double parallaxOffset;

  const _ParallaxCard({
    required this.lesson,
    required this.progress,
    required this.parallaxOffset,
  });

  void _navigate(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) =>
            LessonDetailScreen(lesson: lesson),
        transitionsBuilder: (_, animation, __, child) {
          final slide = Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
          return SlideTransition(position: slide, child: child);
        },
        transitionDuration: const Duration(milliseconds: 380),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Card scaling based on proximity to center
    final scale = 1.0 - (parallaxOffset.abs() * 0.08);
    
    return GestureDetector(
      onTap: lesson.locked ? null : () => _navigate(context),
      child: Transform.scale(
        scale: scale,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // ── Background Parallax Layer ──────────────────────
              Positioned.fill(
                child: _ParallaxBackground(
                  offset: parallaxOffset,
                  emoji: lesson.emoji,
                  color: lesson.iconBg,
                ),
              ),

              // ── Content Layer ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ── Icon with circular progress ─────────
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(54, 54),
                              painter: _ProgressRingPainter(
                                progress: progress,
                                trackColor: Colors.black12,
                                progressColor: AppColors.success,
                              ),
                            ),
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: lesson.iconBg,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  lesson.emoji,
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Locked indicator
                        if (lesson.locked)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.lock, size: 14, color: Colors.black38),
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      lesson.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                          Expanded(
                            child: Text(
                              lesson.meta,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.cardMeta,
                            ),
                          ),
                        const SizedBox(width: 8),
                        if (progress >= 1.0)
                          const Icon(Icons.check_circle, size: 16, color: AppColors.success)
                        else if (progress > 0)
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: AppTextStyles.cardMeta.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
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

class _ParallaxBackground extends StatelessWidget {
  final double offset;
  final String emoji;
  final Color color;

  const _ParallaxBackground({
    required this.offset,
    required this.emoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // We want the emoji in the background to move SLOWER than the card.
    // Card moves by 'offset' pixels. We shift the emoji by 'offset * factor'.
    return Stack(
      children: [
        // Subtle gradient tint
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.2),
                Colors.white,
              ],
            ),
          ),
        ),
        
        // Large parallax emoji
        Positioned(
          right: -20 - (offset * 80), // Swiping moves it
          bottom: -20,
          child: Opacity(
            opacity: 0.08,
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 140),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;

  _ProgressRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 3.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Track
    paint.color = trackColor;
    canvas.drawCircle(center, radius, paint);

    // Progress arc
    if (progress > 0) {
      paint.color = progressColor;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter old) => old.progress != progress;
}
