import 'package:drift/drift.dart';

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

  Future<int> insertTag(JournalEntryTagsCompanion tag) =>
      into(journalEntryTags).insert(tag);

  Future<JournalEntry?> getEntry(int id) =>
      (select(journalEntries)..where((e) => e.id.equals(id))).getSingleOrNull();

  Future<List<JournalEntry>> getAllEntries() => select(journalEntries).get();

  /// Entries on a given day, optionally narrowed to one [JournalType]. `date`
  /// is day-precision, so this matches the whole day, not an exact timestamp.
  Future<List<JournalEntry>> getEntriesForDay(
    DateTime day, {
    JournalType? type,
  }) {
    final start = DateTime(day.year, day.month, day.day);
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
