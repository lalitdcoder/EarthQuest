// lib/providers/earth_state_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import '../models/action_toggle.dart';
import '../models/earth_metrics.dart';
import '../models/real_world_impact.dart';
import '../models/user_stats.dart';
import '../repositories/habit_repository.dart';
import '../services/toast_service.dart';

// ─── Database provider ───────────────────────────────────────────────────────

/// Holds the open [Isar] instance that was initialised in [main].
/// Overridden with [ProviderScope(overrides: [...])].
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError(
    'isarProvider must be overridden in ProviderScope with the open Isar instance.',
  );
});

// ─── Repository provider ─────────────────────────────────────────────────────

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepository(ref.watch(isarProvider));
});

// ─── UserStats stream provider ───────────────────────────────────────────────

/// Re-emits the live [UserStats] row every time it changes in Isar.
final userStatsProvider = StreamProvider<UserStats>((ref) {
  final isar = ref.watch(isarProvider);
  return isar.userStats.watchObject(1, fireImmediately: true).map(
        (stats) => stats ?? UserStats(),
      );
});

// ─── Earth state ─────────────────────────────────────────────────────────────

/// The combined app-wide state exposed to the UI.
class EarthAppState {
  final EarthMetrics metrics;
  final UserStats userStats;
  final bool isLoading;

  /// True when the user has tapped "complete" today (resets on next day).
  final bool dailyHabitDone;

  /// IDs of currently active simulator action toggles.
  final Set<String> activeActionIds;

  const EarthAppState({
    required this.metrics,
    required this.userStats,
    this.isLoading = false,
    this.dailyHabitDone = false,
    this.activeActionIds = const {},
  });

  EarthAppState copyWith({
    EarthMetrics? metrics,
    UserStats? userStats,
    bool? isLoading,
    bool? dailyHabitDone,
    Set<String>? activeActionIds,
  }) {
    return EarthAppState(
      metrics: metrics ?? this.metrics,
      userStats: userStats ?? this.userStats,
      isLoading: isLoading ?? this.isLoading,
      dailyHabitDone: dailyHabitDone ?? this.dailyHabitDone,
      activeActionIds: activeActionIds ?? this.activeActionIds,
    );
  }

  /// Computed property translating XP into real-world units.
  RealWorldImpact get impact => RealWorldImpact.fromXp(userStats.totalXp);
}

// ─────────────────────────────────────────────────────────────────────────────

/// [StateNotifier] that owns [EarthAppState] and drives Earth health
/// changes based on recorded user activity and simulator toggles.
class EarthStateNotifier extends StateNotifier<EarthAppState> {
  final HabitRepository _repo;

  EarthStateNotifier(this._repo)
      : super(EarthAppState(
          metrics: EarthMetrics.initial,
          userStats: UserStats(),
          isLoading: true,
        )) {
    _init();
  }

  // ─── Init ────────────────────────────────────────────────────────────────

  Future<void> _init() async {
    try {
      final stats = await _repo.fetchStats();
      final alreadyDone = _completedToday(stats);
      state = state.copyWith(
        userStats: stats,
        metrics: _recomputeMetrics(stats, state.activeActionIds),
        isLoading: false,
        dailyHabitDone: alreadyDone,
      );
    } catch (e, st) {
      assert(() {
        // ignore: avoid_print
        print('[EarthStateNotifier] init error: $e\n$st');
        return true;
      }());
      state = state.copyWith(isLoading: false);
    }
  }

  // ─── Public API ──────────────────────────────────────────────────────────

  /// Call this when the user completes a lesson or activity.
  Future<void> recordActivity({int xpGained = 10}) async {
    state = state.copyWith(isLoading: true);
    try {
      final updated = await _repo.recordActivity(xpGained: xpGained);
      state = state.copyWith(
        userStats: updated,
        metrics: _recomputeMetrics(updated, state.activeActionIds),
        isLoading: false,
      );
    } catch (e) {
      ToastService.show('Failed to record activity. Simulation stable.', isError: true);
      state = state.copyWith(isLoading: false);
    }
  }

