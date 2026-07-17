import 'package:app/src/core/design_system/theme/stoic_theme.dart';
import 'package:app/src/core/l10n/app_localizations.dart';
import 'package:app/src/features/journal/speech/dictation.dart';
import 'package:app/src/features/journal/speech/mic_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const List<LocalizationsDelegate<dynamic>> _delegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// A fake [Dictation] so the mic UI logic is testable without the native
/// speech plugin. Records how often [prepare] runs to prove permission is only
/// requested on tap.
class _FakeDictation implements Dictation {
  _FakeDictation({this.available = true, this.phrase = 'hola mundo'});

  final bool available;
  final String phrase;
  int prepareCalls = 0;
  bool _listening = false;

  @override
  bool get isListening => _listening;

  @override
  Future<bool> prepare() async {
    prepareCalls++;
    return available;
  }

  @override
  Future<void> startListening({
    required ValueChanged<String> onResult,
    required VoidCallback onDone,
  }) async {
    _listening = true;
    onResult(phrase);
    onDone();
    _listening = false;
  }

  @override
  Future<void> stopListening() async => _listening = false;
}

Widget _app(
  Dictation dictation,
  TextEditingController controller, {
  VoidCallback? onVoiceUsed,
}) =>
    ProviderScope(
      overrides: [dictationProvider.overrideWithValue(dictation)],
      child: MaterialApp(
        theme: stoicLightTheme(),
        localizationsDelegates: _delegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: MicButton(controller: controller, onVoiceUsed: onVoiceUsed),
        ),
      ),
    );

void main() {
  testWidgets('permission is not requested until the mic is tapped',
      (tester) async {
    final fake = _FakeDictation();
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(_app(fake, controller));
    await tester.pump();

    // Nothing happened on mount — the mic is shown but prepare() hasn't run.
    expect(fake.prepareCalls, 0);
    expect(find.byIcon(Icons.mic_none), findsOneWidget);
  });

  testWidgets('a recognized phrase is written into the field and flags voice',
      (tester) async {
    final fake = _FakeDictation(phrase: 'mantener la calma');
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    var usedVoice = false;

    await tester.pumpWidget(
      _app(fake, controller, onVoiceUsed: () => usedVoice = true),
    );

    await tester.tap(find.byIcon(Icons.mic_none));
    await tester.pump();
    await tester.pump();

    expect(fake.prepareCalls, 1);
    expect(controller.text, 'mantener la calma');
    expect(usedVoice, isTrue);
  });

  testWidgets('when dictation is unavailable the mic silently disappears',
      (tester) async {
    final fake = _FakeDictation(available: false);
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    var usedVoice = false;

    await tester.pumpWidget(
      _app(fake, controller, onVoiceUsed: () => usedVoice = true),
    );

    await tester.tap(find.byIcon(Icons.mic_none));
    await tester.pump();
    await tester.pump();

    // Silent fallback: the mic is gone, the field is untouched, voice not flagged.
    expect(find.byIcon(Icons.mic_none), findsNothing);
    expect(find.byIcon(Icons.mic), findsNothing);
    expect(controller.text, isEmpty);
    expect(usedVoice, isFalse);
  });
}
