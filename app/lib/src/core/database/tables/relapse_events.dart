import 'package:drift/drift.dart';

import 'habit_check_ins.dart';
import 'habits.dart';

/// A relapse recorded as a **learning event**, never a failure (README 4.2,
/// *prokopé*). All qualitative fields are optional. Like [HabitCheckIns], these
/// rows are pure history — never deleted or mutated by a streak reset. Linked to
/// the check-in that recorded the relapse (`checkInId`, nullable so a relapse
/// can also be logged standalone).
class RelapseEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId =>
      integer().references(Habits, #id, onDelete: KeyAction.cascade)();
  IntColumn get checkInId =>
      integer().nullable().references(HabitCheckIns, #id)();
  TextColumn get context => text().nullable()();
  TextColumn get trigger => text().nullable()();
  TextColumn get learning => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
