import 'package:app/src/app.dart';
import 'package:app/src/core/database/app_database.dart';
import 'package:app/src/core/database/database_provider.dart';
import 'package:app/src/core/design_system/theme/stoic_theme.dart';
import 'package:app/src/core/l10n/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A fresh in-memory database for a test.
AppDatabase newTestDatabase() => AppDatabase.forTesting(NativeDatabase.memory());

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
