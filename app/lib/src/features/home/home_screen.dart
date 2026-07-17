import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/repositories/habit_repository.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../shared/virtue_l10n.dart';

/// Minimal home shell for Sprint 3 — the real virtue dashboard is Sprint 7.
/// Shows what the user is working on and a way into habit management (and, in
/// debug, the design gallery).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.stoic;
    final l = AppLocalizations.of(context);
    final habits = ref.watch(activeHabitsProvider);

    return AppScaffold(
      // Persistent, always-reachable crisis access (README 10.2) — one tap from
      // home into the calm grounding flow, never buried in settings.
      crisisAccess: CrisisAccessButton(
        label: l.crisisAccessLabel,
        onPressed: () => context.push('/crisis'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.homeTitle, style: tokens.text.displayGreeting),
            SizedBox(height: tokens.spacing.xl),
            Text(l.homeHabitsSectionTitle, style: tokens.text.eyebrow),
            SizedBox(height: tokens.spacing.md),
            Expanded(
              child: habits.when(
                data: (list) => ListView(
                  children: [
                    for (final h in list)
                      AppCard(
                        padding: EdgeInsets.symmetric(
                          horizontal: tokens.spacing.lg,
                          vertical: tokens.spacing.md,
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Text(h.label, style: tokens.text.body)),
                            Text(h.virtue.label(l), style: tokens.text.eyebrow),
                          ],
                        ),
                      ),
                  ],
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ),
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
      ),
    );
  }
}
