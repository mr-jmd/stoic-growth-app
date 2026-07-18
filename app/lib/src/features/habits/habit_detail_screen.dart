import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/database/repositories/habit_repository.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../shared/check_in_status.dart';
import '../../shared/dates.dart';
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

    // One success per calendar day: once today is registered the button turns
    // into a calm "Registrado hoy" state. The repository guard is the real
    // invariant; this is the honest UI for it.
    final now = DateTime.now();
    final registeredToday = ref
            .watch(habitCheckInsProvider(habitId))
            .asData
            ?.value
            .any((c) =>
                c.status == CheckInStatus.success &&
                isSameLocalDay(c.date, now)) ??
        false;

    return AppScaffold(
      onBack: () => context.pop(),
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
                Text(h.virtue.label(l).toUpperCase(), style: tokens.text.eyebrow),
                SizedBox(height: tokens.spacing.sm),
                Text(h.label, style: tokens.text.displayGreeting),
                SizedBox(height: tokens.spacing.xl),
                _StreakCard(habit: h),
                SizedBox(height: tokens.spacing.lg),
                AppButton(
                  label: registeredToday
                      ? l.habitDetailRegisteredToday
                      : l.habitDetailRegisterToday,
                  onPressed: registeredToday
                      ? null
                      : () => _registerToday(context, ref),
                ),
                SizedBox(height: tokens.spacing.sm),
                AppButton(
                  label: l.habitDetailRegisterRelapse,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => context.push('/habits/$habitId/relapse'),
                ),
                SizedBox(height: tokens.spacing.xxl),
                SectionHeader(eyebrow: l.habitDetailHistoryTitle),
                SizedBox(height: tokens.spacing.gap),
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
          StepperControl(
            count: count,
            // Never below zero — a reset floors here, it doesn't go negative.
            onDecrement: count > 0 ? () => _set(ref, count - 1) : null,
            onIncrement: () => _set(ref, count + 1),
            decrementTooltip: l.habitDetailDecrement,
            incrementTooltip: l.habitDetailIncrement,
            onTapCount: () => _editDialog(context, ref),
            caption: l.habitDetailStreakLabel,
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

    // An editorial timeline row: the dot hangs on a hairline left rule.
    // Success uses the habit-check fill, a relapse the resting-stone tone —
    // neither is red.
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Align(
                    child: Container(width: 1, color: tokens.colors.line),
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSuccess
                        ? tokens.colors.habitCheckFill
                        : tokens.reposo.onColor.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: tokens.spacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: tokens.spacing.xs),
              child: Text(label, style: tokens.text.body),
            ),
          ),
          Text(date, style: tokens.text.caption),
        ],
      ),
    );
  }
}
