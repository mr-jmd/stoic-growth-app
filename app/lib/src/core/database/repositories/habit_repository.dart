import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/check_in_status.dart';
import '../../../shared/virtue.dart';
import '../app_database.dart';
import '../daos/habits_dao.dart';
import '../database_provider.dart';

part 'habit_repository.g.dart';

/// Concrete repository over [HabitsDao] — no abstract interface (single impl;
/// tests override [appDatabaseProvider] with an in-memory DB instead, per
/// SPRINT_PLAN). Foundational CRUD lives here; Sprint 3 adds the 3-active cap /
/// onboarding orchestration and Sprint 4 the transactional relapse flow, both
/// reusing these methods.
class HabitRepository {
  HabitRepository(this._db);

  final AppDatabase _db;
  HabitsDao get _dao => _db.habitsDao;

  Future<int> addHabit({
    required String label,
    required Virtue virtue,
    int sortOrder = 0,
  }) {
    return _dao.insertHabit(HabitsCompanion.insert(
      label: label,
      virtue: virtue,
      sortOrder: Value(sortOrder),
    ));
  }

  Stream<List<Habit>> watchActiveHabits() => _dao.watchActiveHabits();
  Future<List<Habit>> getAllHabits() => _dao.getAllHabits();
  Future<Habit?> getHabit(int id) => _dao.getHabit(id);
  Future<int> countActiveHabits() => _dao.countActiveHabits();

  /// Directly overwrites the streak count (the user-editable path). History is
  /// never touched.
  Future<void> setStreakCount(int habitId, int count) =>
      _dao.setStreakCount(habitId, count);

  Future<void> archiveHabit(int habitId) =>
      _dao.setArchived(habitId, archived: true);

  /// Appends a check-in and recomputes the streak in one transaction: a
  /// `success` increments the count, a `relapse` resets it to 0 (as an
  /// immediately re-editable default, never a locked reset). The history row is
  /// append-only. Returns the new check-in id.
  Future<int> recordCheckIn({
    required int habitId,
    required CheckInStatus status,
    String? note,
    DateTime? date,
  }) {
    return _db.transaction(() async {
      final habit = await _dao.getHabit(habitId);
      if (habit == null) {
        throw StateError('Habit $habitId does not exist');
      }
      final checkInId = await _dao.insertCheckIn(HabitCheckInsCompanion.insert(
        habitId: habitId,
        date: date ?? DateTime.now(),
        status: status,
        note: Value(note),
      ));
      final newStreak =
          status == CheckInStatus.success ? habit.currentStreakCount + 1 : 0;
      await _dao.setStreakCount(habitId, newStreak);
      return checkInId;
    });
  }

  /// Records a relapse as a learning event (all fields optional). Pure history —
  /// does not delete or mutate any prior [HabitCheckIns]/[RelapseEvents] row.
  /// Sprint 4 wraps this together with the check-in insert in one transaction.
  Future<int> logRelapseEvent({
    required int habitId,
    int? checkInId,
    String? context,
    String? trigger,
    String? learning,
  }) {
    return _dao.insertRelapseEvent(RelapseEventsCompanion.insert(
      habitId: habitId,
      checkInId: Value(checkInId),
      context: Value(context),
      trigger: Value(trigger),
      learning: Value(learning),
    ));
  }

  Future<List<HabitCheckIn>> getCheckIns(int habitId) =>
      _dao.getCheckIns(habitId);
  Stream<List<HabitCheckIn>> watchCheckIns(int habitId) =>
      _dao.watchCheckIns(habitId);
  Future<List<RelapseEvent>> getRelapseEvents(int habitId) =>
      _dao.getRelapseEvents(habitId);
}

@riverpod
HabitRepository habitRepository(Ref ref) =>
    HabitRepository(ref.watch(appDatabaseProvider));
