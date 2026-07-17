import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/repositories/habit_repository.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../shared/virtue.dart';
import '../../shared/virtue_progress_state.dart';
import '../daily_quote/daily_quote.dart';
import 'virtue_progress_calculator.dart';

/// The MVP dashboard (Sprint 7). Framed **around the four virtues** — not a
/// streak-count-first layout (streak numbers live in the habit detail). Shows
/// today's quote + reflection question, the virtue overview derived from habit
/// consistency, and calm entries into habits, journal, and (persistent) crisis.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.stoic;
    final l = AppLocalizations.of(context);
    final habits = ref.watch(activeHabitsProvider);
    final virtues = VirtueProgressCalculator.fromHabits(
      habits.asData?.value ?? const [],
    );

    return AppScaffold(
      // Persistent crisis access (README 10.2) — one tap into the grounding flow.
      crisisAccess: CrisisAccessButton(
        label: l.crisisAccessLabel,
        onPressed: () => context.push('/crisis'),
      ),
      body: ListView(
        // Bottom padding clears the floating crisis affordance.
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
        children: [
          Text(l.homeTitle, style: tokens.text.displayGreeting),
          SizedBox(height: tokens.spacing.xl),
          const _DailyQuoteCard(),
          SizedBox(height: tokens.spacing.xxl),
          Text(l.homeVirtuesSectionTitle, style: tokens.text.eyebrow),
          SizedBox(height: tokens.spacing.md),
          _VirtueGrid(states: virtues),
          SizedBox(height: tokens.spacing.xxl),
          Text(l.homeHabitsSectionTitle, style: tokens.text.eyebrow),
          SizedBox(height: tokens.spacing.md),
          AppButton(
            label: l.homeOpenHabits,
            onPressed: () => context.push('/habits'),
          ),
          SizedBox(height: tokens.spacing.xxl),
          Text(l.homeJournalSectionTitle, style: tokens.text.eyebrow),
          SizedBox(height: tokens.spacing.md),
          AppButton(
            label: l.homeOpenMorning,
            variant: AppButtonVariant.secondary,
            onPressed: () => context.push('/journal/morning'),
          ),
          SizedBox(height: tokens.spacing.sm),
          AppButton(
            label: l.homeOpenEvening,
            variant: AppButtonVariant.secondary,
            onPressed: () => context.push('/journal/evening'),
          ),
          if (kDebugMode) ...[
            SizedBox(height: tokens.spacing.sm),
            AppButton(
              label: l.homeOpenGallery,
              variant: AppButtonVariant.secondary,
              onPressed: () => context.push('/gallery'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Today's quote + its reflection question. Loads from the bundled asset; while
/// it resolves (or if it fails) the dashboard simply omits the card — never a
/// broken or blocking state.
class _DailyQuoteCard extends ConsumerWidget {
  const _DailyQuoteCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.stoic;
    final l = AppLocalizations.of(context);
    final quote = ref.watch(dailyQuoteProvider);

    return quote.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (q) => AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.homeQuoteEyebrow, style: tokens.text.eyebrow),
            SizedBox(height: tokens.spacing.md),
            Text(q.text, style: tokens.text.quote),
            SizedBox(height: tokens.spacing.sm),
            Text(q.author, style: tokens.text.attribution),
            SizedBox(height: tokens.spacing.lg),
            Text(q.reflection, style: tokens.text.reflection),
          ],
        ),
      ),
    );
  }
}

/// The four virtues as a 2×2 grid of material slabs (never numbers/bars). The
/// primary progress framing of the dashboard.
class _VirtueGrid extends StatelessWidget {
  const _VirtueGrid({required this.states});

  final Map<Virtue, VirtueProgressState> states;

  @override
  Widget build(BuildContext context) {
    final gap = context.stoic.spacing.gap;
    Widget cell(Virtue v) => Expanded(
          child: VirtueIndicator(virtue: v, state: states[v]!),
        );
    return Column(
      children: [
        Row(children: [
          cell(Virtue.templanza),
          SizedBox(width: gap),
          cell(Virtue.coraje),
        ]),
        SizedBox(height: gap),
        Row(children: [
          cell(Virtue.sabiduria),
          SizedBox(width: gap),
          cell(Virtue.justicia),
        ]),
      ],
    );
  }
}
