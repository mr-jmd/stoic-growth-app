import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/database/repositories/tutorial_repository.dart';
import 'tour_steps.dart';

part 'tour_controller.g.dart';

/// Drives the guided tour: `null` = inactive, otherwise the current step index
/// into [kTourSteps]. Both finishing and skipping persist the seen-flag, so the
/// tour auto-runs at most once; home can [start] it again anytime.
@Riverpod(keepAlive: true)
class TourController extends _$TourController {
  @override
  int? build() => null;

  void start() => state = 0;

  void next() {
    final current = state;
    if (current == null) return;
    if (current >= kTourSteps.length - 1) {
      finish();
    } else {
      state = current + 1;
    }
  }

  Future<void> skip() => _end();

  Future<void> finish() => _end();

  Future<void> _end() async {
    state = null;
    await ref.read(tutorialRepositoryProvider).complete();
  }
}
