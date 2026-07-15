import 'package:drift/drift.dart';

import '../../../shared/check_in_status.dart';
import 'habits.dart';

/// The real "streak record": an **append-only event log** of daily check-ins,
/// not a single mutable row (SPRINT_PLAN). Modeling it as history means a streak
/// reset never loses the past — these rows are **never deleted or mutated** by a
/// reset. `status` is success or relapse; a relapse row is paired with a
/// [RelapseEvents] row in the same transaction (Sprint 4).
class HabitCheckIns extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId =>
      integer().references(Habits, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get date => dateTime()();
  TextColumn get status => textEnum<CheckInStatus>()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
