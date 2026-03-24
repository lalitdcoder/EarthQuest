import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// "Today's Act" card — streak badge + lesson teaser
class ActCard extends StatelessWidget {
  const ActCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon box
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.playTint,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: const Center(
                child: Text('🌋', style: TextStyle(fontSize: 26)),
              ),
            ),

            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Today's Quest", style: AppTextStyles.sectionTitle),
                  const SizedBox(height: 3),
                  Text('Plate tectonics · 10 min',
                      style: AppTextStyles.cardMeta),
                  const SizedBox(height: 8),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: 0.42,
                      minHeight: 5,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.success),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('42% complete', style: AppTextStyles.sectionSub),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // Streak badge
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Column(
                    children: [
                      const Text('🔥',
                          style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 2),
                      Text('7',
                          style: AppTextStyles.sectionTitle.copyWith(
                              fontSize: 16, color: AppColors.accent)),
                      Text('streak',
                          style: AppTextStyles.sectionSub.copyWith(
                              fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
