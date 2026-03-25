// lib/widgets/error_boundary.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Overrides the standard Flutter red-screen of death with a premium, themed experience.
class GlobalErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;
  const GlobalErrorWidget({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🛰️', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 24),
              Text(
                'A GLITCH IN THE MATRIX',
                style: AppTextStyles.display.copyWith(
                  color: AppColors.textDark,
                  fontSize: 22,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Our sensors detected a temporary anomaly in the simulation. We are recalibrating.',
                style: AppTextStyles.cardMeta.copyWith(
                  color: AppColors.textMid,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              TextButton(
                onPressed: () {
                  // Attempt a soft restart or just pop back
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    // Logic to jump back home can go here
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.heroDeep,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('RELOAD SIMULATION'),
              ),
              // We could show the error in small print for dev-internal logging if needed
              // if (kDebugMode) Text(details.exceptionAsString().substring(0, 100))
            ],
          ),
        ),
      ),
    );
  }
}
