// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crisis_flow.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Screen-local flow controller (autoDispose, so leaving crisis resets it — it
/// is never global app state). The relief→question transition can only be
/// triggered by the breathing timer completing, never by opening a question
/// first.

@ProviderFor(CrisisFlow)
final crisisFlowProvider = CrisisFlowProvider._();

/// Screen-local flow controller (autoDispose, so leaving crisis resets it — it
/// is never global app state). The relief→question transition can only be
/// triggered by the breathing timer completing, never by opening a question
/// first.
final class CrisisFlowProvider
    extends $NotifierProvider<CrisisFlow, CrisisFlowState> {
  /// Screen-local flow controller (autoDispose, so leaving crisis resets it — it
  /// is never global app state). The relief→question transition can only be
  /// triggered by the breathing timer completing, never by opening a question
  /// first.
  CrisisFlowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'crisisFlowProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$crisisFlowHash();

  @$internal
  @override
  CrisisFlow create() => CrisisFlow();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CrisisFlowState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CrisisFlowState>(value),
    );
  }
}

String _$crisisFlowHash() => r'ebaa3b5ada964815b98a477bdb7e37bb2350efc8';

/// Screen-local flow controller (autoDispose, so leaving crisis resets it — it
/// is never global app state). The relief→question transition can only be
/// triggered by the breathing timer completing, never by opening a question
/// first.

abstract class _$CrisisFlow extends $Notifier<CrisisFlowState> {
  CrisisFlowState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CrisisFlowState, CrisisFlowState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CrisisFlowState, CrisisFlowState>,
              CrisisFlowState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
