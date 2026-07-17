import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_localizations.dart';
import 'dictation.dart';

/// A warm, inviting mic affordance for a free-text field (README 10.1). Tapping
/// it requests the mic permission and starts dictation via the device's speech
/// recognizer, writing the recognized text into [controller]. If dictation is
/// unavailable (permission denied or no recognizer) the button **silently
/// disappears** and the user keeps typing — voice never blocks completing an
/// entry.
///
/// The active state is a soft earth-tone fill, never a pulsing red "recording"
/// dot (DESIGN_BRIEF: no alarm tone).
class MicButton extends ConsumerStatefulWidget {
  const MicButton({super.key, required this.controller, this.onVoiceUsed});

  final TextEditingController controller;

  /// Called the first time a dictation result lands, so the screen can record
  /// the entry's input method as voice.
  final VoidCallback? onVoiceUsed;

  @override
  ConsumerState<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends ConsumerState<MicButton> {
  // Optimistic: show the mic until a tap proves dictation is unavailable. We
  // never probe (or request permission) on mount — only on an explicit tap.
  bool _available = true;
  bool _listening = false;

  Dictation get _dictation => ref.read(dictationProvider);

  @override
  void dispose() {
    if (_listening) _dictation.stopListening();
    super.dispose();
  }

  Future<void> _onTap() async {
    if (_listening) {
      await _dictation.stopListening();
      if (mounted) setState(() => _listening = false);
      return;
    }
    final ready = await _dictation.prepare();
    if (!mounted) return;
    if (!ready) {
      // Silent fallback: hide the mic, keep chips/typing working.
      setState(() => _available = false);
      return;
    }
    setState(() => _listening = true);
    await _dictation.startListening(
      onResult: (text) {
        widget.onVoiceUsed?.call();
        widget.controller
          ..text = text
          ..selection = TextSelection.collapsed(offset: text.length);
      },
      onDone: () {
        if (mounted) setState(() => _listening = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_available) return const SizedBox.shrink();
    final tokens = context.stoic;
    final c = tokens.colors;

    return IconButton(
      onPressed: _onTap,
      tooltip: AppLocalizations.of(context).journalMicTooltip,
      icon: Icon(_listening ? Icons.mic : Icons.mic_none),
      color: _listening ? c.chipSelectedText : c.labelWarm,
      style: IconButton.styleFrom(
        backgroundColor:
            _listening ? c.chipSelectedFill : Colors.transparent,
      ),
    );
  }
}