  /// Marks today's daily habit as complete. Awards 25 XP.
  Future<void> completeDailyHabit() async {
    if (state.dailyHabitDone) return;
    state = state.copyWith(isLoading: true);
    try {
      final updated = await _repo.recordActivity(xpGained: 25);
      state = state.copyWith(
        userStats: updated,
        metrics: _recomputeMetrics(updated, state.activeActionIds),
        isLoading: false,
        dailyHabitDone: true,
      );
    } catch (_) {
      ToastService.show('Snapshot failed. Retrying simulation...', isError: true);
      state = state.copyWith(isLoading: false);
    }
  }

  /// Persists the Earth rank chosen during onboarding.
  Future<void> setEarthRank(String rank) async {
    try {
      final updated = await _repo.saveEarthRank(rank);
      state = state.copyWith(userStats: updated);
    } catch (_) {
      ToastService.show('Could not save Earth Rank.', isError: true);
    }
  }

  /// Updates how far through a lesson the user is.
  Future<void> updateLessonProgress(
    String lessonId,
    int done,
    int total,
  ) async {
    try {
      final updated = await _repo.updateLessonProgress(lessonId, done, total);
      state = state.copyWith(
        userStats: updated,
        metrics: _recomputeMetrics(updated, state.activeActionIds),
      );
    } catch (_) {
      ToastService.show('Lesson sync failed.', isError: true);
    }
  }

  // ─── Simulator action toggles ─────────────────────────────────────────────

  /// Activates a simulator action toggle.
  /// Pure in-memory — no DB write, instant state update.
  void applyAction(ActionToggle action) {
    final next = {...state.activeActionIds, action.id};
    state = state.copyWith(
      activeActionIds: next,
      metrics: _recomputeMetrics(state.userStats, next),
    );
  }

  /// Deactivates a simulator action toggle.
  void removeAction(ActionToggle action) {
    final next = {...state.activeActionIds}..remove(action.id);
    state = state.copyWith(
      activeActionIds: next,
      metrics: _recomputeMetrics(state.userStats, next),
    );
  }

  // ─── Metric computation ───────────────────────────────────────────────────

  /// Single source of truth for all metric derivation.
  ///
  /// Computes: XP-baseline + Σ(all active action deltas).
  /// This ensures toggling always produces exact, drift-free values.
  EarthMetrics _recomputeMetrics(UserStats stats, Set<String> activeIds) {
    final units = stats.totalXp / 10.0;

    // XP-derived baseline
    double temp   = (EarthMetrics.initial.temp - units * 0.02).clamp(0.5, 4.0);
    double co2    = (EarthMetrics.initial.co2 - units).clamp(280.0, 500.0);
    double ice    = (EarthMetrics.initial.ice + units * 0.005).clamp(0.0, 1.0);
    double health = (EarthMetrics.initial.healthScore + units * 0.3).clamp(0.0, 100.0);

    // Layer active simulator actions on top
    for (final action in kSimulatorActions) {
      if (activeIds.contains(action.id)) {
        temp   += action.dTemp;
        co2    += action.dCo2;
        ice    += action.dIce;
        health += action.dHealth;
      }
    }

    return EarthMetrics(
      temp:        double.parse(temp.clamp(0.1, 4.0).toStringAsFixed(2)),
      co2:         double.parse(co2.clamp(280.0, 500.0).toStringAsFixed(1)),
      ice:         double.parse(ice.clamp(0.0, 1.0).toStringAsFixed(3)),
      healthScore: double.parse(health.clamp(0.0, 100.0).toStringAsFixed(1)),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  bool _completedToday(UserStats stats) {
    if (stats.lastActivityDate == null) return false;
    final now  = DateTime.now().toUtc();
    final last = stats.lastActivityDate!.toUtc();
    return last.year == now.year &&
        last.month == now.month &&
        last.day == now.day;
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// The primary provider consumed by all UI widgets.
final earthStateProvider =
    StateNotifierProvider<EarthStateNotifier, EarthAppState>((ref) {
  final repo = ref.watch(habitRepositoryProvider);
  return EarthStateNotifier(repo);
});
