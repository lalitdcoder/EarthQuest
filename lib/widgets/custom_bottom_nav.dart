import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

const _navItems = [
  _NavItem(CupertinoIcons.house_fill, 'Home'),
  _NavItem(CupertinoIcons.compass, 'Explore'),
  _NavItem(CupertinoIcons.star_circle_fill, 'Progress'),
  _NavItem(CupertinoIcons.person_crop_circle_fill, 'Profile'),
];

/// Custom bottom nav — no BottomNavigationBar widget
class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.heroDeep.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: _navItems.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final isActive = i == currentIndex;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Dot indicator
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isActive ? 5 : 0,
                        height: isActive ? 5 : 0,
                        margin: const EdgeInsets.only(bottom: 3),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accent,
                        ),
                      ),
                      Icon(
                        item.icon,
                        size: 22,
                        color: isActive
                            ? AppColors.heroDeep
                            : AppColors.textLight,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: isActive
                            ? AppTextStyles.navLabelActive
                            : AppTextStyles.navLabel,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
