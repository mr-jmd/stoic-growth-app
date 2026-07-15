import 'package:app/src/core/database/app_database.dart';
import 'package:app/src/core/database/repositories/habit_repository.dart';
import 'package:app/src/core/database/repositories/journal_repository.dart';
import 'package:app/src/core/database/repositories/user_profile_repository.dart';
import 'package:app/src/shared/check_in_status.dart';
import 'package:app/src/shared/journal_enums.dart';
import 'package:app/src/shared/virtue.dart';
import 'package:drift/drift.dart' show Migrator;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late HabitRepository habits;
  late JournalRepository journal;
  late UserProfileRepository profiles;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    habits = HabitRepository(db);
    journal = JournalRepository(db);
    profiles = UserProfileRepository(db);
  });

  tearDown(() => db.close());

  group('HabitRepository', () {
    test('inserts a habit', () async {
      final id = await habits.addHabit(label: 'Meditar', virtue: Virtue.sabiduria);
      final habit = await habits.getHabit(id);

      expect(habit, isNotNull);
      expect(habit!.label, 'Meditar');
      expect(habit.virtue, Virtue.sabiduria);
      expect(habit.currentStreakCount, 0);
      expect(habit.archived, isFalse);
    });

    test('a success check-in appends history and increments the streak', () async {
      final id = await habits.addHabit(label: 'Ducha fría', virtue: Virtue.coraje);

      await habits.recordCheckIn(habitId: id, status: CheckInStatus.success);
      await habits.recordCheckIn(habitId: id, status: CheckInStatus.success);

      final habit = await habits.getHabit(id);
      expect(habit!.currentStreakCount, 2);
      expect((await habits.getCheckIns(id)).length, 2);
    });

    test('logging a relapse never mutates or deletes prior check-in history',
        () async {
      final id = await habits.addHabit(label: 'Redes', virtue: Virtue.templanza);
      await habits.recordCheckIn(habitId: id, status: CheckInStatus.success);
      await habits.recordCheckIn(habitId: id, status: CheckInStatus.success);

      final before = await habits.getCheckIns(id);
      expect(before.length, 2);
      final beforeIds = before.map((c) => c.id).toList();

      // Record the relapse (check-in row) + the learning event.
      final relapseCheckInId =
          await habits.recordCheckIn(habitId: id, status: CheckInStatus.relapse);
      await habits.logRelapseEvent(
        habitId: id,
        checkInId: relapseCheckInId,
        context: 'Noche difícil',
        learning: 'Reconocer el detonante antes',
      );

      final after = await habits.getCheckIns(id);
      // The two earlier successes are still there, unchanged (append-only log).
      expect(after.length, 3);
      expect(after.map((c) => c.id), containsAll(beforeIds));
      expect(
        after.where((c) => c.status == CheckInStatus.success).length,
        2,
      );

      final events = await habits.getRelapseEvents(id);
      expect(events.length, 1);
      expect(events.first.learning, 'Reconocer el detonante antes');

      // Streak resets to 0 as a default (immediately re-editable).
      expect((await habits.getHabit(id))!.currentStreakCount, 0);
    });

    test('a manual streak edit persists and leaves history untouched', () async {
      final id = await habits.addHabit(label: 'Leer', virtue: Virtue.sabiduria);
      await habits.recordCheckIn(habitId: id, status: CheckInStatus.success);

      await habits.updateStreakManually(id, 42);

      expect((await habits.getHabit(id))!.currentStreakCount, 42);
      // The manual overwrite doesn't remove the check-in history.
      expect((await habits.getCheckIns(id)).length, 1);
    });

    test('active-habit count ignores archived habits', () async {
      final a = await habits.addHabit(label: 'A', virtue: Virtue.justicia);
      await habits.addHabit(label: 'B', virtue: Virtue.coraje);
      expect(await habits.countActiveHabits(), 2);

      await habits.archiveHabit(a);
      expect(await habits.countActiveHabits(), 1);
    });
  });

  group('JournalRepository', () {
    test('saves an evening entry with its tags atomically', () async {
      final day = DateTime(2026, 7, 14);
      final id = await journal.saveEntry(
        date: day,
        type: JournalType.evening,
        moodScore: 2,
        energyScore: 1,
        tags: [EveningTag.calm, EveningTag.advanced],
      );

      expect((await journal.getTags(id)).toSet(),
          {EveningTag.calm, EveningTag.advanced});

      final entries = await journal.getEntriesForDay(day, type: JournalType.evening);
      expect(entries.length, 1);
      expect(entries.first.moodScore, 2);
      expect(entries.first.energyScore, 1);
    });

    test('mood/energy are optional — an entry saves without them', () async {
      final day = DateTime(2026, 7, 14);
      await journal.saveEntry(
        date: day,
        type: JournalType.morning,
        freeText: 'Hoy depende de mí mantener la calma',
      );

      final entries = await journal.getEntriesForDay(day, type: JournalType.morning);
      expect(entries.length, 1);
      expect(entries.first.moodScore, isNull);
      expect(entries.first.energyScore, isNull);
      expect(await journal.getTags(entries.first.id), isEmpty);
    });
  });

  group('UserProfileRepository', () {
    test('creates and reads a profile (no auth fields exist)', () async {
      final id = await profiles.createProfile(displayName: 'Marco');
      final profile = await profiles.getProfile();

      expect(profile, isNotNull);
      expect(profile!.id, id);
      expect(profile.displayName, 'Marco');
    });
  });

  group('schema & migration', () {
    test('schemaVersion is 2 and onUpgrade is wired and invocable', () async {
      expect(db.schemaVersion, 2);

      // Placeholder for future migrations: the onUpgrade handler is wired and
      // invoking it for the current version is a safe no-op (the v1→v2 branch is
      // guarded by `from < 2`).
      final Migrator migrator = db.createMigrator();
      await db.migration.onUpgrade(migrator, 2, 2);

      // The DB is still usable afterwards.
      expect(await habits.countActiveHabits(), 0);
    });
  });
}
