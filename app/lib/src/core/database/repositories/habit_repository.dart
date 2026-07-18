import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/check_in_status.dart';
import '../../../shared/virtue.dart';
import '../app_database.dart';
import '../daos/habits_dao.dart';
import '../database_provider.dart';

part 'habit_repository.g.dart';

/// Concrete repository over [HabitsDao] — no abstract interface (single impl;
/// tests override [appDatabaseProvider] with an in-memory DB instead, per
/// SPRINT_PLAN). Foundational CRUD lives here; Sprint 4 adds the transactional
/// relapse flow, reusing these methods.
class HabitRepository {
  HabitRepository(this._db);

  final AppDatabase _db;
  HabitsDao get _dao => _db.habitsDao;

  /// Raw insert — foundation used by [createHabit] and tests.
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

  /// Creates a habit. There is no cap on active habits — starting small is a
  /// recommendation carried by onboarding copy, never a block.
  Future<int> createHabit({
    required String label,
    required Virtue virtue,
    int sortOrder = 0,
  }) =>
      addHabit(label: label, virtue: virtue, sortOrder: sortOrder);

  Stream<List<Habit>> watchActiveHabits() => _dao.watchActiveHabits();
  Future<List<Habit>> getAllHabits() => _dao.getAllHabits();
  Future<Habit?> getHabit(int id) => _dao.getHabit(id);
  Stream<Habit?> watchHabit(int id) => _dao.watchHabit(id);
  Future<int> countActiveHabits() => _dao.countActiveHabits();

  /// Directly overwrites the streak count (the user-editable path). History is
  /// never touched. Reused by Sprint 4's tap-to-edit control.
  Future<void> updateStreakManually(int habitId, int count) =>
      _dao.setStreakCount(habitId, count);

  Future<void> archiveHabit(int habitId) =>
      _dao.setArchived(habitId, archived: true);

  /// Appends a check-in and recomputes the streak in one transaction: a
  /// `success` increments the count, a `relapse` resets it to 0 (as an
  /// immediately re-editable default, never a locked reset). The history row is
  /// append-only. Returns the new check-in id.
  ///
  /// **At most one `success` per local calendar day**: recording a second
  /// success the same day is an idempotent no-op that returns the existing
  /// row's id — no new history row, no extra increment. Relapses are never
  /// limited (real life allows several in a day), and the manual streak edit
  /// stays unrestricted (the number is the user's).
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
      final when = date ?? DateTime.now();
      if (status == CheckInStatus.success) {
        final existing = await _dao.successCheckInOn(habitId, when);
        if (existing != null) return existing.id;
      }
      final checkInId = await _dao.insertCheckIn(HabitCheckInsCompanion.insert(
        habitId: habitId,
        date: when,
        status: status,
        note: Value(note),
      ));
      final newStreak =
          status == CheckInStatus.success ? habit.currentStreakCount + 1 : 0;
      await _dao.setStreakCount(habitId, newStreak);
      return checkInId;
    });
  }

  /// The Sprint 4 relapse flow: appends a `relapse` check-in **and** its paired
  /// learning event, then resets the streak to 0 — all in one transaction, so
  /// the two history rows and the reset can never be observed half-applied.
  ///
  /// All qualitative fields are optional (framed as learning, never confession).
  /// The reset is only an immediately re-editable *default* via
  /// [updateStreakManually] — never a locked reset. Prior [HabitCheckIns]/
  /// [RelapseEvents] rows are append-only and left untouched. Returns the new
  /// check-in id.
  Future<int> logRelapse({
    required int habitId,
    String? context,
    String? trigger,
    String? learning,
  }) {
    return _db.transaction(() async {
      final habit = await _dao.getHabit(habitId);
      if (habit == null) {
        throw StateError('Habit $habitId does not exist');
      }
      final checkInId = await _dao.insertCheckIn(HabitCheckInsCompanion.insert(
        habitId: habitId,
        date: DateTime.now(),
        status: CheckInStatus.relapse,
      ));
      await _dao.insertRelapseEvent(RelapseEventsCompanion.insert(
        habitId: habitId,
        checkInId: Value(checkInId),
        context: Value(context),
        trigger: Value(trigger),
        learning: Value(learning),
      ));
      await _dao.setStreakCount(habitId, 0);
      return checkInId;
    });
  }

  /// Records a relapse as a learning event (all fields optional). Pure history —
  /// does not delete or mutate any prior [HabitCheckIns]/[RelapseEvents] row.
  /// Low-level primitive; the two-table [logRelapse] flow is the one the UI uses.
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

/// Live list of active (non-archived) habits — backs the habits list, the home
/// shell, and the "0 active habits" empty state.
///
/// Declared manually (not `@riverpod`) because riverpod_generator can't emit a
/// return type that comes from drift's generated `part` file (build-ordering
/// limitation between the two generators). The behaviour is identical.
final activeHabitsProvider = StreamProvider<List<Habit>>(
  (ref) => ref.watch(habitRepositoryProvider).watchActiveHabits(),
);

/// Live single habit by id — backs the habit-detail screen's streak display so
/// a check-in / relapse / manual edit reflects immediately. Manual (not
/// `@riverpod`) for the same drift-return-type reason as [activeHabitsProvider].
final habitByIdProvider = StreamProvider.family<Habit?, int>(
  (ref, id) => ref.watch(habitRepositoryProvider).watchHabit(id),
);

/// Live append-only check-in history for one habit (newest last, as stored) —
/// backs the consistency-history strip, where past relapses stay visible as
/// data instead of being hidden or deleted.
final habitCheckInsProvider = StreamProvider.family<List<HabitCheckIn>, int>(
  (ref, id) => ref.watch(habitRepositoryProvider).watchCheckIns(id),
);
