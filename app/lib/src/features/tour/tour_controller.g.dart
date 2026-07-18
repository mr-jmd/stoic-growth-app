// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tour_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the guided tour: `null` = inactive, otherwise the current step index
/// into [kTourSteps]. Both finishing and skipping persist the seen-flag, so the
/// tour auto-runs at most once; home can [start] it again anytime.

@ProviderFor(TourController)
final tourControllerProvider = TourControllerProvider._();

/// Drives the guided tour: `null` = inactive, otherwise the current step index
/// into [kTourSteps]. Both finishing and skipping persist the seen-flag, so the
/// tour auto-runs at most once; home can [start] it again anytime.
final class TourControllerProvider
    extends $NotifierProvider<TourController, int?> {
  /// Drives the guided tour: `null` = inactive, otherwise the current step index
  /// into [kTourSteps]. Both finishing and skipping persist the seen-flag, so the
  /// tour auto-runs at most once; home can [start] it again anytime.
  TourControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tourControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tourControllerHash();

  @$internal
  @override
  TourController create() => TourController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$tourControllerHash() => r'8138aeac9039c1206ce3255130fc11a6a273216f';

/// Drives the guided tour: `null` = inactive, otherwise the current step index
/// into [kTourSteps]. Both finishing and skipping persist the seen-flag, so the
/// tour auto-runs at most once; home can [start] it again anytime.

abstract class _$TourController extends $Notifier<int?> {
  int? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int?, int?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int?, int?>,
              int?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
