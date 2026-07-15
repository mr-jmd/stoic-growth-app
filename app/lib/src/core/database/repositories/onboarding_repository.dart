import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../app_database.dart';
import '../daos/app_meta_dao.dart';
import '../database_provider.dart';

part 'onboarding_repository.g.dart';

/// Owns the onboarding-completed flag (persisted in `AppMeta`). The router's
/// onboarding gate reads this — never the habit count — so archiving all habits
/// after onboarding doesn't force the user back through it.
class OnboardingRepository {
  OnboardingRepository(this._db);

  final AppDatabase _db;
  AppMetaDao get _dao => _db.appMetaDao;

  Stream<bool> watchCompleted() => _dao.watchOnboardingCompleted();
  Future<bool> isCompleted() => _dao.isOnboardingCompleted();
  Future<void> complete() => _dao.setOnboardingCompleted(completed: true);
}

@riverpod
OnboardingRepository onboardingRepository(Ref ref) =>
    OnboardingRepository(ref.watch(appDatabaseProvider));

/// Reactive onboarding-completed state. Drives the router gate and the startup
/// splash in `StoicApp`.
@riverpod
Stream<bool> onboardingCompleted(Ref ref) =>
    ref.watch(onboardingRepositoryProvider).watchCompleted();
