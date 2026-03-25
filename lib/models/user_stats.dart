// lib/models/user_stats.dart
// ignore_for_file: unused_import
import 'package:isar_community/isar.dart';

// The generated file will be created by build_runner.
part 'user_stats.g.dart';

/// Isar-persisted record that tracks the player's progress.
/// Only a single row (id == 1) is ever used; it acts as a singleton store.
@Collection()
class UserStats {
  /// Auto-incremented primary key (Isar convention).
  Id id = Isar.autoIncrement;

  /// Current consecutive-day streak.
  int currentStreak = 0;

  /// All-time highest streak reached.
  int highestStreak = 0;

  /// The last calendar date on which the user completed an activity.
  /// Stored as UTC so comparisons are timezone-safe.
  DateTime? lastActivityDate;

  /// Cumulative experience points earned across all activities.
  int totalXp = 0;

  /// Earth rank title assigned after onboarding (e.g. "Seedling", "Wayfinder").
  String earthRank = 'Seedling';

  /// Whether the user has completed the onboarding flow.
  bool onboardingComplete = false;

  /// Track individual lesson progress.
  List<LessonProgress> lessonProgress = [];
}

/// Local tracking for how much of a lesson is completed.
@Embedded()
class LessonProgress {
  /// Matches [LessonModel.id].
  String? lessonId;

  /// Number of sections completed by the user.
  int completedSections = 0;

  /// Total number of sections in the lesson (cached).
  int totalSections = 0;

  /// Percentage calculated for UI (0.0 – 1.0).
  double get fraction => totalSections > 0 ? (completedSections / totalSections).clamp(0, 1) : 0;
}
