import 'package:app/src/core/database/app_database.dart';
import 'package:app/src/core/database/database_provider.dart';
import 'package:app/src/core/database/repositories/journal_repository.dart';
import 'package:app/src/core/design_system/theme/stoic_theme.dart';
import 'package:app/src/core/l10n/app_localizations.dart';
import 'package:app/src/features/journal/evening_screen.dart';
import 'package:app/src/features/journal/morning_screen.dart';
import 'package:app/src/shared/journal_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/no_network_http_overrides.dart';
import '../support/test_app.dart';

const List<LocalizationsDelegate<dynamic>> _delegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// A minimal router with a stub home + the two journal routes, so a screen's
/// `context.pop()` on save has somewhere to return to. Driven directly through
/// GoRouter (not by tapping through the real dashboard), which keeps these tests
/// focused on the journal screens themselves.
GoRouter _journalRouter() => GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Scaffold()),
        GoRoute(
          path: '/journal/morning',
          builder: (_, _) => const MorningScreen(),
        ),
        GoRoute(
          path: '/journal/evening',
          builder: (_, _) => const EveningScreen(),
        ),
      ],
    );

Widget _journalApp(AppDatabase db, GoRouter router) => ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp.router(
        routerConfig: router,
        theme: stoicLightTheme(),
        darkTheme: stoicDarkTheme(),
        localizationsDelegates: _delegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );

void main() {
  final es = lookupAppLocalizations(const Locale('es'));

  testWidgets(
      'the evening free-text field is absent from the tree until "add a note"',
      (tester) async {
    final db = newTestDatabase();
    addTearDown(db.close);
    final router = _journalRouter();

    await withNoNetwork(() async {
      await tester.pumpWidget(_journalApp(db, router));
      router.push('/journal/evening');
      await tester.pumpAndSettle();
      expect(find.byType(EveningScreen), findsOneWidget);

      // The free-text field is genuinely not in the tree yet.
      expect(find.byType(TextField), findsNothing);
      expect(find.text(es.eveningAddNote), findsOneWidget);

      // Opt in — now the field appears. (It autofocuses, so pump, not settle.)
      // The editorial type scale can push the row below the 800×600 test
      // viewport — scroll it into view first.
      await tester.ensureVisible(find.text(es.eveningAddNote));
      await tester.pump();
      await tester.tap(find.text(es.eveningAddNote));
      await tester.pump();
      expect(find.byType(TextField), findsOneWidget);

      await _disposeTree(tester);
    });
  });

  testWidgets('a morning entry is completable in a tap and persists',
      (tester) async {
    final db = newTestDatabase();
    addTearDown(db.close);
    final router = _journalRouter();

    await withNoNetwork(() async {
      await tester.pumpWidget(_journalApp(db, router));
      router.push('/journal/morning');
      await tester.pumpAndSettle();
      expect(find.byType(MorningScreen), findsOneWidget);

      // One tap on a preset completes the phrase; then save.
      await tester.tap(find.text(es.morningPresetFocus));
      await tester.pump();
      await tester.tap(find.text(es.journalSave));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final entry = await JournalRepository(db)
          .getEntryForDay(DateTime.now(), JournalType.morning);
      expect(entry, isNotNull);
      expect(entry!.freeText, es.morningPresetFocus);

      await _disposeTree(tester);
    });
  });
}

Future<void> _disposeTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 50));
}
