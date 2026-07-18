import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/repositories/habit_repository.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../shared/virtue.dart';
import '../../shared/virtue_progress_state.dart';
import '../daily_quote/daily_quote.dart';
import '../tour/tour_controller.dart';
import '../tour/tour_targets.dart';
import 'virtue_progress_calculator.dart';

/// The "Hoy" tab: an editorial front page. The daily quote opens the day as a
/// full-width hero (no card box), the four virtues follow as material slabs —
/// never streak-count-first (streak numbers live in the habit detail) — and the
/// journal's two moments close the page. Crisis access lives in the shell's
/// persistent calm band, on every tab.
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
    final date = MaterialLocalizations.of(context).formatFullDate(DateTime.now());

    return AppScaffold(
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.spacing.page,
          tokens.spacing.xl,
          tokens.spacing.page,
          tokens.spacing.xl,
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(date.toUpperCase(), style: tokens.text.eyebrow),
              ),
              // Quiet replay of the guided tour.
              IconButton(
                onPressed: () =>
                    ref.read(tourControllerProvider.notifier).start(),
                tooltip: l.tourReplayTooltip,
                icon: Icon(Icons.help_outline,
                    size: 18, color: tokens.colors.faint),
                constraints:
                    const BoxConstraints(minWidth: 48, minHeight: 48),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.sm),
          KeyedSubtree(key: tourQuoteHeroKey, child: const _DailyQuoteHero()),
          SizedBox(height: tokens.spacing.xxl),
          SectionHeader(eyebrow: l.homeVirtuesSectionTitle),
          SizedBox(height: tokens.spacing.gap),
          KeyedSubtree(
            key: tourVirtueGridKey,
            child: _VirtueGrid(states: virtues),
          ),
          SizedBox(height: tokens.spacing.xxl),
          SectionHeader(
            eyebrow: l.homeHabitsSectionTitle,
            trailingLabel: l.homeOpenHabits,
            onTrailing: () => context.go('/habits'),
          ),
          SizedBox(height: tokens.spacing.xxl),
          SectionHeader(eyebrow: l.homeJournalSectionTitle),
          SizedBox(height: tokens.spacing.gap),
          _JournalTile(
            label: l.homeOpenMorning,
            icon: Icons.wb_twilight,
            onTap: () => context.push('/journal/morning'),
          ),
          SizedBox(height: tokens.spacing.sm),
          _JournalTile(
            label: l.homeOpenEvening,
            icon: Icons.nightlight_outlined,
            onTap: () => context.push('/journal/evening'),
          ),
        ],
      ),
    );
  }
}

/// Today's quote + its reflection question as the page's editorial hero. Loads
/// from the bundled asset; while it resolves (or if it fails) the page simply
/// omits it — never a broken or blocking state.
class _DailyQuoteHero extends ConsumerWidget {
  const _DailyQuoteHero();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final quote = ref.watch(dailyQuoteProvider);

    return quote.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (q) => EditorialHero(
        eyebrow: l.homeQuoteEyebrow,
        quote: q.text,
        attribution: q.author,
        footnote: q.reflection,
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

/// A quiet inset tile into one of the journal's two moments.
class _JournalTile extends StatelessWidget {
  const _JournalTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;

    return AppCard(
      variant: AppCardVariant.inset,
      onTap: onTap,
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.lg,
        vertical: tokens.spacing.gap,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: tokens.colors.faint),
          SizedBox(width: tokens.spacing.md),
          Expanded(child: Text(label, style: tokens.text.bodyStrong)),
          Icon(Icons.chevron_right, size: 20, color: tokens.colors.faint),
        ],
      ),
    );
  }
}
