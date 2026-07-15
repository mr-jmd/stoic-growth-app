import 'package:drift/drift.dart';

import '../../../shared/check_in_status.dart';
import '../app_database.dart';
import '../tables/habit_check_ins.dart';
import '../tables/habits.dart';
import '../tables/relapse_events.dart';

part 'habits_dao.g.dart';

/// DAO for the habit cluster: habits plus their append-only history
/// ([HabitCheckIns], [RelapseEvents]). One DAO per table cluster, not a
/// monolith (SPRINT_PLAN). Higher-level orchestration (3-active cap,
/// transactional relapse logging) lives in the repository / later sprints; this
/// layer stays close to the tables.
@DriftAccessor(tables: [Habits, HabitCheckIns, RelapseEvents])
class HabitsDao extends DatabaseAccessor<AppDatabase> with _$HabitsDaoMixin {
  HabitsDao(super.db);

  // ── Habits ────────────────────────────────────────────────────────────────
  Future<int> insertHabit(HabitsCompanion habit) =>
      into(habits).insert(habit);

  Future<Habit?> getHabit(int id) =>
      (select(habits)..where((h) => h.id.equals(id))).getSingleOrNull();

  Future<List<Habit>> getAllHabits() => select(habits).get();

  /// Active (non-archived) habits, ordered for display. Archived habits don't
  /// count against the 3-active cap enforced in Sprint 3.
  Stream<List<Habit>> watchActiveHabits() {
    return (select(habits)
          ..where((h) => h.archived.equals(false))
          ..orderBy([(h) => OrderingTerm(expression: h.sortOrder)]))
        .watch();
  }

  Future<int> countActiveHabits() async {
    final count = countAll();
    final query = selectOnly(habits)
      ..addColumns([count])
      ..where(habits.archived.equals(false));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// Overwrites the streak column directly (manual UI edit or recompute). The
  /// history tables are untouched — a reset never deletes past rows.
  Future<void> setStreakCount(int habitId, int count) {
    return (update(habits)..where((h) => h.id.equals(habitId)))
        .write(HabitsCompanion(currentStreakCount: Value(count)));
  }

  Future<void> setArchived(int habitId, {required bool archived}) {
    return (update(habits)..where((h) => h.id.equals(habitId)))
        .write(HabitsCompanion(archived: Value(archived)));
  }

  // ── Check-ins (append-only) ───────────────────────────────────────────────
  Future<int> insertCheckIn(HabitCheckInsCompanion checkIn) =>
      into(habitCheckIns).insert(checkIn);

  Future<List<HabitCheckIn>> getCheckIns(int habitId) {
    return (select(habitCheckIns)
          ..where((c) => c.habitId.equals(habitId))
          ..orderBy([(c) => OrderingTerm(expression: c.date)]))
        .get();
  }

  Stream<List<HabitCheckIn>> watchCheckIns(int habitId) {
    return (select(habitCheckIns)
          ..where((c) => c.habitId.equals(habitId))
          ..orderBy([(c) => OrderingTerm(expression: c.date)]))
        .watch();
  }

  Future<int> countCheckIns(int habitId, {CheckInStatus? status}) async {
    final count = countAll();
    final query = selectOnly(habitCheckIns)
      ..addColumns([count])
      ..where(habitCheckIns.habitId.equals(habitId));
    if (status != null) {
      query.where(habitCheckIns.status.equalsValue(status));
    }
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  // ── Relapse events (append-only history) ──────────────────────────────────
  Future<int> insertRelapseEvent(RelapseEventsCompanion event) =>
      into(relapseEvents).insert(event);

  Future<List<RelapseEvent>> getRelapseEvents(int habitId) {
    return (select(relapseEvents)
          ..where((r) => r.habitId.equals(habitId))
          ..orderBy([(r) => OrderingTerm(expression: r.createdAt)]))
        .get();
  }
}
