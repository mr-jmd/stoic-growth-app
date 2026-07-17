import '../../core/database/app_database.dart';
import '../../shared/virtue.dart';
import '../../shared/virtue_progress_state.dart';

/// Rolls per-habit consistency up into a per-virtue [VirtueProgressState] for the
/// dashboard. Pure and widget-independent (SPRINT_PLAN) — no Drift query, no
/// `BuildContext`; it takes plain habit rows and returns qualitative state.
///
/// Rules:
/// - Multiple habits can map to the same virtue → the virtue takes the **best**
///   (max) current streak among them (encouraging, never punitive).
/// - **Archived habits don't count.**
/// - A virtue with no active habit reads as [VirtueProgressState.sinDesbastar]
///   (unworked stone) — present and re-buildable, never empty/red.
///
/// The relapse state ([VirtueProgressState.enReposo]) is intentionally **not**
/// derived here: a reset streak of 0 is indistinguishable from a fresh habit at
/// this layer, so "en reposo" stays a per-habit, contextual state (the Sprint 4
/// detail screen), not a dashboard aggregate.
class VirtueProgressCalculator {
  const VirtueProgressCalculator._();

  /// Min streak to read as "tomando color" (any consistency at all).
  static const int tomandoColorThreshold = 1;

  /// Min streak to read as "pulida" (a sustained week).
  static const int pulidaThreshold = 7;

  static Map<Virtue, VirtueProgressState> fromHabits(Iterable<Habit> habits) {
    final maxStreak = <Virtue, int>{};
    for (final h in habits) {
      if (h.archived) continue;
      final current = maxStreak[h.virtue];
      if (current == null || h.currentStreakCount > current) {
        maxStreak[h.virtue] = h.currentStreakCount;
      }
    }
    return {
      for (final v in Virtue.values) v: _stateFor(maxStreak[v]),
    };
  }

  static VirtueProgressState _stateFor(int? streak) {
    if (streak == null) return VirtueProgressState.sinDesbastar;
    if (streak >= pulidaThreshold) return VirtueProgressState.pulida;
    if (streak >= tomandoColorThreshold) return VirtueProgressState.tomandoColor;
    return VirtueProgressState.sinDesbastar;
  }
}
