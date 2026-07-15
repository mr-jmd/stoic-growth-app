import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/journal_enums.dart';
import '../app_database.dart';
import '../daos/journal_dao.dart';
import '../database_provider.dart';

part 'journal_repository.g.dart';

/// Concrete repository over [JournalDao]. Saves an entry and its evening tags in
/// one transaction. Sprint 5 adds the unique (date, type) index so re-saving the
/// same day edits instead of duplicating, and the low-friction morning/evening
/// UI on top.
class JournalRepository {
  JournalRepository(this._db);

  final AppDatabase _db;
  JournalDao get _dao => _db.journalDao;

  /// Inserts a journal entry plus any evening [tags] atomically. Returns the
  /// entry id. `moodScore`/`energyScore` are optional (mood/energy is never
  /// required to save an entry).
  Future<int> saveEntry({
    required DateTime date,
    required JournalType type,
    JournalInputMethod inputMethod = JournalInputMethod.typed,
    String? freeText,
    int? moodScore,
    int? energyScore,
    List<EveningTag> tags = const [],
  }) {
    return _db.transaction(() async {
      final entryId = await _dao.insertEntry(JournalEntriesCompanion.insert(
        date: date,
        type: type,
        inputMethod: inputMethod,
        freeText: Value(freeText),
        moodScore: Value(moodScore),
        energyScore: Value(energyScore),
      ));
      for (final tag in tags) {
        await _dao.insertTag(JournalEntryTagsCompanion.insert(
          journalEntryId: entryId,
          tag: tag,
        ));
      }
      return entryId;
    });
  }

  Future<List<JournalEntry>> getEntriesForDay(DateTime day, {JournalType? type}) =>
      _dao.getEntriesForDay(day, type: type);

  Future<List<JournalEntry>> getAllEntries() => _dao.getAllEntries();

  Future<List<EveningTag>> getTags(int entryId) async {
    final rows = await _dao.getTags(entryId);
    return rows.map((r) => r.tag).toList();
  }
}

@riverpod
JournalRepository journalRepository(Ref ref) =>
    JournalRepository(ref.watch(appDatabaseProvider));
