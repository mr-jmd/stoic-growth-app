import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/database/repositories/habit_repository.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../shared/virtue_l10n.dart';
import '../tour/tour_targets.dart';

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

    // Tab root — the shell's nav bar is the way out, no back affordance.
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
            KeyedSubtree(
              key: tourHabitsAddKey,
              child: AppButton(
                label: l.habitsAdd,
                onPressed: () => context.push('/habits/new'),
              ),
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
      onTap: () => context.push('/habits/${habit.id}'),
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.lg,
        vertical: tokens.spacing.gap,
      ),
      child: Row(
        children: [
          // The habit-check dot — the accent at full strength.
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tokens.colors.habitCheckFill,
            ),
          ),
          SizedBox(width: tokens.spacing.gap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(habit.label, style: tokens.text.bodyStrong),
                SizedBox(height: tokens.spacing.xs),
                Text(
                  habit.virtue.label(l).toUpperCase(),
                  style: tokens.text.eyebrowSub,
                ),
              ],
            ),
          ),
          // Archiving is deliberately two steps away (menu → confirm) so it
          // can't happen by a stray tap.
          IconButton(
            onPressed: () => _showMenu(context, ref),
            tooltip: l.habitsMenuTooltip,
            icon: Icon(Icons.more_horiz, size: 20, color: tokens.colors.faint),
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          ),
        ],
      ),
    );
  }

  Future<void> _showMenu(BuildContext context, WidgetRef ref) async {
    final tokens = context.stoic;
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    final archive = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(tokens.radii.sheet)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: tokens.spacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  tokens.spacing.xl,
                  tokens.spacing.md,
                  tokens.spacing.xl,
                  tokens.spacing.sm,
                ),
                child: Text(
                  habit.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tokens.text.eyebrowSub,
                ),
              ),
              InkWell(
                onTap: () => Navigator.of(sheetContext).pop(true),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 52),
                  padding:
                      EdgeInsets.symmetric(horizontal: tokens.spacing.xl),
                  alignment: Alignment.centerLeft,
                  child: Text(l.habitsMenuArchive,
                      style: tokens.text.bodyStrong),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (archive != true || !context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.habitsArchiveConfirmTitle(habit.label)),
        content: Text(l.habitsArchiveConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l.dialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l.habitsArchiveConfirmAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await _archive(context, ref);
  }

  Future<void> _archive(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(habitRepositoryProvider).archiveHabit(habit.id);
    messenger.showSnackBar(SnackBar(content: Text(l.habitsArchived)));
  }
}
