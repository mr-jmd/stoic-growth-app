import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../shared/virtue.dart';
import '../../shared/virtue_l10n.dart';
import '../../shared/virtue_progress_state.dart';
import 'onboarding_controller.dart';
import 'onboarding_suggestions.dart';

enum _Step { intro, select, confirm }

/// First-run flow (no login): a brief framing, a free selection of starter
/// habits (at least one — the "start small" advice is copy, never a block),
/// and a confirmation. The router blocks every other route behind this until
/// it completes (gate keyed on the persisted onboarding flag, not habit count).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  _Step _step = _Step.intro;
  final Set<HabitSuggestionKey> _selected = {};

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
      selected ? _selected.add(key) : _selected.remove(key);
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

    // A quiet editorial entrance: the manifesto fades up once, slowly.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: tokens.motion.slow,
      curve: tokens.motion.standard,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 16),
          child: child,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: tokens.spacing.hero),
          Text('ANDAMIO', style: tokens.text.eyebrow),
          const Spacer(),
          Text(l.onboardingIntroTitle, style: tokens.text.displayHero),
          SizedBox(height: tokens.spacing.xl),
          Container(
            width: 36,
            height: 2,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.75),
          ),
          SizedBox(height: tokens.spacing.xl),
          Text(
            l.onboardingIntroBody,
            style: tokens.text.body.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          const Spacer(flex: 2),
          AppButton(
            label: l.onboardingIntroStart,
            onPressed: onStart,
            expanded: true,
          ),
          SizedBox(height: tokens.spacing.lg),
        ],
      ),
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
    final canContinue = selected.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.onboardingSelectTitle, style: tokens.text.displayGreeting),
        SizedBox(height: tokens.spacing.sm),
        Text(l.onboardingSelectSubtitle, style: tokens.text.body),
        SizedBox(height: tokens.spacing.md),
        Text(
          l.onboardingSelectionCounter(selected.length),
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
    required this.onToggle,
  });

  final Virtue virtue;
  final Set<HabitSuggestionKey> selected;
  final void Function(HabitSuggestionKey, bool) onToggle;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final l = AppLocalizations.of(context);
    final suggestions =
        kHabitSuggestions.where((s) => s.virtue == virtue).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(eyebrow: virtue.label(l)),
          SizedBox(height: tokens.spacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in suggestions)
                SelectableChip(
                  label: s.label(l),
                  selected: selected.contains(s.key),
                  onSelected: (v) => onToggle(s.key, v),
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
          child: ListView.separated(
            itemCount: suggestions.length,
            separatorBuilder: (_, _) => SizedBox(height: tokens.spacing.gap),
            itemBuilder: (context, i) {
              final s = suggestions[i];
              // Each chosen habit is a paper card with its virtue's stone
              // undertone as a left edge.
              final slabColor = tokens
                  .virtueSlab(s.virtue, VirtueProgressState.pulida)
                  .colors
                  .first;
              return AppCard(
                padding: EdgeInsets.zero,
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        decoration: BoxDecoration(
                          color: slabColor,
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(tokens.radii.card),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(tokens.spacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.label(l), style: tokens.text.bodyStrong),
                              SizedBox(height: tokens.spacing.xs),
                              Text(
                                s.virtue.label(l).toUpperCase(),
                                style: tokens.text.eyebrowSub,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
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
