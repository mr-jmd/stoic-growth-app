import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/repositories/habit_repository.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';

/// Logs a relapse as a learning event — context / trigger / learning, all
/// optional. Reachable in one tap from the habit detail (well inside the
/// "≤2 taps" acceptance target).
///
/// Copy is framed around learning, never confession or guilt: no red, no
/// "you broke your streak", no exclamation marks. Saving resets the streak to a
/// re-editable 0 (handled atomically in [HabitRepository.logRelapse]).
class RelapseFormScreen extends ConsumerStatefulWidget {
  const RelapseFormScreen({super.key, required this.habitId});

  final int habitId;

  @override
  ConsumerState<RelapseFormScreen> createState() => _RelapseFormScreenState();
}

class _RelapseFormScreenState extends ConsumerState<RelapseFormScreen> {
  final _context = TextEditingController();
  final _trigger = TextEditingController();
  final _learning = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _context.dispose();
    _trigger.dispose();
    _learning.dispose();
    super.dispose();
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
              // A calm resting-sand band frames the moment — the reposo
              // material, never red, never an alarm.
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(tokens.spacing.xl),
                decoration: BoxDecoration(
                  gradient: tokens.reposo.gradient,
                  borderRadius: BorderRadius.circular(tokens.radii.card),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.relapseFormTitle,
                      style: tokens.text.promptDisplay
                          .copyWith(color: tokens.reposo.onColor),
                    ),
                    SizedBox(height: tokens.spacing.md),
                    Text(
                      l.relapseFormSubtitle,
                      style: tokens.text.body.copyWith(
                        color: tokens.reposo.onColor.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: tokens.spacing.xl),
              Expanded(
                child: ListView(
                  children: [
                    _Field(label: l.relapseFormContextLabel, controller: _context),
                    SizedBox(height: tokens.spacing.lg),
                    _Field(label: l.relapseFormTriggerLabel, controller: _trigger),
                    SizedBox(height: tokens.spacing.lg),
                    _Field(label: l.relapseFormLearningLabel, controller: _learning),
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
                    label: l.relapseFormSave,
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

    String? nullIfEmpty(TextEditingController c) {
      final text = c.text.trim();
      return text.isEmpty ? null : text;
    }

    await ref.read(habitRepositoryProvider).logRelapse(
          habitId: widget.habitId,
          context: nullIfEmpty(_context),
          trigger: nullIfEmpty(_trigger),
          learning: nullIfEmpty(_learning),
        );

    messenger.showSnackBar(SnackBar(content: Text(l.relapseFormSaved)));
    router.pop();
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: tokens.text.eyebrow),
        SizedBox(height: tokens.spacing.md),
        // Styled by the theme's InputDecorationTheme (inset paper, accent focus).
        TextField(
          controller: controller,
          minLines: 2,
          maxLines: 4,
          style: tokens.text.body,
        ),
      ],
    );
  }
}
