import 'package:drift/drift.dart';

import '../../../shared/virtue.dart';

/// A habit/virtue the user chooses to work on. `virtue` is the fixed [Virtue]
/// enum stored via Drift's `textEnum` type converter (the set is core to the
/// product, not a lookup table — SPRINT_PLAN). Display labels live in l10n.
///
/// `currentStreakCount` is a plain, directly-editable integer: normally
/// recomputed when a [HabitCheckIns] row is inserted, but a manual UI edit just
/// overwrites the column (same mechanism, no schema special-case). The 3-active
/// cap is a UI/repository constraint, not a schema one; `archived` habits don't
/// count against it.
class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get label => text().withLength(min: 1, max: 80)();
  TextColumn get virtue => textEnum<Virtue>()();
  IntColumn get currentStreakCount => integer().withDefault(const Constant(0))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
