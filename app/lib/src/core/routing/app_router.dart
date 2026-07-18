import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/habits/habit_detail_screen.dart';
import '../../features/habits/habit_form_screen.dart';
import '../../features/habits/habits_list_screen.dart';
import '../../features/habits/relapse_form_screen.dart';
import '../../features/crisis/crisis_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/journal/evening_screen.dart';
import '../../features/journal/journal_hub_screen.dart';
import '../../features/journal/morning_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../database/repositories/onboarding_repository.dart';
import 'app_shell.dart';

part 'app_router.g.dart';

/// Single top-level GoRouter, consumed once in StoicApp.
///
/// Structure: a [StatefulShellRoute] with three branches (Hoy `/`, Hábitos
/// `/habits`, Diario `/journal`) wrapped by [AppShell] (tab bar + calm band).
/// Detail/form/entry flows and `/crisis` are pushed on the **root** navigator
/// (`parentNavigatorKey`), so they present full-screen over the shell while
/// tab state is preserved underneath.
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

  final rootKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootKey,
    refreshListenable: refresh,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/habits',
              builder: (context, state) => const HabitsListScreen(),
              routes: [
                // Declared before ':id' so "new" isn't captured as an id.
                GoRoute(
                  path: 'new',
                  parentNavigatorKey: rootKey,
                  builder: (context, state) => const HabitFormScreen(),
                ),
                GoRoute(
                  path: ':id',
                  parentNavigatorKey: rootKey,
                  builder: (context, state) => HabitDetailScreen(
                    habitId: int.parse(state.pathParameters['id']!),
                  ),
                  routes: [
                    GoRoute(
                      path: 'relapse',
                      parentNavigatorKey: rootKey,
                      builder: (context, state) => RelapseFormScreen(
                        habitId: int.parse(state.pathParameters['id']!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/journal',
              builder: (context, state) => const JournalHubScreen(),
              routes: [
                GoRoute(
                  path: 'morning',
                  parentNavigatorKey: rootKey,
                  builder: (context, state) => const MorningScreen(),
                ),
                GoRoute(
                  path: 'evening',
                  parentNavigatorKey: rootKey,
                  builder: (context, state) => const EveningScreen(),
                ),
              ],
            ),
          ]),
        ],
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      // Crisis mode: reachable from anywhere and exempt from the onboarding
      // gate — a person in distress must never be blocked by a setup flow.
      GoRoute(
        path: '/crisis',
        builder: (context, state) => const CrisisScreen(),
      ),
    ],
    redirect: (context, state) {
      final location = state.matchedLocation;
      if (location == '/crisis') return null; // safety: never gate crisis mode

      final completed = readCompleted();
      final atOnboarding = location == '/onboarding';

      if (!completed && !atOnboarding) return '/onboarding';
      if (completed && atOnboarding) return '/';
      return null;
    },
  );
}
