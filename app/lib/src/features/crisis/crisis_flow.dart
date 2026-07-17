import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'crisis_flow.g.dart';

/// The crisis flow's phases (README 10.2). The ordering is the whole point:
/// relief always comes first, and the socratic prompt is structurally gated on
/// having passed [relief] — see [reliefIsComplete], which the screen uses to
/// keep the prompt widget **out of the tree** until relief is done.
///
/// `relief` → (breathing timer finishes) → `reliefComplete`
///          → (user opts into another question) → `socraticOffered`
///          → (user leaves) → `dismissed`
enum CrisisFlowState { relief, reliefComplete, socraticOffered, dismissed }

extension CrisisFlowStatePhase on CrisisFlowState {
  /// True once relief is over — the only gate under which a socratic prompt may
  /// exist. `dismissed` is a leaving state, so it does not re-open the prompt.
  bool get reliefIsComplete =>
      this == CrisisFlowState.reliefComplete ||
      this == CrisisFlowState.socraticOffered;
}

/// Screen-local flow controller (autoDispose, so leaving crisis resets it — it
/// is never global app state). The relief→question transition can only be
/// triggered by the breathing timer completing, never by opening a question
/// first.
@riverpod
class CrisisFlow extends _$CrisisFlow {
  @override
  CrisisFlowState build() => CrisisFlowState.relief;

  /// Called by the breathing timer when relief finishes — the only path out of
  /// [CrisisFlowState.relief].
  void completeRelief() {
    if (state == CrisisFlowState.relief) {
      state = CrisisFlowState.reliefComplete;
    }
  }

  /// The user opted into exploring a(nother) question — a deliberate tap, never
  /// automatic.
  void offerSocratic() {
    if (state.reliefIsComplete) state = CrisisFlowState.socraticOffered;
  }

  void dismiss() => state = CrisisFlowState.dismissed;
}
