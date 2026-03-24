import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class _Lesson {
  final String emoji;
  final Color iconBg;
  final String title;
  final String meta;
  final bool locked;
  const _Lesson(this.emoji, this.iconBg, this.title, this.meta,
      {this.locked = false});
}

const _lessons = [
  _Lesson('🌎', Color(0xFFE1F5EE), 'Formation of Earth',
      '8 min · Intro'),
  _Lesson('🔥', Color(0xFFFAEEDA), 'Volcanic Eruptions',
      '12 min · Geology'),
  _Lesson('🌊', Color(0xFFE3F0FF), 'Ocean Currents',
      '10 min · Oceans'),
  _Lesson('🌬️', Color(0xFFEAF3DE), 'Jet Streams',
      '9 min · Atmosphere'),
  _Lesson('🪨', Color(0xFFF5EDE4), 'Rock Cycle',
      '11 min · Geology', locked: true),
  _Lesson('☄️', Color(0xFFF2E8F8), 'Asteroid Impact',
      '15 min · Space', locked: true),
];

/// Scrollable lesson list
class LessonList extends StatelessWidget {
  const LessonList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _lessons.asMap().entries.map((entry) {
        final i = entry.key;
        final lesson = entry.value;
        return _LessonRow(lesson: lesson, isLast: i == _lessons.length - 1);
      }).toList(),
    );
  }
}

class _LessonRow extends StatefulWidget {
  final _Lesson lesson;
  final bool isLast;
  const _LessonRow({required this.lesson, required this.isLast});

  @override
  State<_LessonRow> createState() => _LessonRowState();
}

class _LessonRowState extends State<_LessonRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) => setState(() => _hovered = false),
      onTapCancel: () => setState(() => _hovered = false),
      onTap: widget.lesson.locked ? null : () {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        margin: EdgeInsets.fromLTRB(20, 0, 20, widget.isLast ? 0 : 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _hovered
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
                  Text(widget.lesson.title,
                      style: AppTextStyles.lessonTitle.copyWith(
                        color: widget.lesson.locked
                            ? AppColors.textLight
                            : AppColors.textDark,
                      )),
                  const SizedBox(height: 3),
                  Text(widget.lesson.meta,
                      style: AppTextStyles.lessonMeta),
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
                child: Text('›',
                    style: TextStyle(
                      fontSize: 22,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w300,
                    )),
              ),
          ],
        ),
      ),
    );
  }
}
