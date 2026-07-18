// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tutorial_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tutorialRepository)
final tutorialRepositoryProvider = TutorialRepositoryProvider._();

final class TutorialRepositoryProvider
    extends
        $FunctionalProvider<
          TutorialRepository,
          TutorialRepository,
          TutorialRepository
        >
    with $Provider<TutorialRepository> {
  TutorialRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tutorialRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tutorialRepositoryHash();

  @$internal
  @override
  $ProviderElement<TutorialRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TutorialRepository create(Ref ref) {
    return tutorialRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TutorialRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TutorialRepository>(value),
    );
  }
}

String _$tutorialRepositoryHash() =>
    r'c245bd15e06c0f1c10215c2c784c3b3712b0f358';

/// Reactive tour-seen state. The shell watches it to auto-start the tour on
/// the first post-onboarding landing.

@ProviderFor(tutorialCompleted)
final tutorialCompletedProvider = TutorialCompletedProvider._();

/// Reactive tour-seen state. The shell watches it to auto-start the tour on
/// the first post-onboarding landing.

final class TutorialCompletedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Reactive tour-seen state. The shell watches it to auto-start the tour on
  /// the first post-onboarding landing.
  TutorialCompletedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tutorialCompletedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tutorialCompletedHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return tutorialCompleted(ref);
  }
}

String _$tutorialCompletedHash() => r'4472547e37c2e1d104aa78144bca9b3b420e0f4c';
