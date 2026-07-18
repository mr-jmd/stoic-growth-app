import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// Motion tokens. **Shared between modes** (never interpolated). Calm,
/// deliberate movement: nothing snaps, nothing bounces.
///
/// The crisis `BreathingTimer` does NOT use these — its phase durations are
/// product behaviour (the breathing script), not styling.
@immutable
class StoicMotion {
  const StoicMotion();

  /// Chip/selection feedback.
  final Duration fast = const Duration(milliseconds: 120);

  /// Standard transitions (fades, fills).
  final Duration base = const Duration(milliseconds: 240);

  /// Editorial entrances (onboarding manifesto, splash).
  final Duration slow = const Duration(milliseconds: 420);

  final Curve standard = Curves.easeOutCubic;
  final Curve emphasized = Curves.easeInOutCubicEmphasized;
}
