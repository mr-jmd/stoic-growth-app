import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/user_profiles.dart';

part 'user_profile_dao.g.dart';

/// DAO for the single local user profile. No auth — just an optional display
/// name and creation time.
@DriftAccessor(tables: [UserProfiles])
class UserProfileDao extends DatabaseAccessor<AppDatabase>
    with _$UserProfileDaoMixin {
  UserProfileDao(super.db);

  Future<int> insertProfile(UserProfilesCompanion profile) =>
      into(userProfiles).insert(profile);

  /// The local profile, if one exists (the app is single-user on-device).
  Future<UserProfile?> getProfile() =>
      (select(userProfiles)..limit(1)).getSingleOrNull();

  Future<void> setDisplayName(int id, String? displayName) {
    return (update(userProfiles)..where((u) => u.id.equals(id)))
        .write(UserProfilesCompanion(displayName: Value(displayName)));
  }
}
