import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/repositories/habit_repository.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../shared/virtue.dart';
import '../../shared/virtue_l10n.dart';
import 'onboarding_controller.dart';
import 'onboarding_suggestions.dart';

enum _Step { intro, select, confirm }

/// First-run flow (no login): a brief framing, a 1–3 selection of starter
/// habits, and a confirmation. The router blocks every other route behind this
/// until it completes (gate keyed on the persisted onboarding flag, not habit
/// count).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  _Step _step = _Step.intro;
  final Set<HabitSuggestionKey> _selected = {};

  static const int _max = HabitRepository.maxActiveHabits;

  List<HabitSuggestion> get _selectedSuggestions =>
      kHabitSuggestions.where((s) => _selected.contains(s.key)).toList();

  @override
  Widget build(BuildContext context) {
    final controllerState = ref.watch(onboardingControllerProvider);
    return AppScaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: switch (_step) {
          _Step.intro => _IntroStep(onStart: () => setState(() => _step = _Step.select)),
          _Step.select => _SelectStep(
              selected: _selected,
              onToggle: _toggle,
              onBack: () => setState(() => _step = _Step.intro),
              onContinue: () => setState(() => _step = _Step.confirm),
            ),
          _Step.confirm => _ConfirmStep(
              suggestions: _selectedSuggestions,
              isSaving: controllerState.isLoading,
              onBack: () => setState(() => _step = _Step.select),
              onStart: _finish,
            ),
        },
      ),
    );
  }

  void _toggle(HabitSuggestionKey key, bool selected) {
    setState(() {
      if (selected) {
        if (_selected.length < _max) _selected.add(key);
      } else {
        _selected.remove(key);
      }
    });
  }

  Future<void> _finish() async {
    final l = AppLocalizations.of(context);
    await ref
        .read(onboardingControllerProvider.notifier)
        .finish(_selectedSuggestions, (s) => s.label(l));
    // On success the onboarding flag flips and the router moves us home; no
    // manual navigation needed here.
  }
}

class _IntroStep extends StatelessWidget {
  const _IntroStep({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Text(l.onboardingIntroTitle, style: tokens.text.displayGreeting),
        SizedBox(height: tokens.spacing.lg),
        Text(l.onboardingIntroBody, style: tokens.text.body),
        const Spacer(),
        Align(
          alignment: Alignment.centerLeft,
          child: AppButton(label: l.onboardingIntroStart, onPressed: onStart),
        ),
      ],
    );
  }
}

class _SelectStep extends StatelessWidget {
  const _SelectStep({
    required this.selected,
    required this.onToggle,
    required this.onBack,
    required this.onContinue,
  });

  final Set<HabitSuggestionKey> selected;
  final void Function(HabitSuggestionKey, bool) onToggle;
  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final l = AppLocalizations.of(context);
    final atCap = selected.length >= _OnboardingScreenState._max;
    final canContinue = selected.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.onboardingSelectTitle, style: tokens.text.displayGreeting),
        SizedBox(height: tokens.spacing.sm),
        Text(l.onboardingSelectSubtitle, style: tokens.text.body),
        SizedBox(height: tokens.spacing.md),
        Text(
          l.onboardingSelectionCounter(selected.length, _OnboardingScreenState._max),
          style: tokens.text.eyebrow,
        ),
        SizedBox(height: tokens.spacing.md),
        Expanded(
          child: ListView(
            children: [
              for (final virtue in Virtue.values)
                _VirtueGroup(
                  virtue: virtue,
                  selected: selected,
                  atCap: atCap,
                  onToggle: onToggle,
                ),
            ],
          ),
        ),
        Row(
          children: [
            AppButton(
              label: l.onboardingBack,
              variant: AppButtonVariant.secondary,
              onPressed: onBack,
            ),
            const Spacer(),
            AppButton(
              label: l.onboardingContinue,
              onPressed: canContinue ? onContinue : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _VirtueGroup extends StatelessWidget {
  const _VirtueGroup({
    required this.virtue,
    required this.selected,
    required this.atCap,
    required this.onToggle,
  });

  final Virtue virtue;
  final Set<HabitSuggestionKey> selected;
  final bool atCap;
  final void Function(HabitSuggestionKey, bool) onToggle;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final l = AppLocalizations.of(context);
    final suggestions =
        kHabitSuggestions.where((s) => s.virtue == virtue).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(virtue.label(l), style: tokens.text.virtueName),
          SizedBox(height: tokens.spacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in suggestions)
                SelectableChip(
                  label: s.label(l),
                  selected: selected.contains(s.key),
                  // Disable unselected chips once the cap is reached.
                  onSelected: (!selected.contains(s.key) && atCap)
                      ? null
                      : (v) => onToggle(s.key, v),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConfirmStep extends StatelessWidget {
  const _ConfirmStep({
    required this.suggestions,
    required this.isSaving,
    required this.onBack,
    required this.onStart,
  });

  final List<HabitSuggestion> suggestions;
  final bool isSaving;
  final VoidCallback onBack;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final l = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.onboardingConfirmTitle, style: tokens.text.displayGreeting),
        SizedBox(height: tokens.spacing.sm),
        Text(l.onboardingConfirmSubtitle, style: tokens.text.body),
        SizedBox(height: tokens.spacing.lg),
        Expanded(
          child: ListView(
            children: [
              for (final s in suggestions)
                AppCard(
                  padding: EdgeInsets.all(tokens.spacing.lg),
                  child: Row(
                    children: [
                      Expanded(child: Text(s.label(l), style: tokens.text.body)),
                      Text(s.virtue.label(l), style: tokens.text.eyebrow),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Row(
          children: [
            AppButton(
              label: l.onboardingBack,
              variant: AppButtonVariant.secondary,
              onPressed: isSaving ? null : onBack,
            ),
            const Spacer(),
            AppButton(
              label: l.onboardingStart,
              onPressed: isSaving ? null : onStart,
            ),
          ],
        ),
      ],
    );
  }
}
