import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ShareCard extends StatelessWidget {
  final String rank;
  final int streak;
  final double health;

  const ShareCard({
    super.key,
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
