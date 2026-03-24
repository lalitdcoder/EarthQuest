import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'theme/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const EarthQuestApp());
}

class EarthQuestApp extends StatelessWidget {
  const EarthQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EarthQuest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.heroDeep,
          surface: AppColors.background,
        ),
        // Disable all splash / highlight ripples for a clean feel
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      home: const HomeScreen(),
    );
  }
}
