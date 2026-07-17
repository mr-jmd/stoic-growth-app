import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Voice dictation seam for the journal free-text fields (README 10.1).
///
/// This is one of the few places the "no interfaces" convention is set aside on
/// purpose: dictation is a native platform plugin that can't run in a headless
/// test, so an abstract [Dictation] lets the UI logic (permission-denied →
/// silent fallback, result → field) be tested with a fake, while the real
/// [SpeechDictation] wraps `speech_to_text` + `permission_handler`.
abstract class Dictation {
  /// Best-effort readiness. Requests the mic permission (only when called, i.e.
  /// on tapping the mic — never at app open) and initializes the engine.
  /// Returns false **silently** (never throws) when unavailable, so the UI can
  /// just hide the mic and the user keeps chips/typing — the always-offline path
  /// is never blocked by voice.
  Future<bool> prepare();

  /// Streams recognized text to [onResult] and calls [onDone] when the session
  /// ends (final result, timeout, or error).
  Future<void> startListening({
    required ValueChanged<String> onResult,
    required VoidCallback onDone,
  });

  Future<void> stopListening();

  bool get isListening;
}

/// Real implementation over `speech_to_text`. Uses the **device's system speech
/// recognizer** (`onDevice: false`), which recognizes on-device where the OS
/// can and falls back to the OS's cloud recognizer otherwise — so dictation
/// works on virtually any device. Only the audio of this **optional** voice
/// feature may leave the phone; the rest of the app remains 100% offline (no
/// account, local-first data). If the recognizer is unavailable the mic hides
/// and the user keeps typing — voice never blocks completing an entry.
class SpeechDictation implements Dictation {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _ready = false;
  ValueChanged<String>? _onResult;
  VoidCallback? _onDone;

  @override
  bool get isListening => _speech.isListening;

  @override
  Future<bool> prepare() async {
    if (_ready) return true;
    final status = await Permission.microphone.request();
    if (!status.isGranted) return false;
    _ready = await _speech.initialize(
      onError: (_) => _finish(),
      onStatus: (s) {
        if (s == 'done' || s == 'notListening') _finish();
      },
    );
    return _ready;
  }

  @override
  Future<void> startListening({
    required ValueChanged<String> onResult,
    required VoidCallback onDone,
  }) async {
    if (!_ready) return;
    _onResult = onResult;
    _onDone = onDone;
    await _speech.listen(
      onResult: (r) => _onResult?.call(r.recognizedWords),
      listenOptions: stt.SpeechListenOptions(
        onDevice: false,
        partialResults: true,
        cancelOnError: true,
        localeId: 'es_ES',
        // Keep the session open a while, ending after a short pause in speech.
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Future<void> stopListening() => _speech.stop();

  void _finish() {
    final done = _onDone;
    _onDone = null;
    _onResult = null;
    done?.call();
  }
}

/// The dictation implementation. Overridden with a fake in tests.
final dictationProvider = Provider<Dictation>((ref) => SpeechDictation());
