import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Horizontally scrolling topic pill bar
class TopicPillRow extends StatefulWidget {
  const TopicPillRow({super.key});

  @override
  State<TopicPillRow> createState() => _TopicPillRowState();
}

class _TopicPillRowState extends State<TopicPillRow> {
  int _active = 0;

  static const _topics = [
    'All',
    'Planets',
    'Geology',
    'Atmosphere',
    'Oceans',
    'Climate',
    'Space',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _topics.length,
        itemBuilder: (context, i) {
          final isActive = i == _active;
          return GestureDetector(
            onTap: () => setState(() => _active = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.heroDeep : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? AppColors.heroDeep
                      : AppColors.border,
                  width: 1,
                ),
              ),
              child: Text(
                _topics[i],
                style: isActive
                    ? AppTextStyles.pillActive
                    : AppTextStyles.pillInactive,
              ),
            ),
          );
        },
      ),
    );
  }
}
