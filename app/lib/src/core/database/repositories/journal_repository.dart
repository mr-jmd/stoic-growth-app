import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/dates.dart';
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

  /// Upserts the single entry for a (day, type) plus its evening [tags], all in
  /// one transaction. Re-saving the same day **edits** that entry instead of
  /// duplicating (backed by the unique (date, type) index): existing tags are
  /// cleared and replaced with the current selection. `date` is normalized to
  /// local midnight so the day key is stable. `moodScore`/`energyScore` are
  /// optional — mood/energy is never required to save. Returns the entry id.
  Future<int> saveEntry({
    required DateTime date,
    required JournalType type,
    JournalInputMethod inputMethod = JournalInputMethod.typed,
    String? freeText,
    int? moodScore,
    int? energyScore,
    List<EveningTag> tags = const [],
  }) {
    final day = dayOf(date);
    return _db.transaction(() async {
      final existing = await _dao.getEntryForDay(day, type);
      final int entryId;
      if (existing == null) {
        entryId = await _dao.insertEntry(JournalEntriesCompanion.insert(
          date: day,
          type: type,
          inputMethod: inputMethod,
          freeText: Value(freeText),
          moodScore: Value(moodScore),
          energyScore: Value(energyScore),
        ));
      } else {
        entryId = existing.id;
        await _dao.updateEntry(
          entryId,
          JournalEntriesCompanion(
            inputMethod: Value(inputMethod),
            freeText: Value(freeText),
            moodScore: Value(moodScore),
            energyScore: Value(energyScore),
          ),
        );
        await _dao.deleteTags(entryId);
      }
      for (final tag in tags) {
        await _dao.insertTag(JournalEntryTagsCompanion.insert(
          journalEntryId: entryId,
          tag: tag,
        ));
      }
      return entryId;
    });
  }

  /// The low-friction morning entry: a short "Hoy depende de mí: ___" phrase
  /// (README 10.1), plus optional mood/energy. Delegates to the [saveEntry]
  /// upsert so a second save of the same morning edits, not duplicates.
  Future<int> saveMorningEntry({
    required DateTime date,
    String? phrase,
    int? moodScore,
    int? energyScore,
    JournalInputMethod inputMethod = JournalInputMethod.typed,
  }) =>
      saveEntry(
        date: date,
        type: JournalType.morning,
        inputMethod: inputMethod,
        freeText: phrase,
        moodScore: moodScore,
        energyScore: energyScore,
      );

  /// The low-friction evening entry: the fixed multi-select reflection [tags]
  /// (README 10.1), an optional opt-in [freeText] note, plus optional
  /// mood/energy. Upserts like [saveMorningEntry].
  Future<int> saveEveningEntry({
    required DateTime date,
    List<EveningTag> tags = const [],
    String? freeText,
    int? moodScore,
    int? energyScore,
    JournalInputMethod inputMethod = JournalInputMethod.typed,
  }) =>
      saveEntry(
        date: date,
        type: JournalType.evening,
        inputMethod: inputMethod,
        freeText: freeText,
        moodScore: moodScore,
        energyScore: energyScore,
        tags: tags,
      );

  Future<List<JournalEntry>> getEntriesForDay(DateTime day, {JournalType? type}) =>
      _dao.getEntriesForDay(day, type: type);

  /// The single entry for a (day, type), for screen prefill when reopening a day.
  Future<JournalEntry?> getEntryForDay(DateTime day, JournalType type) =>
      _dao.getEntryForDay(day, type);

  Future<List<JournalEntry>> getAllEntries() => _dao.getAllEntries();

  Future<List<EveningTag>> getTags(int entryId) async {
    final rows = await _dao.getTags(entryId);
    return rows.map((r) => r.tag).toList();
  }
}

@riverpod
JournalRepository journalRepository(Ref ref) =>
    JournalRepository(ref.watch(appDatabaseProvider));
