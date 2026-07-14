import 'package:drift/drift.dart';

// Single-row table tracking app-level setup state. Populated properly in
// Sprint 3 (onboarding gate); exists here only to prove the Drift + codegen
// toolchain works end-to-end on this SDK before Sprint 2 builds the full
// schema on top of it.
class AppMeta extends Table {
  IntColumn get id => integer().autoIncrement()();
  BoolColumn get onboardingCompleted =>
      boolean().withDefault(const Constant(false))();
  IntColumn get schemaVersion => integer().withDefault(const Constant(1))();
}
