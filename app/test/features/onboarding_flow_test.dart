import 'package:app/src/core/database/repositories/habit_repository.dart';
import 'package:app/src/core/l10n/app_localizations.dart';
import 'package:app/src/features/habits/habit_form_screen.dart';
import 'package:app/src/features/onboarding/onboarding_screen.dart';
import 'package:app/src/shared/virtue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/no_network_http_overrides.dart';
import '../support/test_app.dart';

void main() {
  final es = lookupAppLocalizations(const Locale('es'));

  testWidgets('a clean install lands on onboarding and cannot reach home',
      (tester) async {
    final db = newTestDatabase();
    addTearDown(db.close);

    await withNoNetwork(() async {
      await tester.pumpWidget(testApp(db));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text(es.onboardingIntroTitle), findsOneWidget);

      await _disposeTree(tester);
    });
  });

  testWidgets('completing onboarding reaches home and does not bounce back',
      (tester) async {
    final db = newTestDatabase();
    addTearDown(db.close);
    // Keep this a pure onboarding test (the guided tour has its own tests).
    await db.appMetaDao.setTutorialCompleted(completed: true);

    await withNoNetwork(() async {
      await tester.pumpWidget(testApp(db));
      await tester.pumpAndSettle();

      // Intro → selection.
      await tester.tap(find.text(es.onboardingIntroStart));
      await tester.pumpAndSettle();

      // Pick one starter habit, then continue. (The editorial type scale can
      // leave the chip unbuilt below the 800×600 test viewport — the selection
      // list is lazy, so scroll until it exists.)
      await tester.scrollUntilVisible(
        find.text(es.suggestionRead),
        120,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text(es.suggestionRead));
      await tester.pumpAndSettle();
      await tester.tap(find.text(es.onboardingContinue));
      await tester.pumpAndSettle();

      // Confirm → start.
      await tester.tap(find.text(es.onboardingStart));
      await tester.pumpAndSettle();

      // Now at home, not redirected back to onboarding.
      expect(find.byType(OnboardingScreen), findsNothing);
      expect(find.text(es.homeTitle), findsOneWidget);

      // The chosen habit was persisted.
      final habits = await db.habitsDao.getAllHabits();
      expect(habits.length, 1);
      expect(habits.single.label, es.suggestionRead);

      await _disposeTree(tester);
    });
  });

  testWidgets('a 4th active habit can be created — there is no cap',
      (tester) async {
    final db = newTestDatabase();
    addTearDown(db.close);
    final repo = HabitRepository(db);
    await repo.createHabit(label: 'Uno', virtue: Virtue.templanza);
    await repo.createHabit(label: 'Dos', virtue: Virtue.coraje);
    await repo.createHabit(label: 'Tres', virtue: Virtue.sabiduria);

    // The form pops on success, so it needs a real router with a page beneath.
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Scaffold()),
        GoRoute(
            path: '/habits/new', builder: (_, _) => const HabitFormScreen()),
      ],
    );
    await tester.pumpWidget(wrapRouter(router, db: db));
    router.push('/habits/new');
    // Let the push transition finish (the form field has no autofocus, so
    // there's no cursor timer yet and settle is safe).
    await tester.pumpAndSettle();

    // A focused TextField runs a periodic cursor timer, so pump explicitly
    // rather than pumpAndSettle (which would wait for that timer forever).
    await tester.enterText(find.byType(TextField), 'Cuatro');
    await tester.pump();
    await tester.tap(find.text(es.habitFormSave));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // The 4th habit saved without any limit message.
    final all = await repo.getAllHabits();
    expect(all.length, 4);
    expect(all.map((h) => h.label), contains('Cuatro'));

    await _disposeTree(tester);
  });
}

/// Unmounts the widget tree and pumps once more so Drift's stream-close timer
/// (scheduled by `StreamQueryStore.markAsClosed` on disposal) and any focused
/// TextField cursor timer fire before the test's pending-timer invariant runs.
Future<void> _disposeTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  // Advance the fake clock so the zero-duration close timer actually fires
  // (a plain pump() elapses no time and leaves it pending).
  await tester.pump(const Duration(milliseconds: 50));
}
