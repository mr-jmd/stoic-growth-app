import 'package:flutter/widgets.dart';

/// The two vendored OFL families (assets/fonts/, declared in pubspec.yaml).
/// Never fetched at runtime — that would break the 100%-offline invariant.
const String fontDisplay = 'Cormorant Garamond'; // inscriptional serif
const String fontBody = 'Source Sans 3'; // sober humanist sans

/// Both families ship as variable fonts. We set `fontVariations` on the `wght`
/// axis explicitly (and mirror it on `fontWeight` for fallback/metrics).
List<FontVariation> _wght(int w) => [FontVariation('wght', w.toDouble())];

FontWeight _weight(int w) => FontWeight.values.firstWhere(
      (fw) => fw.value == ((w ~/ 100) * 100),
      orElse: () => FontWeight.normal,
    );

TextStyle _display(double size, int weight, Color color,
        {double? height, bool italic = false, double? letterSpacing}) =>
    TextStyle(
      fontFamily: fontDisplay,
      fontSize: size,
      fontWeight: _weight(weight),
      fontVariations: _wght(weight),
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );

TextStyle _sans(double size, int weight, Color color,
        {double? height, double? letterSpacing}) =>
    TextStyle(
      fontFamily: fontBody,
      fontSize: size,
      fontWeight: _weight(weight),
      fontVariations: _wght(weight),
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );

/// Named text roles from DESIGN_BRIEF §1. Sizes/weights/tracking are **shared**
/// across modes; only the resolved colour differs, so the whole object is built
/// per-mode from that mode's palette (passed in by the theme builder).
@immutable
class StoicText {
  const StoicText({
    required this.displayGreeting,
    required this.virtueName,
    required this.quote,
    required this.promptDisplay,
    required this.reflection,
    required this.eyebrow,
    required this.eyebrowSub,
    required this.body,
    required this.chip,
    required this.attribution,
    required this.navLabel,
  });

  final TextStyle displayGreeting;
  final TextStyle virtueName;
  final TextStyle quote;
  final TextStyle promptDisplay;
  final TextStyle reflection;
  final TextStyle eyebrow;
  final TextStyle eyebrowSub;
  final TextStyle body;
  final TextStyle chip;
  final TextStyle attribution;
  final TextStyle navLabel;

  factory StoicText.build({
    required Color ink,
    required Color soft,
    required Color faint,
    required Color eyebrowSubColor,
    required Color attributionColor,
    required Color navInactive,
  }) {
    return StoicText(
      displayGreeting: _display(32, 500, ink),
      virtueName: _display(22, 500, ink),
      quote: _display(24, 400, ink, height: 1.32),
      promptDisplay: _display(20, 500, ink),
      reflection: _display(17, 400, soft, italic: true),
      eyebrow: _sans(10.5, 600, faint, letterSpacing: 10.5 * 0.19),
      eyebrowSub: _sans(9.5, 600, eyebrowSubColor, letterSpacing: 9.5 * 0.16),
      body: _sans(14.5, 400, ink),
      chip: _sans(12.5, 500, ink),
      attribution: _sans(11, 500, attributionColor),
      navLabel: _sans(10, 600, navInactive),
    );
  }

  static StoicText lerp(StoicText a, StoicText b, double t) {
    return StoicText(
      displayGreeting: TextStyle.lerp(a.displayGreeting, b.displayGreeting, t)!,
      virtueName: TextStyle.lerp(a.virtueName, b.virtueName, t)!,
      quote: TextStyle.lerp(a.quote, b.quote, t)!,
      promptDisplay: TextStyle.lerp(a.promptDisplay, b.promptDisplay, t)!,
      reflection: TextStyle.lerp(a.reflection, b.reflection, t)!,
      eyebrow: TextStyle.lerp(a.eyebrow, b.eyebrow, t)!,
      eyebrowSub: TextStyle.lerp(a.eyebrowSub, b.eyebrowSub, t)!,
      body: TextStyle.lerp(a.body, b.body, t)!,
      chip: TextStyle.lerp(a.chip, b.chip, t)!,
      attribution: TextStyle.lerp(a.attribution, b.attribution, t)!,
      navLabel: TextStyle.lerp(a.navLabel, b.navLabel, t)!,
    );
  }
}
