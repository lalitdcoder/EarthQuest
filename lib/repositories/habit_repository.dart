// lib/repositories/habit_repository.dart
import 'package:isar_community/isar.dart';
import '../models/user_stats.dart';

/// Handles all secure, transaction-based reads and writes to the Isar database
/// for the user's habit / streak data.
///
/// Usage:
///   final repo = HabitRepository(isar);
///   final stats = await repo.fetchStats();
///   await repo.recordActivity(xpGained: 25);
class HabitRepository {
  final Isar _db;

  HabitRepository(this._db);

  // ─── Internals ────────────────────────────────────────────────────────────

  static const _kStatsId = 1; // Singleton row ID

  /// Returns the persisted [UserStats] row, creating it on first launch.
  Future<UserStats> fetchStats() async {
    return _db.txn(() async {
      final existing = await _db.userStats.get(_kStatsId);
      if (existing != null) return existing;

      // First launch – seed a default record.
      final fresh = UserStats()..id = _kStatsId;
      // Write happens outside this read-only txn; return defaults.
      return fresh;
    });
  }

  /// Records a completed activity for today.
  ///
  /// - Increments [currentStreak] if the user was active yesterday, or resets
  ///   to 1 if they missed a day.
  /// - Updates [highestStreak] when a new personal best is set.
  /// - Adds [xpGained] to [totalXp].
  ///
  /// Returns the updated [UserStats].
  Future<UserStats> recordActivity({int xpGained = 0}) async {
    return _db.writeTxn(() async {
      // Load or create the singleton stats row.
      UserStats stats = await _db.userStats.get(_kStatsId) ??
          (UserStats()..id = _kStatsId);

      final now = DateTime.now().toUtc();
      final today = _dateOnly(now);
      final last = stats.lastActivityDate != null
          ? _dateOnly(stats.lastActivityDate!)
          : null;

      if (last == null) {
        // Very first activity ever.
        stats.currentStreak = 1;
      } else if (last == today) {
        // Already recorded today – only add XP, don't change streak.
      } else {
        final diff = today.difference(last).inDays;
        if (diff == 1) {
          // Consecutive day – extend streak.
          stats.currentStreak += 1;
        } else {
          // Missed one or more days – reset.
          stats.currentStreak = 1;
        }
      }

      // Update best streak.
      if (stats.currentStreak > stats.highestStreak) {
        stats.highestStreak = stats.currentStreak;
      }

      stats.lastActivityDate = today;
      stats.totalXp += xpGained;

      await _db.userStats.put(stats);
      return stats;
    });
  }

  /// Overwrites the stats record with the provided [stats] object.
  /// Useful for migrations or test-seeding.
  Future<void> saveStats(UserStats stats) async {
    await _db.writeTxn(() async {
      stats.id = _kStatsId;
      await _db.userStats.put(stats);
    });
  }

  /// Persists the onboarding result: assigns [rank] and marks
  /// [onboardingComplete] = true.  Creates the stats row if it doesn't exist.
  Future<UserStats> saveEarthRank(String rank) async {
    return _db.writeTxn(() async {
      final stats = await _db.userStats.get(_kStatsId) ??
          (UserStats()..id = _kStatsId);
      stats.earthRank = rank;
      stats.onboardingComplete = true;
      await _db.userStats.put(stats);
      return stats;
    });
  }

  /// Updates the user's progress for a specific lesson.
  Future<UserStats> updateLessonProgress(
    String lessonId,
    int completedSections,
    int totalSections,
  ) async {
    return _db.writeTxn(() async {
      final stats = await _db.userStats.get(_kStatsId) ??
          (UserStats()..id = _kStatsId);

      // Find or create the entry
      final index = stats.lessonProgress.indexWhere((p) => p.lessonId == lessonId);
      if (index != -1) {
        final existing = stats.lessonProgress[index];
        // Only update if progress is more than existing
        if (completedSections > existing.completedSections) {
          existing.completedSections = completedSections;
          existing.totalSections = totalSections;
        }
      } else {
        stats.lessonProgress.add(LessonProgress()
          ..lessonId = lessonId
          ..completedSections = completedSections
          ..totalSections = totalSections);
      }

      await _db.userStats.put(stats);
      return stats;
    });
  }


  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// Strips time-of-day so date comparisons are day-accurate.
  DateTime _dateOnly(DateTime dt) => DateTime.utc(dt.year, dt.month, dt.day);
}
