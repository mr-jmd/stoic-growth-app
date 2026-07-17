import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/repositories/journal_repository.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../shared/journal_enums.dart';
import '../../shared/journal_l10n.dart';
import '../../shared/qualitative_level.dart';
import 'mood_energy_picker.dart';
import 'speech/mic_button.dart';

/// Evening reflection (README 10.1): three fixed multi-select chips, optional
/// mood/energy, and a free-text note that stays **collapsed** — the text field
/// is absent from the tree until the user explicitly taps "add a note". The
/// minimal version is always a tap; the long version is an extra the user opts
/// into, never the reverse. Reopening the same day edits (repository upsert).
class EveningScreen extends ConsumerStatefulWidget {
  const EveningScreen({super.key});

  @override
  ConsumerState<EveningScreen> createState() => _EveningScreenState();
}

class _EveningScreenState extends ConsumerState<EveningScreen> {
  final Set<EveningTag> _tags = {};
  final _note = TextEditingController();
  QualitativeLevel? _mood;
  QualitativeLevel? _energy;
  bool _showNote = false;
  bool _usedVoice = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  /// Prefill from today's evening entry, if any. A saved note re-opens expanded;
  /// with no prior note the field stays collapsed (absent from the tree).
  Future<void> _loadExisting() async {
    final repo = ref.read(journalRepositoryProvider);
    final existing = await repo.getEntryForDay(DateTime.now(), JournalType.evening);
    if (existing == null || !mounted) return;
    final tags = await repo.getTags(existing.id);
    if (!mounted) return;
    setState(() {
      _tags
        ..clear()
        ..addAll(tags);
      _mood = QualitativeLevelScore.fromScore(existing.moodScore);
      _energy = QualitativeLevelScore.fromScore(existing.energyScore);
      final note = existing.freeText;
      if (note != null && note.isNotEmpty) {
        _note.text = note;
        _showNote = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final l = AppLocalizations.of(context);

    return AppScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.journalEveningEyebrow, style: tokens.text.eyebrow),
              SizedBox(height: tokens.spacing.sm),
              Text(l.journalEveningTitle, style: tokens.text.displayGreeting),
              SizedBox(height: tokens.spacing.lg),
              Expanded(
                child: ListView(
                  children: [
                    for (final tag in EveningTag.values) ...[
                      SelectableChip(
                        label: tag.label(l),
                        selected: _tags.contains(tag),
                        onSelected: (_) => setState(() {
                          _tags.contains(tag)
                              ? _tags.remove(tag)
                              : _tags.add(tag);
                        }),
                      ),
                      SizedBox(height: tokens.spacing.sm),
                    ],
                    SizedBox(height: tokens.spacing.lg),
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
                    SizedBox(height: tokens.spacing.xxl),
                    // The optional free-text note: collapsed by default. The
                    // field only enters the tree once the user opts in.
                    if (_showNote)
                      _NoteField(
                        controller: _note,
                        onVoiceUsed: () => _usedVoice = true,
                      )
                    else
                      _AddNoteButton(
                        onTap: () => setState(() => _showNote = true),
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
    final note = _showNote ? _note.text.trim() : '';

    await ref.read(journalRepositoryProvider).saveEveningEntry(
          date: DateTime.now(),
          tags: _tags.toList(),
          freeText: note.isEmpty ? null : note,
          moodScore: _mood?.score,
          energyScore: _energy?.score,
          inputMethod:
              _usedVoice ? JournalInputMethod.voice : JournalInputMethod.typed,
        );

    messenger.showSnackBar(SnackBar(content: Text(l.journalSaved)));
    router.pop();
  }
}

/// The collapsed affordance. Warm and quiet — an invitation, not a required
/// field. Tapping it reveals [_NoteField].
class _AddNoteButton extends StatelessWidget {
  const _AddNoteButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final l = AppLocalizations.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(tokens.radii.chip),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.spacing.md),
        child: Row(
          children: [
            Icon(Icons.add, size: 18, color: tokens.colors.faint),
            SizedBox(width: tokens.spacing.sm),
            Text(
              l.eveningAddNote,
              style: tokens.text.chip.copyWith(color: tokens.colors.faint),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteField extends StatelessWidget {
  const _NoteField({required this.controller, this.onVoiceUsed});

  final TextEditingController controller;
  final VoidCallback? onVoiceUsed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final scheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.eveningNoteHint, style: tokens.text.eyebrow),
        SizedBox(height: tokens.spacing.sm),
        TextField(
          controller: controller,
          autofocus: true,
          minLines: 2,
          maxLines: 5,
          style: tokens.text.body,
          decoration: InputDecoration(
            filled: true,
            fillColor: scheme.surfaceContainer,
            suffixIcon:
                MicButton(controller: controller, onVoiceUsed: onVoiceUsed),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(tokens.radii.card),
              borderSide: BorderSide(color: tokens.colors.line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(tokens.radii.card),
              borderSide: BorderSide(color: tokens.colors.line),
            ),
          ),
        ),
      ],
    );
  }
}
