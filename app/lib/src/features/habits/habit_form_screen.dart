import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/repositories/habit_repository.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../shared/virtue.dart';
import '../../shared/virtue_l10n.dart';

/// Create-habit form: a label plus a virtue. Enforces the 3-active cap with a
/// clear, non-punitive message (the repository is the real guard; this surfaces
/// it). Reused by the habits list and reachable during normal use, not just
/// onboarding.
class HabitFormScreen extends ConsumerStatefulWidget {
  const HabitFormScreen({super.key});

  @override
  ConsumerState<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends ConsumerState<HabitFormScreen> {
  final _labelController = TextEditingController();
  Virtue _virtue = Virtue.templanza;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final scheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);

    return AppScaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.habitFormTitle, style: tokens.text.displayGreeting),
            SizedBox(height: tokens.spacing.xl),
            Text(l.habitFormLabelHint, style: tokens.text.eyebrow),
            SizedBox(height: tokens.spacing.sm),
            TextField(
              controller: _labelController,
              maxLength: 80,
              style: tokens.text.body,
              decoration: InputDecoration(
                filled: true,
                fillColor: scheme.surfaceContainer,
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
            SizedBox(height: tokens.spacing.lg),
            Text(l.habitFormVirtueLabel, style: tokens.text.eyebrow),
            SizedBox(height: tokens.spacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final v in Virtue.values)
                  SelectableChip(
                    label: v.label(l),
                    selected: _virtue == v,
                    onSelected: (_) => setState(() => _virtue = v),
                  ),
              ],
            ),
            if (_error != null) ...[
              SizedBox(height: tokens.spacing.lg),
              Text(
                _error!,
                style: tokens.text.body.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
            const Spacer(),
            Row(
              children: [
                AppButton(
                  label: l.onboardingBack,
                  variant: AppButtonVariant.secondary,
                  onPressed: _saving ? null : () => context.pop(),
                ),
                const Spacer(),
                AppButton(
                  label: l.habitFormSave,
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    final label = _labelController.text.trim();
    if (label.isEmpty) {
      setState(() => _error = l.habitFormEmptyLabel);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(habitRepositoryProvider)
          .createHabit(label: label, virtue: _virtue);
      if (mounted) context.pop();
    } on MaxActiveHabitsException {
      setState(() {
        _saving = false;
        _error = l.habitsLimitReached;
      });
    }
  }
}
