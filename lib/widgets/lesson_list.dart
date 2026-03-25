import 'package:flutter/material.dart';
import '../models/lesson_model.dart';
import '../screens/lesson_detail_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Scrollable lesson list — data driven by the shared [lessons] catalogue.
class LessonList extends StatelessWidget {
  const LessonList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: lessons.asMap().entries.map((entry) {
        final i = entry.key;
        final lesson = entry.value;
        return _LessonRow(lesson: lesson, isLast: i == lessons.length - 1);
      }).toList(),
    );
  }
}

class _LessonRow extends StatefulWidget {
  final LessonModel lesson;
  final bool isLast;
  const _LessonRow({required this.lesson, required this.isLast});

  @override
  State<_LessonRow> createState() => _LessonRowState();
}

class _LessonRowState extends State<_LessonRow> {
  bool _pressed = false;

  void _navigate() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) =>
            LessonDetailScreen(lesson: widget.lesson),
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
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.lesson.locked ? null : _navigate,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        margin: EdgeInsets.fromLTRB(20, 0, 20, widget.isLast ? 0 : 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _pressed
              ? AppColors.cardLight
              : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: widget.lesson.iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(widget.lesson.emoji,
                    style: const TextStyle(fontSize: 22)),
              ),
            ),

            const SizedBox(width: 14),

            // Title + meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.lesson.title,
                    style: AppTextStyles.lessonTitle.copyWith(
                      color: widget.lesson.locked
                          ? AppColors.textLight
                          : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(widget.lesson.meta, style: AppTextStyles.lessonMeta),
                ],
              ),
            ),

            // Right indicator
            if (widget.lesson.locked)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.lock_outline_rounded,
                    size: 16, color: AppColors.textLight),
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  '›',
                  style: TextStyle(
                    fontSize: 22,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
