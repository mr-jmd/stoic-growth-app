import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/habits/habit_detail_screen.dart';
import '../../features/habits/habit_form_screen.dart';
import '../../features/habits/habits_list_screen.dart';
import '../../features/habits/relapse_form_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../database/repositories/onboarding_repository.dart';
import '../design_system/gallery/design_gallery_screen.dart';

part 'app_router.g.dart';

/// Single top-level GoRouter, consumed once in StoicApp.
///
/// Onboarding gate: the redirect keys off the **persisted onboarding flag**
/// ([onboardingCompletedProvider]), never the habit count — so a user who
/// archives every habit lands on an empty state, not back in onboarding.
///
/// Both the `refreshListenable` and the redirect read that **same provider**
/// (bridged through a [ValueNotifier] via `ref.listen`), so completing
/// onboarding re-runs the redirect against an already-updated value. Using two
/// independent DB streams here caused a race where the redirect could still see
/// the old value and strand the user on the confirmation screen. StoicApp holds
/// a splash until the flag first loads, so the redirect never reads a null.
@riverpod
GoRouter appRouter(Ref ref) {
  bool readCompleted() =>
      ref.read(onboardingCompletedProvider).asData?.value ?? false;

  final refresh = ValueNotifier<bool>(readCompleted());
  ref.onDispose(refresh.dispose);
  ref.listen(onboardingCompletedProvider, (_, next) {
    refresh.value = next.asData?.value ?? false;
  });

  return GoRouter(
    refreshListenable: refresh,
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/habits',
        builder: (context, state) => const HabitsListScreen(),
      ),
      // Declared before '/habits/:id' so "new" isn't captured as an id.
      GoRoute(
        path: '/habits/new',
        builder: (context, state) => const HabitFormScreen(),
      ),
      GoRoute(
        path: '/habits/:id',
        builder: (context, state) => HabitDetailScreen(
          habitId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/habits/:id/relapse',
        builder: (context, state) => RelapseFormScreen(
          habitId: int.parse(state.pathParameters['id']!),
        ),
      ),
      // Debug-only design-system reference, exempt from the onboarding gate.
      if (kDebugMode)
        GoRoute(
          path: '/gallery',
          builder: (context, state) => const DesignGalleryScreen(),
        ),
    ],
    redirect: (context, state) {
      final location = state.matchedLocation;
      if (location == '/gallery') return null; // always reachable in debug

      final completed = readCompleted();
      final atOnboarding = location == '/onboarding';

      if (!completed && !atOnboarding) return '/onboarding';
      if (completed && atOnboarding) return '/';
      return null;
    },
  );
}
