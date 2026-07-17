import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/database/repositories/habit_repository.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../shared/virtue_l10n.dart';

/// Lists the active habits with add/archive access. When there are none *after*
/// onboarding (the user archived everything), it shows the warm empty state —
/// a distinct case from onboarding, never a forced re-onboarding.
class HabitsListScreen extends ConsumerWidget {
  const HabitsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.stoic;
    final l = AppLocalizations.of(context);
    final habits = ref.watch(activeHabitsProvider);

    return AppScaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.habitsTitle, style: tokens.text.displayGreeting),
            SizedBox(height: tokens.spacing.lg),
            Expanded(
              child: habits.when(
                data: (list) => list.isEmpty
                    ? EmptyState(
                        title: l.emptyHabitsTitle,
                        message: l.emptyHabitsBody,
                        actionLabel: l.emptyHabitsAction,
                        onAction: () => context.push('/habits/new'),
                      )
                    : ListView.separated(
                        itemCount: list.length,
                        separatorBuilder: (_, _) =>
                            SizedBox(height: tokens.spacing.gap),
                        itemBuilder: (context, i) => _HabitRow(habit: list[i]),
                      ),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ),
            SizedBox(height: tokens.spacing.sm),
            AppButton(
              label: l.habitsAdd,
              onPressed: () => context.push('/habits/new'),
            ),
            SizedBox(height: tokens.spacing.sm),
          ],
        ),
      ),
    );
  }
}

class _HabitRow extends ConsumerWidget {
  const _HabitRow({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.stoic;
    final l = AppLocalizations.of(context);

    return AppCard(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.lg,
        vertical: tokens.spacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => context.push('/habits/${habit.id}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(habit.label, style: tokens.text.body),
                  SizedBox(height: tokens.spacing.xs),
                  Text(habit.virtue.label(l), style: tokens.text.eyebrow),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: () => _archive(context, ref),
            child: Text(
              l.habitsArchive,
              style: tokens.text.chip.copyWith(color: tokens.colors.faint),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _archive(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(habitRepositoryProvider).archiveHabit(habit.id);
    messenger.showSnackBar(SnackBar(content: Text(l.habitsArchived)));
  }
}
