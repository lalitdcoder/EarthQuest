// lib/services/asset_preloader.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// One-stop utility to ensure crucial UI assets are warm in memory
/// before the user ever sees a screen. Ensures zero-stutter first frames.
class AssetPreloader {
  static Future<void> preload(BuildContext context) async {
    try {
      // 1. Precache crucial Lottie files
      // We can use the Lottie cache directly or just warm up the composition
      await AssetLottie('assets/lottie/planet_health.json').load();
      
      // 2. We can also precache standard image assets if we had any
      // For instance: 
      // await precacheImage(const AssetImage('assets/images/stars_bg.png'), context);
      
      // 3. Keep any other warm-up tasks here
      await Future.delayed(const Duration(milliseconds: 800)); // Minimum feel-good delay
    } catch (e) {
      debugPrint('Preloading failed: $e');
      // We don't block the app for preloading failures
    }
  }
}
