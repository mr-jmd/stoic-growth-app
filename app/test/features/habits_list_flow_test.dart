import 'package:app/src/core/database/app_database.dart';
import 'package:app/src/core/database/repositories/habit_repository.dart';
import 'package:app/src/core/l10n/app_localizations.dart';
import 'package:app/src/features/habits/habits_list_screen.dart';
import 'package:app/src/shared/virtue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/no_network_http_overrides.dart';
import '../support/test_app.dart';

/// Archiving must be two deliberate steps away (⋯ menu → confirm dialog) so a
/// stray tap can never archive a habit.
void main() {
  final es = lookupAppLocalizations(const Locale('es'));

  GoRouter listRouter() => GoRouter(
        initialLocation: '/habits',
        routes: [
          GoRoute(
              path: '/habits', builder: (_, _) => const HabitsListScreen()),
          GoRoute(path: '/habits/new', builder: (_, _) => const Scaffold()),
          GoRoute(path: '/habits/:id', builder: (_, _) => const Scaffold()),
        ],
      );

  Future<AppDatabase> seededDb() async {
    final db = newTestDatabase();
    await HabitRepository(db).createHabit(
      label: 'Leer', virtue: Virtue.sabiduria);
    return db;
  }

  testWidgets('tapping the habit card navigates and never archives',
      (tester) async {
    final db = await seededDb();
    addTearDown(db.close);
    final repo = HabitRepository(db);

    await withNoNetwork(() async {
      await tester.pumpWidget(wrapRouter(listRouter(), db: db));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Leer'));
      await tester.pumpAndSettle();

      // Navigated away; the habit is still active.
      expect(find.text('Leer'), findsNothing);
      expect(await repo.countActiveHabits(), 1);

      await _disposeTree(tester);
    });
  });

  testWidgets('the menu opens the confirm dialog and cancel does nothing',
      (tester) async {
    final db = await seededDb();
    addTearDown(db.close);
    final repo = HabitRepository(db);

    await withNoNetwork(() async {
      await tester.pumpWidget(wrapRouter(listRouter(), db: db));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip(es.habitsMenuTooltip));
      await tester.pumpAndSettle();
      expect(find.text(es.habitsMenuArchive), findsOneWidget);

      await tester.tap(find.text(es.habitsMenuArchive));
      await tester.pumpAndSettle();
      expect(find.text(es.habitsArchiveConfirmBody), findsOneWidget);

      await tester.tap(find.text(es.dialogCancel));
      await tester.pumpAndSettle();

      // Nothing archived, no snackbar.
      expect(await repo.countActiveHabits(), 1);
      expect(find.text(es.habitsArchived), findsNothing);

      await _disposeTree(tester);
    });
  });

  testWidgets('confirming the dialog archives the habit', (tester) async {
    final db = await seededDb();
    addTearDown(db.close);
    final repo = HabitRepository(db);

    await withNoNetwork(() async {
      await tester.pumpWidget(wrapRouter(listRouter(), db: db));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip(es.habitsMenuTooltip));
      await tester.pumpAndSettle();
      await tester.tap(find.text(es.habitsMenuArchive));
      await tester.pumpAndSettle();
      await tester.tap(find.text(es.habitsArchiveConfirmAction));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(await repo.countActiveHabits(), 0);
      expect(find.text(es.habitsArchived), findsOneWidget);

      await _disposeTree(tester);
    });
  });
}

Future<void> _disposeTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 50));
}
