import 'package:flutter/foundation.dart';

/// Spacing scale (DESIGN_BRIEF §4). **Shared between light and dark** — geometry
/// never changes with theme. Values are the design's adjusted set: 4·8·12·14·16·20·24.
@immutable
class StoicSpacing {
  const StoicSpacing();

  final double xs = 4;
  final double sm = 8;
  final double md = 12;
  final double gap = 14; // gap between cards
  final double lg = 16;
  final double xl = 20; // card inner padding
  final double xxl = 24; // space above the virtue block
}

/// Corner radii (DESIGN_BRIEF §4) — contained, "carved stone". Shared across modes.
@immutable
class StoicRadii {
  const StoicRadii();

  final double chip = 7;
  final double tile = 10; // virtue slabs, habit rows
  final double card = 12; // quote / morning / evening cards
  final double affordance = 14; // crisis access, buttons
}
