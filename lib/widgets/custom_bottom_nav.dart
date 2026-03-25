// lib/widgets/custom_bottom_nav.dart
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

/// Premium bottom navigation with elastic interactions and a sliding glowing pill indicator.
class CustomBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tabWidth = screenWidth / _navItems.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.heroDeep.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Stack(
            children: [
              // ── Sliding Glowing Pill Indicator ──────────────────
              AnimatedPositioned(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutBack,
                left: widget.currentIndex * tabWidth + (tabWidth / 2) - 20,
                bottom: 8,
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Navigation Icons ────────────────────────────────
              Row(
                children: _navItems.asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  final isActive = i == widget.currentIndex;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => widget.onTap(i),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Elastic Animated Icon
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.elasticOut,
                            tween: Tween(
                              begin: isActive ? 0.8 : 1.0,
                              end: isActive ? 1.2 : 1.0,
                            ),
                            builder: (context, scale, child) {
                              return Transform.scale(
                                scale: scale,
                                child: Transform.rotate(
                                  angle: isActive ? 0.05 : 0,
                                  child: Icon(
                                    item.icon,
                                    size: 24,
                                    color: isActive
                                        ? AppColors.heroDeep
                                        : AppColors.textLight.withValues(alpha: 0.6),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: (isActive
                                    ? AppTextStyles.navLabelActive
                                    : AppTextStyles.navLabel)
                                .copyWith(
                              fontSize: 10,
                              color: isActive
                                  ? AppColors.heroDeep
                                  : AppColors.textLight.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
