import 'package:drift/drift.dart';

/// The local user. Deliberately minimal — **no auth fields** (no email, token,
/// or identity). The MVP works with no account (SPRINT_PLAN invariant #5).
/// Onboarding-completed state is tracked here / in `AppMeta` (Sprint 3), not
/// inferred from habit count.
class UserProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get displayName => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
