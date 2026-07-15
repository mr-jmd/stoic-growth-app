import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../app_database.dart';
import '../daos/user_profile_dao.dart';
import '../database_provider.dart';

part 'user_profile_repository.g.dart';

/// Concrete repository over [UserProfileDao]. The app is single-user on-device
/// with no auth; this just holds an optional display name.
class UserProfileRepository {
  UserProfileRepository(this._db);

  final AppDatabase _db;
  UserProfileDao get _dao => _db.userProfileDao;

  Future<int> createProfile({String? displayName}) => _dao.insertProfile(
        UserProfilesCompanion.insert(displayName: Value(displayName)),
      );

  Future<UserProfile?> getProfile() => _dao.getProfile();

  Future<void> setDisplayName(int id, String? displayName) =>
      _dao.setDisplayName(id, displayName);
}

@riverpod
UserProfileRepository userProfileRepository(Ref ref) =>
    UserProfileRepository(ref.watch(appDatabaseProvider));
