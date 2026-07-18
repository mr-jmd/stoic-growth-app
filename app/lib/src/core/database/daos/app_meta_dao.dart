import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/app_meta.dart';

part 'app_meta_dao.g.dart';

/// DAO for the single-row app-level state table. Sprint 3 uses it for the
/// onboarding-completed flag — tracked here explicitly, **not** inferred from
/// habit count, so a user who later archives every habit lands on an empty
/// state instead of being forced back through onboarding.
@DriftAccessor(tables: [AppMeta])
class AppMetaDao extends DatabaseAccessor<AppDatabase> with _$AppMetaDaoMixin {
  AppMetaDao(super.db);

  // The meta table is single-row; pin it to a fixed id.
  static const int _rowId = 1;

  Stream<bool> watchOnboardingCompleted() {
    return (select(appMeta)..where((m) => m.id.equals(_rowId)))
        .watchSingleOrNull()
        .map((row) => row?.onboardingCompleted ?? false);
  }

  Future<bool> isOnboardingCompleted() async {
    final row = await (select(appMeta)..where((m) => m.id.equals(_rowId)))
        .getSingleOrNull();
    return row?.onboardingCompleted ?? false;
  }

  Future<void> setOnboardingCompleted({required bool completed}) {
    return into(appMeta).insertOnConflictUpdate(
      AppMetaCompanion(
        id: const Value(_rowId),
        onboardingCompleted: Value(completed),
      ),
    );
  }

  // ── Guided-tour flag (v4) — same single-row pattern ───────────────────────

  Stream<bool> watchTutorialCompleted() {
    return (select(appMeta)..where((m) => m.id.equals(_rowId)))
        .watchSingleOrNull()
        .map((row) => row?.tutorialCompleted ?? false);
  }

  Future<bool> isTutorialCompleted() async {
    final row = await (select(appMeta)..where((m) => m.id.equals(_rowId)))
        .getSingleOrNull();
    return row?.tutorialCompleted ?? false;
  }

  /// Careful: `insertOnConflictUpdate` writes every column it's given — only
  /// pass the tutorial flag so a set here never clobbers onboarding state.
  Future<void> setTutorialCompleted({required bool completed}) {
    return into(appMeta).insertOnConflictUpdate(
      AppMetaCompanion(
        id: const Value(_rowId),
        tutorialCompleted: Value(completed),
      ),
    );
  }
}
