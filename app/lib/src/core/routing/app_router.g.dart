// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

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

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
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
  AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'839e1b0d32aad95ba54e672080e78afe97b8ac5b';
