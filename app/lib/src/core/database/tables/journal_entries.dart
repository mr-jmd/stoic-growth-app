import 'package:drift/drift.dart';

import '../../../shared/journal_enums.dart';

/// A morning or evening journal entry (README 4.1 / 10.1). `date` is
/// day-precision (store at local midnight); a unique (date, type) index is
/// added in Sprint 5 so reopening the same day edits instead of duplicating.
///
/// `moodScore` / `energyScore` are the mood/energy capture confirmed for the
/// MVP — nullable (always optional) and surfaced in the UI as qualitative chips
/// (low/medium/high), never a clinical numeric scale (Sprint 5). `freeText` is
/// opt-in; the low-friction path is chips/voice.
class JournalEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get type => textEnum<JournalType>()();
  TextColumn get inputMethod => textEnum<JournalInputMethod>()();
  TextColumn get freeText => text().nullable()();
  IntColumn get moodScore => integer().nullable()();
  IntColumn get energyScore => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
