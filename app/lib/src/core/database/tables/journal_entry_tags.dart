import 'package:drift/drift.dart';

import '../../../shared/journal_enums.dart';
import 'journal_entries.dart';

/// Join table: the fixed evening reflection chips selected for an entry
/// (multi-select, README 10.1). Only evening entries use this — the morning
/// entry is a short phrase, not fixed-option chips.
class JournalEntryTags extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get journalEntryId =>
      integer().references(JournalEntries, #id, onDelete: KeyAction.cascade)();
  TextColumn get tag => textEnum<EveningTag>()();
}
