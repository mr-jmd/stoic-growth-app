import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/database/repositories/habit_repository.dart';
import '../../core/database/repositories/onboarding_repository.dart';
import 'onboarding_suggestions.dart';

part 'onboarding_controller.g.dart';

/// Drives the end of the onboarding flow: creates the chosen habits, then marks
/// onboarding complete. Completing the flag flips [onboardingCompletedProvider],
/// which the router gate observes to move the user to home — no manual nav here.
@riverpod
class OnboardingController extends _$OnboardingController {
  @override
  FutureOr<void> build() {}

  /// Creates a habit per selected [suggestions] (in order), then completes
  /// onboarding. Surfaces loading/error via [state] for the screen to react.
  Future<void> finish(
    List<HabitSuggestion> suggestions,
    String Function(HabitSuggestion) label,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final habits = ref.read(habitRepositoryProvider);
      for (var i = 0; i < suggestions.length; i++) {
        await habits.createHabit(
          label: label(suggestions[i]),
          virtue: suggestions[i].virtue,
          sortOrder: i,
        );
      }
      // Always mark onboarding complete so the gate lets the user through.
      await ref.read(onboardingRepositoryProvider).complete();
    });
  }
}
