// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habits_dao.dart';

// ignore_for_file: type=lint
mixin _$HabitsDaoMixin on DatabaseAccessor<AppDatabase> {
  $HabitsTable get habits => attachedDatabase.habits;
  $HabitCheckInsTable get habitCheckIns => attachedDatabase.habitCheckIns;
  $RelapseEventsTable get relapseEvents => attachedDatabase.relapseEvents;
  HabitsDaoManager get managers => HabitsDaoManager(this);
}

class HabitsDaoManager {
  final _$HabitsDaoMixin _db;
  HabitsDaoManager(this._db);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db.attachedDatabase, _db.habits);
  $$HabitCheckInsTableTableManager get habitCheckIns =>
      $$HabitCheckInsTableTableManager(_db.attachedDatabase, _db.habitCheckIns);
  $$RelapseEventsTableTableManager get relapseEvents =>
      $$RelapseEventsTableTableManager(_db.attachedDatabase, _db.relapseEvents);
}
