import 'package:flutter/foundation.dart';

/// Spacing scale. **Shared between light and dark** — geometry never changes
/// with theme. "Piedra y luz" breathes: wider page margins and real editorial
/// air between blocks.
@immutable
class StoicSpacing {
  const StoicSpacing();

  final double xs = 4;
  final double sm = 8;
  final double md = 12;
  final double gap = 16; // gap between cards
  final double lg = 20;
  final double xl = 24; // card inner padding
  final double xxl = 32; // space between major sections
  final double page = 24; // horizontal page margin
  final double hero = 48; // editorial breathing room around hero blocks
}

/// Corner radii — soft contemporary stone, no hard carves. Shared across modes.
@immutable
class StoicRadii {
  const StoicRadii();

  final double chip = 12;
  final double tile = 16; // virtue slabs, habit rows, inputs
  final double card = 20; // paper cards
  final double affordance = 24; // buttons, calm band pill
  final double sheet = 28; // dialogs, sheets
  final double full = 999; // full pills
}

/// Minimum tap target (dp) — audited on every interactive element.
const double minTap = 48;
