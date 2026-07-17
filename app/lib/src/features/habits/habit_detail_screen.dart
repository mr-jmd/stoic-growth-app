import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/database/repositories/habit_repository.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../shared/check_in_status.dart';
import '../../shared/virtue_l10n.dart';

/// Habit detail: the live consistency count (directly editable), the two
/// first-class actions — "register today" and "log a relapse" — and the
/// append-only history where past relapses stay visible as data, never hidden.
///
/// Sprint 4's copy/visual constraints apply hard here: no red, no "you broke
/// your streak", no exclamation marks, no gamified framing. A relapse is a
/// learning event in `VirtueProgressState.enReposo`, never a failure.
class HabitDetailScreen extends ConsumerWidget {
  const HabitDetailScreen({super.key, required this.habitId});

  final int habitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.stoic;
    final l = AppLocalizations.of(context);
    final habit = ref.watch(habitByIdProvider(habitId));

    return AppScaffold(
      body: habit.when(
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
        data: (h) {
          if (h == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(h.label, style: tokens.text.displayGreeting),
                SizedBox(height: tokens.spacing.xs),
                Text(h.virtue.label(l), style: tokens.text.eyebrow),
                SizedBox(height: tokens.spacing.xl),
                _StreakCard(habit: h),
                SizedBox(height: tokens.spacing.lg),
                AppButton(
                  label: l.habitDetailRegisterToday,
                  onPressed: () => _registerToday(context, ref),
                ),
                SizedBox(height: tokens.spacing.sm),
                AppButton(
                  label: l.habitDetailRegisterRelapse,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => context.push('/habits/$habitId/relapse'),
                ),
                SizedBox(height: tokens.spacing.xxl),
                Text(l.habitDetailHistoryTitle, style: tokens.text.eyebrow),
                SizedBox(height: tokens.spacing.md),
                Expanded(child: _History(habitId: habitId)),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _registerToday(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    await ref
        .read(habitRepositoryProvider)
        .recordCheckIn(habitId: habitId, status: CheckInStatus.success);
    messenger.showSnackBar(SnackBar(content: Text(l.habitDetailRegistered)));
  }
}

/// The consistency count with a directly-editable value: a stepper for ±1 and
/// tap-to-edit for an arbitrary number. Editing is as prominent as "register
/// today", never buried in a settings menu.
class _StreakCard extends ConsumerWidget {
  const _StreakCard({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.stoic;
    final scheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    final count = habit.currentStreakCount;

    return AppCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StepperButton(
                icon: Icons.remove,
                tooltip: l.habitDetailDecrement,
                // Never below zero — a reset floors here, it doesn't go negative.
                onPressed:
                    count > 0 ? () => _set(ref, count - 1) : null,
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _editDialog(context, ref),
                  borderRadius: BorderRadius.circular(tokens.radii.card),
                  child: Column(
                    children: [
                      Text(
                        '$count',
                        style: tokens.text.displayGreeting.copyWith(
                          fontSize: 52,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        l.habitDetailStreakLabel,
                        style: tokens.text.eyebrow,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              _StepperButton(
                icon: Icons.add,
                tooltip: l.habitDetailIncrement,
                onPressed: () => _set(ref, count + 1),
              ),
            ],
          ),
          if (count == 0) ...[
            SizedBox(height: tokens.spacing.md),
            Text(
              l.habitDetailStreakZero,
              style: tokens.text.body.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  void _set(WidgetRef ref, int value) =>
      ref.read(habitRepositoryProvider).updateStreakManually(habit.id, value);

  Future<void> _editDialog(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final controller =
        TextEditingController(text: habit.currentStreakCount.toString());
    final value = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.habitDetailEditStreakTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l.habitDetailStreakLabel),
          onSubmitted: (_) =>
              Navigator.of(context).pop(_parse(controller.text)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.dialogCancel),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(_parse(controller.text)),
            child: Text(l.dialogSave),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value != null) _set(ref, value);
  }

  /// Parses the edited value, flooring at 0 and ignoring non-numeric input.
  int? _parse(String raw) {
    final parsed = int.tryParse(raw.trim());
    if (parsed == null) return null;
    return parsed < 0 ? 0 : parsed;
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon),
      color: scheme.onSurfaceVariant,
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radii.chip),
          side: BorderSide(color: tokens.colors.line),
        ),
        minimumSize: const Size(48, 48),
      ),
    );
  }
}

/// Append-only check-in history, newest first. Successes and relapses are both
/// shown as neutral facts — a relapse row is "en reposo", never red or "failed".
class _History extends ConsumerWidget {
  const _History({required this.habitId});

  final int habitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.stoic;
    final l = AppLocalizations.of(context);
    final checkIns = ref.watch(habitCheckInsProvider(habitId));

    return checkIns.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (list) {
        if (list.isEmpty) {
          return Text(
            l.habitDetailHistoryEmpty,
            style: tokens.text.body
                .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          );
        }
        // Stored ascending by date; show most recent first.
        final rows = list.reversed.toList();
        return ListView.separated(
          itemCount: rows.length,
          separatorBuilder: (_, _) => SizedBox(height: tokens.spacing.sm),
          itemBuilder: (context, i) => _HistoryRow(checkIn: rows[i]),
        );
      },
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.checkIn});

  final HabitCheckIn checkIn;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final l = AppLocalizations.of(context);
    final isSuccess = checkIn.status == CheckInStatus.success;
    final label = isSuccess
        ? l.habitDetailHistorySuccess
        : l.habitDetailHistoryRelapse;
    final date = MaterialLocalizations.of(context).formatMediumDate(checkIn.date);

    return Row(
      children: [
        // A small warm dot: success uses the habit-check fill, a relapse the
        // resting-stone tone — neither is red.
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSuccess
                ? tokens.colors.habitCheckFill
                : tokens.reposo.onColor.withValues(alpha: 0.5),
          ),
        ),
        SizedBox(width: tokens.spacing.md),
        Expanded(child: Text(label, style: tokens.text.body)),
        Text(date, style: tokens.text.eyebrow),
      ],
    );
  }
}
