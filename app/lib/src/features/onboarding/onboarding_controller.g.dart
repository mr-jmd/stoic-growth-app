// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the end of the onboarding flow: creates the chosen habits, then marks
/// onboarding complete. Completing the flag flips [onboardingCompletedProvider],
/// which the router gate observes to move the user to home — no manual nav here.

@ProviderFor(OnboardingController)
final onboardingControllerProvider = OnboardingControllerProvider._();

/// Drives the end of the onboarding flow: creates the chosen habits, then marks
/// onboarding complete. Completing the flag flips [onboardingCompletedProvider],
/// which the router gate observes to move the user to home — no manual nav here.
final class OnboardingControllerProvider
    extends $AsyncNotifierProvider<OnboardingController, void> {
  /// Drives the end of the onboarding flow: creates the chosen habits, then marks
  /// onboarding complete. Completing the flag flips [onboardingCompletedProvider],
  /// which the router gate observes to move the user to home — no manual nav here.
  OnboardingControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingControllerHash();

  @$internal
  @override
  OnboardingController create() => OnboardingController();
}

String _$onboardingControllerHash() =>
    r'03a363f448d2137c1724bbf32e8ecfba03abf536';

/// Drives the end of the onboarding flow: creates the chosen habits, then marks
/// onboarding complete. Completing the flag flips [onboardingCompletedProvider],
/// which the router gate observes to move the user to home — no manual nav here.

abstract class _$OnboardingController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
