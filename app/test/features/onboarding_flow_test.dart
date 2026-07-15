import 'package:app/src/core/database/repositories/habit_repository.dart';
import 'package:app/src/core/l10n/app_localizations.dart';
import 'package:app/src/features/habits/habit_form_screen.dart';
import 'package:app/src/features/onboarding/onboarding_screen.dart';
import 'package:app/src/shared/virtue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

    await withNoNetwork(() async {
      await tester.pumpWidget(testApp(db));
      await tester.pumpAndSettle();

      // Intro → selection.
      await tester.tap(find.text(es.onboardingIntroStart));
      await tester.pumpAndSettle();

      // Pick one starter habit, then continue.
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

  testWidgets('the habit form blocks a 4th active habit with a clear message',
      (tester) async {
    final db = newTestDatabase();
    addTearDown(db.close);
    final repo = HabitRepository(db);
    await repo.createHabit(label: 'Uno', virtue: Virtue.templanza);
    await repo.createHabit(label: 'Dos', virtue: Virtue.coraje);
    await repo.createHabit(label: 'Tres', virtue: Virtue.sabiduria);

    await tester.pumpWidget(wrapScreen(const HabitFormScreen(), db: db));
    await tester.pump();

    // A focused TextField runs a periodic cursor timer, so pump explicitly
    // rather than pumpAndSettle (which would wait for that timer forever).
    await tester.enterText(find.byType(TextField), 'Cuatro');
    await tester.pump();
    await tester.tap(find.text(es.habitFormSave));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(es.habitsLimitReached), findsOneWidget);
    // No 4th habit was created.
    expect((await repo.getAllHabits()).length, 3);

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
