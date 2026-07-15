import 'package:flutter/widgets.dart';

import 'palette.dart';

/// Elevation treatment (DESIGN_BRIEF §2 "Sombras"). **Per-mode.**
///
/// - Light ("mármol"): diffuse, low-contrast, warm-tinted drop shadows.
/// - Dark ("basalto"): elevation reads mostly from the `surface → surfaceContainer`
///   luminance step + a hairline [border] + an inner highlight; the drop shadow
///   is secondary and warm-near-black, never pure black.
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

  /// Shadows for a more raised surface (crisis slab, sheets).
  final List<BoxShadow> raised;

  /// Hairline border — null in light (shadow carries it), a 1px `line` in dark.
  final Border? border;

  /// Top inner-highlight colour applied by components as a 1px inset line.
  final Color innerHighlight;

  static BoxShadow _s(Color c, double a, double y, double blur) =>
      BoxShadow(color: c.withValues(alpha: a), offset: Offset(0, y), blurRadius: blur);

  factory StoicElevation.light() => StoicElevation(
        card: [
          _s(shadowWarmLight, 0.04, 1, 2),
          _s(shadowWarmLight, 0.05, 8, 22),
        ],
        raised: [
          _s(shadowWarmLight, 0.05, 1, 2),
          _s(shadowWarmLight, 0.08, 14, 38),
          _s(shadowWarmLight, 0.05, 40, 72),
        ],
        border: null,
        innerHighlight: innerHighlightLight.withValues(alpha: 0.35),
      );

  factory StoicElevation.dark() => StoicElevation(
        card: [
          _s(shadowWarmDark, 0.50, 1, 2),
          _s(shadowWarmDark, 0.35, 10, 26),
        ],
        raised: [
          _s(shadowWarmDark, 0.55, 2, 4),
          _s(shadowWarmDark, 0.40, 18, 44),
        ],
        border: const Border.fromBorderSide(BorderSide(color: lineDark, width: 1)),
        innerHighlight: innerHighlightDark.withValues(alpha: 0.05),
      );

  static StoicElevation lerp(StoicElevation a, StoicElevation b, double t) {
    return t < 0.5 ? a : b; // shadow lists don't interpolate cleanly; snap.
  }
}
