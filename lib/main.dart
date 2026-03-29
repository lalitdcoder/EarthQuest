// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'models/user_stats.dart';
import 'providers/earth_state_notifier.dart';
import 'screens/splash_screen.dart';
import 'theme/app_colors.dart';
import 'widgets/error_boundary.dart';
import 'services/toast_service.dart';

/// Opens (or re-opens) the Isar database and returns the instance.
Future<Isar> _openIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  if (Isar.instanceNames.isNotEmpty) {
    return Future.value(Isar.getInstance()!);
  }
  return Isar.open(
    [UserStatsSchema],
    directory: dir.path,
    inspector: false,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Global Error Handling Strategy
  // Replaces the standard red screen with our themed Glue Screen.
  ErrorWidget.builder = (details) => GlobalErrorWidget(details: details);

  // Lock status bar to light icons
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // 2. Open DB
  final isar = await _openIsar();

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
      ],
      child: const EarthQuestApp(),
    ),
  );
}

class EarthQuestApp extends StatelessWidget {
  const EarthQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: ToastService.messengerKey,
      title: 'EarthQuest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.heroDeep,
          surface: AppColors.background,
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: _FadeScaleTransitionsBuilder(),
            TargetPlatform.iOS: _FadeScaleTransitionsBuilder(),
            TargetPlatform.macOS: _FadeScaleTransitionsBuilder(),
          },
        ),
      ),
      // We boot into SplashScreen which handles preloading and initial routing.
      home: const SplashScreen(),
    );
  }
}

/// Custom Scale+Fade transition for a premium "pop" effect.
class _FadeScaleTransitionsBuilder extends PageTransitionsBuilder {
  const _FadeScaleTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.96, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
    );
  }
}
