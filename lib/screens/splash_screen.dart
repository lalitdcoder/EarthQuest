// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/asset_preloader.dart';
import '../providers/earth_state_notifier.dart';
import '../screens/home_screen.dart';
import '../screens/onboarding_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startApp();
  }

  Future<void> _startApp() async {
    // 1. Preload assets
    await AssetPreloader.preload(context);

    // 2. Determine initial route
    final onboardingComplete = ref.read(earthStateProvider.select((s) => s.userStats.onboardingComplete));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, animation, __) =>
              onboardingComplete ? const HomeScreen() : const OnboardingScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 1200),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.heroDeep,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Animate(
              onPlay: (c) => c.repeat(reverse: true),
              child: const Text('🌍', style: TextStyle(fontSize: 80)),
            )
                .scale(duration: 800.ms, curve: Curves.elasticOut)
                .rotate(begin: -0.1, end: 0.1, duration: 2000.ms)
                .then()
                .rotate(begin: 0.1, end: -0.1, duration: 2000.ms),
            const SizedBox(height: 32),
            Text(
              'EARTHQUEST',
              style: AppTextStyles.display.copyWith(
                color: Colors.white,
                letterSpacing: 4,
                fontSize: 24,
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
            const SizedBox(height: 12),
            Text(
              'RECALIBRATING SENSORS...',
              style: AppTextStyles.cardMeta.copyWith(
                color: Colors.white70,
                letterSpacing: 1.5,
              ),
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }
}
