import 'package:app/src/core/database/repositories/onboarding_repository.dart';
import 'package:app/src/core/l10n/app_localizations.dart';
import 'package:app/src/features/habits/habits_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/no_network_http_overrides.dart';
import '../support/test_app.dart';

/// The guided tour: auto-runs once after onboarding, is skippable at every
/// step, crosses tabs itself, and never re-appears once seen.
void main() {
  final es = lookupAppLocalizations(const Locale('es'));

  void useTallScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  /// Pumps enough frames for the overlay's post-frame measuring + animations
  /// (bounded pumps — the overlay animates, so pumpAndSettle would be fragile).
  Future<void> settleTour(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('the tour auto-starts once after onboarding', (tester) async {
    useTallScreen(tester);
    final db = newTestDatabase();
    addTearDown(db.close);
    await OnboardingRepository(db).complete(); // tour flag deliberately unset

    await withNoNetwork(() async {
      await tester.pumpWidget(testApp(db));
      await tester.pumpAndSettle();
      await settleTour(tester);

      expect(find.text(es.tourStepVirtuesTitle), findsOneWidget);

      await _disposeTree(tester);
    });
  });

  testWidgets('skipping ends the tour and persists the seen-flag',
      (tester) async {
    useTallScreen(tester);
    final db = newTestDatabase();
    addTearDown(db.close);
    await OnboardingRepository(db).complete();

    await withNoNetwork(() async {
      await tester.pumpWidget(testApp(db));
      await tester.pumpAndSettle();
      await settleTour(tester);

      await tester.tap(find.text(es.tourSkip));
      await settleTour(tester);

      expect(find.text(es.tourStepVirtuesTitle), findsNothing);
      expect(await db.appMetaDao.isTutorialCompleted(), isTrue);

      await _disposeTree(tester);
    });
  });

  testWidgets('stepping forward crosses to the Hábitos tab', (tester) async {
    useTallScreen(tester);
    final db = newTestDatabase();
    addTearDown(db.close);
    await OnboardingRepository(db).complete();

    await withNoNetwork(() async {
      await tester.pumpWidget(testApp(db));
      await tester.pumpAndSettle();
      await settleTour(tester);

      await tester.tap(find.text(es.tourNext)); // → quote step
      await settleTour(tester);
      await tester.tap(find.text(es.tourNext)); // → habits step (branch 1)
      await settleTour(tester);

      // The tour switched the shell to the Hábitos branch by itself. (The step
      // title matches the screen title, so assert on the unique step body.)
      expect(find.byType(HabitsListScreen), findsOneWidget);
      expect(find.text(es.tourStepHabitsBody), findsOneWidget);

      await _disposeTree(tester);
    });
  });

  testWidgets('a seen tour never re-appears', (tester) async {
    useTallScreen(tester);
    final db = newTestDatabase();
    addTearDown(db.close);
    await completeFirstRun(db);

    await withNoNetwork(() async {
      await tester.pumpWidget(testApp(db));
      await tester.pumpAndSettle();
      await settleTour(tester);

      expect(find.text(es.tourStepVirtuesTitle), findsNothing);
      expect(find.text(es.tourSkip), findsNothing);

      await _disposeTree(tester);
    });
  });
}

Future<void> _disposeTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 50));
}
