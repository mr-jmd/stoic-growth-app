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

    test('logRelapse appends both history rows atomically and resets the streak',
        () async {
      final id = await habits.addHabit(label: 'Redes', virtue: Virtue.templanza);
      await habits.recordCheckIn(habitId: id, status: CheckInStatus.success);
      await habits.recordCheckIn(habitId: id, status: CheckInStatus.success);

      final before = await habits.getCheckIns(id);
      final beforeIds = before.map((c) => c.id).toList();
      expect(before.length, 2);

      final checkInId = await habits.logRelapse(
        habitId: id,
        context: 'Noche difícil',
        trigger: 'Aburrimiento',
        learning: 'Reconocer el detonante antes',
      );

      // Both rows landed: a relapse check-in + its paired learning event.
      final after = await habits.getCheckIns(id);
      expect(after.length, 3);
      // The two earlier successes are untouched (append-only log).
      expect(after.map((c) => c.id), containsAll(beforeIds));
      expect(after.where((c) => c.status == CheckInStatus.success).length, 2);
      expect(after.singleWhere((c) => c.status == CheckInStatus.relapse).id,
          checkInId);

      final events = await habits.getRelapseEvents(id);
      expect(events.length, 1);
      expect(events.single.checkInId, checkInId);
      expect(events.single.context, 'Noche difícil');
      expect(events.single.trigger, 'Aburrimiento');
      expect(events.single.learning, 'Reconocer el detonante antes');

      // Streak reset to 0 as a re-editable default.
      expect((await habits.getHabit(id))!.currentStreakCount, 0);
    });

    test('logRelapse records with all fields omitted (nothing is required)',
        () async {
      final id = await habits.addHabit(label: 'X', virtue: Virtue.coraje);
      await habits.logRelapse(habitId: id);

      final events = await habits.getRelapseEvents(id);
      expect(events.length, 1);
      expect(events.single.context, isNull);
      expect(events.single.trigger, isNull);
      expect(events.single.learning, isNull);
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

    test('re-saving the same (day, type) edits in place, never duplicates',
        () async {
      // A time-of-day component must not create a second row for the same day.
      final morning = DateTime(2026, 7, 15, 7, 30);
      final id1 = await journal.saveMorningEntry(
        date: morning,
        phrase: 'Mi enfoque',
        moodScore: 1,
      );
      final id2 = await journal.saveMorningEntry(
        date: DateTime(2026, 7, 15, 22, 05),
        phrase: 'Mi actitud',
        moodScore: 3,
      );

      expect(id2, id1); // same row upserted
      final entries =
          await journal.getEntriesForDay(morning, type: JournalType.morning);
      expect(entries.length, 1);
      expect(entries.single.freeText, 'Mi actitud');
      expect(entries.single.moodScore, 3);
      // A morning upsert doesn't touch that day's evening entry.
      await journal.saveEveningEntry(
          date: morning, tags: [EveningTag.calm]);
      expect((await journal.getAllEntries()).length, 2);
    });

    test('re-saving an evening entry replaces its tags, not stacks them',
        () async {
      final day = DateTime(2026, 7, 16);
      await journal.saveEveningEntry(
        date: day,
        tags: [EveningTag.calm, EveningTag.reacted],
      );
      final id = (await journal.getEntryForDay(day, JournalType.evening))!.id;
      expect((await journal.getTags(id)).length, 2);

      await journal.saveEveningEntry(date: day, tags: [EveningTag.advanced]);

      final entries =
          await journal.getEntriesForDay(day, type: JournalType.evening);
      expect(entries.length, 1);
      expect(await journal.getTags(entries.single.id), [EveningTag.advanced]);
    });

    test('entries are recoverable by day and type', () async {
      final day = DateTime(2026, 7, 17);
      await journal.saveMorningEntry(date: day, phrase: 'Mi esfuerzo');
      await journal.saveEveningEntry(date: day, tags: [EveningTag.advanced]);

      final morning = await journal.getEntryForDay(day, JournalType.morning);
      final evening = await journal.getEntryForDay(day, JournalType.evening);
      expect(morning!.freeText, 'Mi esfuerzo');
      expect(evening!.freeText, isNull);
      expect(await journal.getTags(evening.id), [EveningTag.advanced]);
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
    test('schemaVersion is 3 and onUpgrade is wired and invocable', () async {
      expect(db.schemaVersion, 3);

      // The onUpgrade handler is wired; invoking it for the current version is a
      // safe no-op (both the v1→v2 and v2→v3 branches are guarded by `from < n`).
      final Migrator migrator = db.createMigrator();
      await db.migration.onUpgrade(migrator, 3, 3);

      // The DB is still usable afterwards.
      expect(await habits.countActiveHabits(), 0);
    });
  });
}
