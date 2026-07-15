import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

// Enum types used by the generated type converters (this file's `part` .g.dart
// resolves them through these imports).
import '../../shared/check_in_status.dart';
import '../../shared/journal_enums.dart';
import '../../shared/virtue.dart';
import 'daos/app_meta_dao.dart';
import 'daos/habits_dao.dart';
import 'daos/journal_dao.dart';
import 'daos/user_profile_dao.dart';
import 'tables/app_meta.dart';
import 'tables/habit_check_ins.dart';
import 'tables/habits.dart';
import 'tables/journal_entries.dart';
import 'tables/journal_entry_tags.dart';
import 'tables/relapse_events.dart';
import 'tables/user_profiles.dart';

part 'app_database.g.dart';

/// The on-device source of truth (local-first, fully offline). Holds the five
/// MVP entities plus the join/history tables. Static content (quotes, crisis
/// scripts) stays **out** of Drift — it's build-time content, not user data.
@DriftDatabase(
  tables: [
    AppMeta,
    UserProfiles,
    Habits,
    JournalEntries,
    JournalEntryTags,
    HabitCheckIns,
    RelapseEvents,
  ],
  daos: [AppMetaDao, HabitsDao, JournalDao, UserProfileDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'app_database'));

  /// Test constructor — inject a `NativeDatabase.memory()` executor so unit
  /// tests run against a fresh in-memory DB with no file/native asset.
  AppDatabase.forTesting(super.executor);

  // v1 (Sprint 0): AppMeta only. v2 (Sprint 2): the full MVP schema.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) => m.createAll(),
      onUpgrade: (m, from, to) async {
        // v1 → v2: AppMeta already exists; create the tables added in Sprint 2.
        if (from < 2) {
          await m.createTable(userProfiles);
          await m.createTable(habits);
          await m.createTable(journalEntries);
          await m.createTable(journalEntryTags);
          await m.createTable(habitCheckIns);
          await m.createTable(relapseEvents);
        }
      },
      beforeOpen: (details) async {
        // Enforce the FK references declared on the history/join tables.
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }
}
