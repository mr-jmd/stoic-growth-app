import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// The visual material of a virtue slab at a given progress state
/// (DESIGN_BRIEF §3): a two-stop gradient plus the text colour that reads on it.
///
/// The qualitative state → slab mapping is chosen by the caller
/// ([StoicTokens.virtueSlab]); this class only carries resolved colours, so the
/// same [VirtueIndicator] widget renders in both themes with no `if (isDark)`.
@immutable
class VirtueSlab {
  const VirtueSlab({required this.colors, required this.onColor});

  /// Two gradient stops (start → end).
  final List<Color> colors;

  /// Text/icon colour that meets contrast on this slab.
  final Color onColor;

  /// The slab gradient at the brief's 158° angle.
  Gradient get gradient {
    const degrees = 158.0;
    final radians = degrees * math.pi / 180.0;
    final dx = math.cos(radians);
    final dy = math.sin(radians);
    return LinearGradient(
      begin: Alignment(-dx, -dy),
      end: Alignment(dx, dy),
      colors: colors,
    );
  }

  static VirtueSlab lerp(VirtueSlab a, VirtueSlab b, double t) {
    return VirtueSlab(
      colors: [
        Color.lerp(a.colors.first, b.colors.first, t)!,
        Color.lerp(a.colors.last, b.colors.last, t)!,
      ],
      onColor: Color.lerp(a.onColor, b.onColor, t)!,
    );
  }

  /// The "tomando color" (medium) state: this slab interpolated halfway toward
  /// [high]. Encodes DESIGN_BRIEF §3.2 — medium has no hex of its own.
  VirtueSlab midpointTo(VirtueSlab high) => lerp(this, high, 0.5);
}
