import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/repositories/journal_repository.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../shared/journal_enums.dart';
import '../../shared/qualitative_level.dart';
import 'mood_energy_picker.dart';
import 'speech/mic_button.dart';

/// Morning reflection (README 10.1): the "Hoy depende de mí: ___" prompt,
/// completable in a single tap via a pre-written short phrase (or typed in the
/// user's own words), plus optional mood/energy. Reopening the same day edits
/// the existing entry (repository upsert), never duplicates.
class MorningScreen extends ConsumerStatefulWidget {
  const MorningScreen({super.key});

  @override
  ConsumerState<MorningScreen> createState() => _MorningScreenState();
}

class _MorningScreenState extends ConsumerState<MorningScreen> {
  final _phrase = TextEditingController();
  QualitativeLevel? _mood;
  QualitativeLevel? _energy;
  bool _usedVoice = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _phrase.addListener(_onPhraseChanged);
    _loadExisting();
  }

  @override
  void dispose() {
    _phrase.removeListener(_onPhraseChanged);
    _phrase.dispose();
    super.dispose();
  }

  void _onPhraseChanged() => setState(() {});

  /// Prefill from today's morning entry, if any, so reopening edits in place.
  Future<void> _loadExisting() async {
    final existing = await ref
        .read(journalRepositoryProvider)
        .getEntryForDay(DateTime.now(), JournalType.morning);
    if (existing == null || !mounted) return;
    setState(() {
      _phrase.text = existing.freeText ?? '';
      _mood = QualitativeLevelScore.fromScore(existing.moodScore);
      _energy = QualitativeLevelScore.fromScore(existing.energyScore);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final l = AppLocalizations.of(context);
    final presets = [
      l.morningPresetAttitude,
      l.morningPresetEffort,
      l.morningPresetResponse,
      l.morningPresetFocus,
    ];

    return AppScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.journalMorningEyebrow, style: tokens.text.eyebrow),
              SizedBox(height: tokens.spacing.sm),
              Text(l.journalMorningPrompt, style: tokens.text.promptDisplay),
              SizedBox(height: tokens.spacing.lg),
              Expanded(
                child: ListView(
                  children: [
                    // One tap on a preset completes the phrase (README's
                    // "selección corta"); the field stays the single source.
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final preset in presets)
                          SelectableChip(
                            label: preset,
                            selected: _phrase.text.trim() == preset,
                            onSelected: (_) => _phrase.text = preset,
                          ),
                      ],
                    ),
                    SizedBox(height: tokens.spacing.lg),
                    Text(l.morningCustomHint, style: tokens.text.eyebrow),
                    SizedBox(height: tokens.spacing.sm),
                    _PhraseField(
                      controller: _phrase,
                      onVoiceUsed: () => _usedVoice = true,
                    ),
                    SizedBox(height: tokens.spacing.xxl),
                    MoodEnergyPicker(
                      question: l.journalMoodQuestion,
                      selected: _mood,
                      onChanged: (v) => setState(() => _mood = v),
                    ),
                    SizedBox(height: tokens.spacing.lg),
                    MoodEnergyPicker(
                      question: l.journalEnergyQuestion,
                      selected: _energy,
                      onChanged: (v) => setState(() => _energy = v),
                    ),
                  ],
                ),
              ),
              SizedBox(height: tokens.spacing.md),
              Row(
                children: [
                  AppButton(
                    label: l.onboardingBack,
                    variant: AppButtonVariant.secondary,
                    onPressed: _saving ? null : () => context.pop(),
                  ),
                  const Spacer(),
                  AppButton(
                    label: l.journalSave,
                    onPressed: _saving ? null : _save,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final phrase = _phrase.text.trim();

    await ref.read(journalRepositoryProvider).saveMorningEntry(
          date: DateTime.now(),
          phrase: phrase.isEmpty ? null : phrase,
          moodScore: _mood?.score,
          energyScore: _energy?.score,
          inputMethod:
              _usedVoice ? JournalInputMethod.voice : JournalInputMethod.typed,
        );

    messenger.showSnackBar(SnackBar(content: Text(l.journalSaved)));
    router.pop();
  }
}

class _PhraseField extends StatelessWidget {
  const _PhraseField({required this.controller, this.onVoiceUsed});

  final TextEditingController controller;
  final VoidCallback? onVoiceUsed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      // Short by design — a phrase, never a paragraph (README 10.1).
      maxLength: 60,
      style: tokens.text.body,
      decoration: InputDecoration(
        filled: true,
        fillColor: scheme.surfaceContainer,
        suffixIcon: MicButton(controller: controller, onVoiceUsed: onVoiceUsed),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radii.card),
          borderSide: BorderSide(color: tokens.colors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radii.card),
          borderSide: BorderSide(color: tokens.colors.line),
        ),
      ),
    );
  }
}
