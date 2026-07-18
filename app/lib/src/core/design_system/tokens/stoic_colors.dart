import 'package:flutter/widgets.dart';

import 'palette.dart';

/// Per-mode semantic colours that don't map cleanly onto a `ColorScheme` role
/// but are needed by components (nav, crisis slab, chips, habit check, tertiary
/// text, the `appBg` gradient stops). Feature code reads these via
/// `StoicTokens.colors`, never the raw [palette] literals.
@immutable
class StoicColors {
  const StoicColors({
    required this.line,
    required this.faint,
    required this.labelWarm,
    required this.attribution,
    required this.eyebrowSub,
    required this.navActive,
    required this.navInactive,
    required this.navSurface,
    required this.accentSoft,
    required this.onAccentSoft,
    required this.bone,
    required this.containerHigh,
    required this.appBgInner,
    required this.appBgOuter,
    required this.crisisSurface,
    required this.crisisStroke,
    required this.chipSelectedFill,
    required this.chipSelectedText,
    required this.habitCheckFill,
    required this.habitCheckGlyph,
  });

  final Color line;
  final Color faint;
  final Color labelWarm;
  final Color attribution;
  final Color eyebrowSub;
  final Color navActive;
  final Color navInactive;
  final Color navSurface;

  /// Terracotta-tinted paper fill + its readable text (tonal buttons, accents).
  final Color accentSoft;
  final Color onAccentSoft;
  final Color bone;
  final Color containerHigh;
  final Color appBgInner;
  final Color appBgOuter;
  final Color crisisSurface;
  final Color crisisStroke;
  final Color chipSelectedFill;
  final Color chipSelectedText;
  final Color habitCheckFill;
  final Color habitCheckGlyph;

  static const StoicColors light = StoicColors(
    line: lineLight,
    faint: faintLight,
    labelWarm: labelWarmLight,
    attribution: attributionLight,
    eyebrowSub: eyebrowSubLight,
    navActive: navActiveLight,
    navInactive: navInactiveLight,
    navSurface: navSurfaceLight,
    accentSoft: accentSoftFillLight,
    onAccentSoft: accentSoftTextLight,
    bone: boneLight,
    containerHigh: containerHighLight,
    appBgInner: appBgLightInner,
    appBgOuter: appBgLightOuter,
    crisisSurface: crisisSurfaceLight,
    crisisStroke: crisisStrokeLight,
    chipSelectedFill: chipSelectedFillLight,
    chipSelectedText: chipSelectedTextLight,
    habitCheckFill: habitCheckFillLight,
    habitCheckGlyph: habitCheckGlyphLight,
  );

  static const StoicColors dark = StoicColors(
    line: lineDark,
    faint: faintDark,
    labelWarm: labelWarmDark,
    attribution: attributionDark,
    eyebrowSub: eyebrowSubDark,
    navActive: navActiveDark,
    navInactive: navInactiveDark,
    navSurface: navSurfaceDark,
    accentSoft: accentSoftFillDark,
    onAccentSoft: accentSoftTextDark,
    bone: boneDark,
    containerHigh: containerHighDark,
    appBgInner: appBgDarkInner,
    appBgOuter: appBgDarkOuter,
    crisisSurface: crisisSurfaceDark,
    crisisStroke: crisisStrokeDark,
    chipSelectedFill: chipSelectedFillDark,
    chipSelectedText: chipSelectedTextDark,
    habitCheckFill: habitCheckFillDark,
    habitCheckGlyph: habitCheckGlyphDark,
  );

  static StoicColors lerp(StoicColors a, StoicColors b, double t) {
    Color c(Color x, Color y) => Color.lerp(x, y, t)!;
    return StoicColors(
      line: c(a.line, b.line),
      faint: c(a.faint, b.faint),
      labelWarm: c(a.labelWarm, b.labelWarm),
      attribution: c(a.attribution, b.attribution),
      eyebrowSub: c(a.eyebrowSub, b.eyebrowSub),
      navActive: c(a.navActive, b.navActive),
      navInactive: c(a.navInactive, b.navInactive),
      navSurface: c(a.navSurface, b.navSurface),
      accentSoft: c(a.accentSoft, b.accentSoft),
      onAccentSoft: c(a.onAccentSoft, b.onAccentSoft),
      bone: c(a.bone, b.bone),
      containerHigh: c(a.containerHigh, b.containerHigh),
      appBgInner: c(a.appBgInner, b.appBgInner),
      appBgOuter: c(a.appBgOuter, b.appBgOuter),
      crisisSurface: c(a.crisisSurface, b.crisisSurface),
      crisisStroke: c(a.crisisStroke, b.crisisStroke),
      chipSelectedFill: c(a.chipSelectedFill, b.chipSelectedFill),
      chipSelectedText: c(a.chipSelectedText, b.chipSelectedText),
      habitCheckFill: c(a.habitCheckFill, b.habitCheckFill),
      habitCheckGlyph: c(a.habitCheckGlyph, b.habitCheckGlyph),
    );
  }
}
