import 'dart:convert';
import 'dart:io';

import 'package:app/src/core/database/repositories/onboarding_repository.dart';
import 'package:app/src/core/design_system/theme/stoic_theme.dart';
import 'package:app/src/core/l10n/app_localizations.dart';
import 'package:app/src/features/crisis/crisis_content.dart';
import 'package:app/src/features/crisis/crisis_flow.dart';
import 'package:app/src/features/crisis/crisis_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/no_network_http_overrides.dart';
import '../support/test_app.dart';

const List<LocalizationsDelegate<dynamic>> _delegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

const _testContent = CrisisContent(
  affirmation: 'Esto va a pasar.',
  breathing: BreathingScript(
    cycles: 1,
    phases: [BreathingPhase(label: 'Inhala', seconds: 1, scale: 1.0)],
  ),
  socraticPrompts: ['PREGUNTA_UNO', 'PREGUNTA_DOS'],
);

Widget _crisisApp(ProviderContainer container) => UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: stoicLightTheme(),
        darkTheme: stoicDarkTheme(),
        localizationsDelegates: _delegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const CrisisScreen(),
      ),
    );

void main() {
  final es = lookupAppLocalizations(const Locale('es'));

  test('CrisisContent parses from JSON, including the breathing phases', () {
    final json = {
      'affirmation': 'Va a pasar.',
      'breathing': {
        'cycles': 2,
        'phases': [
          {'label': 'Inhala', 'seconds': 4, 'scale': 1.0},
          {'label': 'Suelta', 'seconds': 4, 'scale': 0.4},
        ],
      },
      'socraticPrompts': ['A', 'B'],
    };
    final content = CrisisContent.fromJson(json);

    expect(content.affirmation, 'Va a pasar.');
    expect(content.breathing.cycles, 2);
    expect(content.breathing.phases.length, 2);
    expect(content.breathing.phases.first.label, 'Inhala');
    expect(content.breathing.phases.last.scale, 0.4);
    expect(content.socraticPrompts, ['A', 'B']);
  });

  test('the shipped crisis_content.json is valid and parses', () {
    // The actual bundled asset must always parse — safety-critical content.
    final raw = File('assets/content/crisis_content.json').readAsStringSync();
    final content =
        CrisisContent.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    expect(content.affirmation, isNotEmpty);
    expect(content.breathing.phases, isNotEmpty);
    expect(content.socraticPrompts, isNotEmpty);
  });

  testWidgets(
      'the socratic prompt is absent until relief completes; exit is always shown',
      (tester) async {
    final container = ProviderContainer(
      overrides: [crisisContentProvider.overrideWith((ref) => _testContent)],
    );
    addTearDown(container.dispose);

    await withNoNetwork(() async {
      await tester.pumpWidget(_crisisApp(container));
      await tester.pump(); // resolve the content future

      // During relief: no question in the tree, but the exit is present.
      expect(find.text('PREGUNTA_UNO'), findsNothing);
      expect(find.text(es.crisisExit), findsOneWidget);

      // Force the timer-complete state through the flow controller.
      container.read(crisisFlowProvider.notifier).completeRelief();
      await tester.pump();

      // Now the socratic prompt exists — and the exit is still there.
      expect(find.text('PREGUNTA_UNO'), findsOneWidget);
      expect(find.text(es.crisisExit), findsOneWidget);

      await _disposeTree(tester);
    });
  });

  testWidgets('crisis mode is reachable in one tap from home', (tester) async {
    final db = newTestDatabase();
    addTearDown(db.close);
    await OnboardingRepository(db).complete();

    await withNoNetwork(() async {
      await tester.pumpWidget(testApp(db));
      await tester.pumpAndSettle();

      // The persistent crisis affordance is on the home shell.
      await tester.tap(find.text(es.crisisAccessLabel));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byType(CrisisScreen), findsOneWidget);

      await _disposeTree(tester);
    });
  });
}

/// Unmounts the tree and pumps once more so the breathing timer's ticker and
/// Drift's stream-close timer are cancelled before the pending-timer check.
Future<void> _disposeTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 50));
}
