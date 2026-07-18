import 'package:drift/drift.dart';

import '../../../shared/dates.dart';
import '../../../shared/journal_enums.dart';
import '../app_database.dart';
import '../tables/journal_entries.dart';
import '../tables/journal_entry_tags.dart';

part 'journal_dao.g.dart';

/// DAO for the journal cluster: entries plus their evening tags. Transactional
/// save (entry + tags in one go) is orchestrated by `JournalRepository`
/// (Sprint 5); this layer exposes the primitives.
@DriftAccessor(tables: [JournalEntries, JournalEntryTags])
class JournalDao extends DatabaseAccessor<AppDatabase> with _$JournalDaoMixin {
  JournalDao(super.db);

  Future<int> insertEntry(JournalEntriesCompanion entry) =>
      into(journalEntries).insert(entry);

  Future<void> updateEntry(int id, JournalEntriesCompanion entry) =>
      (update(journalEntries)..where((e) => e.id.equals(id))).write(entry);

  Future<int> insertTag(JournalEntryTagsCompanion tag) =>
      into(journalEntryTags).insert(tag);

  /// Clears an entry's evening tags — used by the upsert before re-inserting the
  /// current selection, so editing a day replaces its tags instead of stacking.
  Future<void> deleteTags(int journalEntryId) =>
      (delete(journalEntryTags)..where((t) => t.journalEntryId.equals(journalEntryId)))
          .go();

  Future<JournalEntry?> getEntry(int id) =>
      (select(journalEntries)..where((e) => e.id.equals(id))).getSingleOrNull();

  /// The single entry for a (day, type), if any. Safe to treat as at-most-one:
  /// the unique (date, type) index guarantees it. Backs upsert + screen prefill.
  Future<JournalEntry?> getEntryForDay(DateTime day, JournalType type) =>
      _entryForDayQuery(day, type).getSingleOrNull();

  Stream<JournalEntry?> watchEntryForDay(DateTime day, JournalType type) =>
      _entryForDayQuery(day, type).watchSingleOrNull();

  SimpleSelectStatement<$JournalEntriesTable, JournalEntry> _entryForDayQuery(
    DateTime day,
    JournalType type,
  ) {
    final start = dayOf(day);
    final end = start.add(const Duration(days: 1));
    return select(journalEntries)
      ..where((e) =>
          e.date.isBiggerOrEqualValue(start) &
          e.date.isSmallerThanValue(end) &
          e.type.equalsValue(type));
  }

  Future<List<JournalEntry>> getAllEntries() => select(journalEntries).get();

  /// Entries on a given day, optionally narrowed to one [JournalType]. `date`
  /// is day-precision, so this matches the whole day, not an exact timestamp.
  Future<List<JournalEntry>> getEntriesForDay(
    DateTime day, {
    JournalType? type,
  }) {
    final start = dayOf(day);
    final end = start.add(const Duration(days: 1));
    final query = select(journalEntries)
      ..where((e) =>
          e.date.isBiggerOrEqualValue(start) & e.date.isSmallerThanValue(end));
    if (type != null) {
      query.where((e) => e.type.equalsValue(type));
    }
    return query.get();
  }

  Future<List<JournalEntryTag>> getTags(int journalEntryId) {
    return (select(journalEntryTags)
          ..where((t) => t.journalEntryId.equals(journalEntryId)))
        .get();
  }
}
