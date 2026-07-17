import 'package:app/src/core/database/app_database.dart';
import 'package:app/src/core/database/database_provider.dart';
import 'package:app/src/core/database/repositories/habit_repository.dart';
import 'package:app/src/core/design_system/theme/stoic_theme.dart';
import 'package:app/src/core/l10n/app_localizations.dart';
import 'package:app/src/features/habits/habit_detail_screen.dart';
import 'package:app/src/features/habits/relapse_form_screen.dart';
import 'package:app/src/shared/check_in_status.dart';
import 'package:app/src/shared/virtue.dart';
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

/// A minimal router carrying just the two Sprint 4 habit routes, so the detail
/// → relapse navigation is exercised through real GoRouter, not a stub.
Widget _detailApp(AppDatabase db, int habitId) {
  final router = GoRouter(
    initialLocation: '/habits/$habitId',
    routes: [
      GoRoute(
        path: '/habits/:id',
        builder: (context, state) =>
            HabitDetailScreen(habitId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/habits/:id/relapse',
        builder: (context, state) =>
            RelapseFormScreen(habitId: int.parse(state.pathParameters['id']!)),
      ),
    ],
  );
  return ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
    child: MaterialApp.router(
      routerConfig: router,
      theme: stoicLightTheme(),
      darkTheme: stoicDarkTheme(),
      localizationsDelegates: _delegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

void main() {
  final es = lookupAppLocalizations(const Locale('es'));

  testWidgets('the relapse form is reachable in one tap from the habit detail',
      (tester) async {
    final db = newTestDatabase();
    addTearDown(db.close);
    final id = await HabitRepository(db)
        .addHabit(label: 'Redes', virtue: Virtue.templanza);

    await withNoNetwork(() async {
      await tester.pumpWidget(_detailApp(db, id));
      await tester.pumpAndSettle();

      // One tap on a first-class action (not buried in a menu) opens the form.
      expect(find.text(es.habitDetailRegisterRelapse), findsOneWidget);
      await tester.tap(find.text(es.habitDetailRegisterRelapse));
      await tester.pumpAndSettle();

      expect(find.byType(RelapseFormScreen), findsOneWidget);
      expect(find.text(es.relapseFormTitle), findsOneWidget);

      await _disposeTree(tester);
    });
  });

  testWidgets('the stepper edits consistency and it persists to the database',
      (tester) async {
    final db = newTestDatabase();
    addTearDown(db.close);
    final repo = HabitRepository(db);
    final id = await repo.addHabit(label: 'Leer', virtue: Virtue.sabiduria);

    await tester.pumpWidget(_detailApp(db, id));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip(es.habitDetailIncrement));
    await tester.pumpAndSettle();

    // The UI reflects it and the change is durable in the DB.
    expect(find.text('1'), findsOneWidget);
    expect((await repo.getHabit(id))!.currentStreakCount, 1);

    await _disposeTree(tester);
  });

  testWidgets('registering today appends a success check-in', (tester) async {
    final db = newTestDatabase();
    addTearDown(db.close);
    final repo = HabitRepository(db);
    final id = await repo.addHabit(label: 'Caminar', virtue: Virtue.coraje);

    await tester.pumpWidget(_detailApp(db, id));
    await tester.pumpAndSettle();

    await tester.tap(find.text(es.habitDetailRegisterToday));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final checkIns = await repo.getCheckIns(id);
    expect(checkIns.length, 1);
    expect(checkIns.single.status, CheckInStatus.success);
    expect((await repo.getHabit(id))!.currentStreakCount, 1);

    await _disposeTree(tester);
  });
}

/// Unmounts the tree and pumps once more so Drift's stream-close timer and the
/// SnackBar auto-dismiss timer fire before the pending-timer invariant runs.
Future<void> _disposeTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 50));
}
