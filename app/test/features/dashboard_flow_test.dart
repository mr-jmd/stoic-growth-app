import 'package:app/src/core/database/repositories/habit_repository.dart';
import 'package:app/src/core/database/repositories/onboarding_repository.dart';
import 'package:app/src/core/design_system/design_system.dart';
import 'package:app/src/core/l10n/app_localizations.dart';
import 'package:app/src/features/habits/habit_detail_screen.dart';
import 'package:app/src/shared/check_in_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/no_network_http_overrides.dart';
import '../support/test_app.dart';

/// The dashboard home is a lazy [ListView], so off-screen widgets aren't built
/// at the default 800×600 test size. Give these tests a tall viewport so the
/// whole home is realised, directly tappable, and stays put across navigation.
void _useTallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200, 3200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  final es = lookupAppLocalizations(const Locale('es'));

  testWidgets(
      'the dashboard shows the four virtues and the daily quote on a fresh install',
      (tester) async {
    _useTallScreen(tester);
    final db = newTestDatabase();
    addTearDown(db.close);
    await OnboardingRepository(db).complete();

    await withNoNetwork(() async {
      await tester.pumpWidget(testApp(db));
      await tester.pumpAndSettle();

      // The four virtues are the primary framing — not a streak count.
      expect(find.byType(VirtueIndicator), findsNWidgets(4));
      // Today's quote + reflection card is present.
      expect(find.text(es.homeQuoteEyebrow), findsOneWidget);

      await _disposeTree(tester);
    });
  });

  testWidgets('the full journey runs offline: onboarding → dashboard → habit '
      'check-in → home', (tester) async {
    _useTallScreen(tester);
    final db = newTestDatabase();
    addTearDown(db.close);

    await withNoNetwork(() async {
      await tester.pumpWidget(testApp(db));
      await tester.pumpAndSettle();

      // Onboarding → home.
      await tester.tap(find.text(es.onboardingIntroStart));
      await tester.pumpAndSettle();
      await tester.tap(find.text(es.suggestionRead));
      await tester.pumpAndSettle();
      await tester.tap(find.text(es.onboardingContinue));
      await tester.pumpAndSettle();
      await tester.tap(find.text(es.onboardingStart));
      await tester.pumpAndSettle();
      expect(find.byType(VirtueIndicator), findsNWidgets(4));

      // Dashboard → habits → detail → register today.
      await tester.tap(find.text(es.homeOpenHabits));
      await tester.pumpAndSettle();
      await tester.tap(find.text(es.suggestionRead));
      await tester.pumpAndSettle();
      expect(find.byType(HabitDetailScreen), findsOneWidget);
      await tester.tap(find.text(es.habitDetailRegisterToday));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final habit = (await HabitRepository(db).getAllHabits()).single;
      expect(habit.currentStreakCount, 1);
      expect((await HabitRepository(db).getCheckIns(habit.id)).single.status,
          CheckInStatus.success);

      // Back to home (arrow back twice: detail → list → home). The dashboard
      // reflects the whole loop, all offline (withNoNetwork would have thrown on
      // any connection attempt). Crisis reachability from home is covered
      // separately in crisis_flow_test.
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text(es.homeTitle), findsOneWidget);
      expect(find.byType(VirtueIndicator), findsNWidgets(4));

      await _disposeTree(tester);
    });
  });
}

Future<void> _disposeTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 50));
}
