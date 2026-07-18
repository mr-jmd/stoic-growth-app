import 'package:flutter/widgets.dart';

import 'palette.dart';

/// Elevation treatment. **Per-mode.**
///
/// - Light ("mármol"): a two-layer warm ambient shadow — a wide soft wash plus
///   a tight contact line. Paper floating on marble, never a Material drop.
/// - Dark ("basalto"): shadows nearly off; depth reads from the surface
///   lightness step (`surface → containerHigh`) + a hairline [border] + an
///   inner highlight.
@immutable
class StoicElevation {
  const StoicElevation({
    required this.card,
    required this.raised,
    required this.border,
    required this.innerHighlight,
  });

  /// Shadows for `AppCard`-level elevation.
  final List<BoxShadow> card;

  /// Shadows for a more raised surface (dialogs, sheets).
  final List<BoxShadow> raised;

  /// Hairline border — subtle in light, load-bearing in dark.
  final Border? border;

  /// Top inner-highlight colour applied by components as a 1px inset line.
  final Color innerHighlight;

  static BoxShadow _s(Color c, double a, double y, double blur) =>
      BoxShadow(color: c.withValues(alpha: a), offset: Offset(0, y), blurRadius: blur);

  factory StoicElevation.light() => StoicElevation(
        card: [
          _s(shadowWarmLight, 0.05, 1, 3),
          _s(shadowWarmLight, 0.08, 8, 24),
        ],
        raised: [
          _s(shadowWarmLight, 0.06, 2, 4),
          _s(shadowWarmLight, 0.10, 16, 40),
        ],
        border: const Border.fromBorderSide(BorderSide(color: lineLight, width: 1)),
        innerHighlight: innerHighlightLight.withValues(alpha: 0.5),
      );

  factory StoicElevation.dark() => StoicElevation(
        card: [
          _s(shadowWarmDark, 0.40, 1, 2),
        ],
        raised: [
          _s(shadowWarmDark, 0.50, 8, 24),
        ],
        border: const Border.fromBorderSide(BorderSide(color: lineDark, width: 1)),
        innerHighlight: innerHighlightDark.withValues(alpha: 0.05),
      );

  static StoicElevation lerp(StoicElevation a, StoicElevation b, double t) {
    return t < 0.5 ? a : b; // shadow lists don't interpolate cleanly; snap.
  }
}
