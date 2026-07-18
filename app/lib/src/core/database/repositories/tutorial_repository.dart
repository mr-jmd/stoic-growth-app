import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../app_database.dart';
import '../daos/app_meta_dao.dart';
import '../database_provider.dart';

part 'tutorial_repository.g.dart';

/// Owns the guided-tour flag (persisted in `AppMeta`, same single-row pattern
/// as onboarding). The tour auto-runs once when this is false after onboarding,
/// and both finishing and skipping mark it complete; home offers a replay.
class TutorialRepository {
  TutorialRepository(this._db);

  final AppDatabase _db;
  AppMetaDao get _dao => _db.appMetaDao;

  Stream<bool> watchCompleted() => _dao.watchTutorialCompleted();
  Future<bool> isCompleted() => _dao.isTutorialCompleted();
  Future<void> complete() => _dao.setTutorialCompleted(completed: true);
}

@riverpod
TutorialRepository tutorialRepository(Ref ref) =>
    TutorialRepository(ref.watch(appDatabaseProvider));

/// Reactive tour-seen state. The shell watches it to auto-start the tour on
/// the first post-onboarding landing.
@riverpod
Stream<bool> tutorialCompleted(Ref ref) =>
    ref.watch(tutorialRepositoryProvider).watchCompleted();
