import 'package:app/src/app.dart';
import 'package:app/src/core/database/app_database.dart';
import 'package:app/src/core/database/database_provider.dart';
import 'package:app/src/core/database/repositories/onboarding_repository.dart';
import 'package:app/src/core/design_system/theme/stoic_theme.dart';
import 'package:app/src/core/l10n/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// A fresh in-memory database for a test.
AppDatabase newTestDatabase() => AppDatabase.forTesting(NativeDatabase.memory());

/// Marks both first-run flows done (onboarding + guided tour) so tests that
/// land on the shell get a quiet home — otherwise the auto-started tour
/// overlay would absorb their taps.
Future<void> completeFirstRun(AppDatabase db) async {
  await OnboardingRepository(db).complete();
  await db.appMetaDao.setTutorialCompleted(completed: true);
}

const List<LocalizationsDelegate<dynamic>> _delegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// The full app wired to an in-memory [db] instead of the on-device file DB.
Widget testApp(AppDatabase db) {
  return ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
    child: const StoicApp(),
  );
}

/// Wraps a single screen in a themed, localized [MaterialApp] for widget tests
/// that don't need routing. Optionally points at an in-memory [db].
Widget wrapScreen(Widget child, {AppDatabase? db}) {
  return ProviderScope(
    overrides: [
      if (db != null) appDatabaseProvider.overrideWithValue(db),
    ],
    child: MaterialApp(
      theme: stoicLightTheme(),
      darkTheme: stoicDarkTheme(),
      localizationsDelegates: _delegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

/// Like [wrapScreen] but drives a minimal local [GoRouter] — for screens whose
/// flows call `context.pop()`/`push` (the journal_flow_test pattern).
Widget wrapRouter(GoRouter router, {AppDatabase? db}) {
  return ProviderScope(
    overrides: [
      if (db != null) appDatabaseProvider.overrideWithValue(db),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      theme: stoicLightTheme(),
      darkTheme: stoicDarkTheme(),
      localizationsDelegates: _delegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}
