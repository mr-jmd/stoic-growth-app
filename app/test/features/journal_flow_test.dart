import 'package:app/src/core/database/repositories/journal_repository.dart';
import 'package:app/src/core/database/repositories/onboarding_repository.dart';
import 'package:app/src/core/l10n/app_localizations.dart';
import 'package:app/src/features/journal/evening_screen.dart';
import 'package:app/src/features/journal/morning_screen.dart';
import 'package:app/src/shared/journal_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/no_network_http_overrides.dart';
import '../support/test_app.dart';

void main() {
  final es = lookupAppLocalizations(const Locale('es'));

  testWidgets(
      'the evening free-text field is absent from the tree until "add a note"',
      (tester) async {
    final db = newTestDatabase();
    addTearDown(db.close);
    // Skip onboarding so the app lands on home, then navigate to the evening
    // screen through the real router.
    await OnboardingRepository(db).complete();

    await withNoNetwork(() async {
      await tester.pumpWidget(testApp(db));
      await tester.pumpAndSettle();

      await tester.tap(find.text(es.homeOpenEvening));
      await tester.pumpAndSettle();
      expect(find.byType(EveningScreen), findsOneWidget);

      // The free-text field is genuinely not in the tree yet.
      expect(find.byType(TextField), findsNothing);
      expect(find.text(es.eveningAddNote), findsOneWidget);

      // Opt in — now the field appears. (It autofocuses, so pump, not settle.)
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
    await OnboardingRepository(db).complete();

    await withNoNetwork(() async {
      await tester.pumpWidget(testApp(db));
      await tester.pumpAndSettle();

      await tester.tap(find.text(es.homeOpenMorning));
      await tester.pumpAndSettle();
      expect(find.byType(MorningScreen), findsOneWidget);

      // One tap on a preset completes the phrase; then save.
      await tester.tap(find.text(es.morningPresetFocus));
      await tester.pump();
      await tester.tap(find.text(es.journalSave));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Back on home, and the entry is persisted for today.
      final entry = await JournalRepository(db)
          .getEntryForDay(DateTime.now(), JournalType.morning);
      expect(entry, isNotNull);
      expect(entry!.freeText, es.morningPresetFocus);

      await _disposeTree(tester);
    });
  });
}

/// Unmounts the tree and pumps once more so Drift's stream-close timer, the
/// SnackBar auto-dismiss timer, and any focused-field cursor timer fire before
/// the pending-timer invariant runs.
Future<void> _disposeTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 50));
}
