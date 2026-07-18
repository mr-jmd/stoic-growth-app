import 'package:flutter/widgets.dart';

/// The two vendored OFL families (assets/fonts/, declared in pubspec.yaml).
/// Never fetched at runtime — that would break the 100%-offline invariant.
///
/// - **Fraunces** (display): an editorial serif with optical sizing; used
///   straight (SOFT 0, WONK 0) for a contemporary Mediterranean voice.
/// - **Instrument Sans** (body): a warm grotesque, quiet at small sizes.
const String fontDisplay = 'Fraunces';
const String fontBody = 'Instrument Sans';

FontWeight _weight(int w) => FontWeight.values.firstWhere(
      (fw) => fw.value == ((w ~/ 100) * 100),
      orElse: () => FontWeight.normal,
    );

/// Fraunces: pin `opsz` to the rendered size so hero sizes get the high-contrast
/// display cut and small sizes stay readable; SOFT/WONK stay 0 (straight voice).
TextStyle _display(double size, int weight, Color color,
        {double? height, bool italic = false, double? letterSpacing}) =>
    TextStyle(
      fontFamily: fontDisplay,
      fontSize: size,
      fontWeight: _weight(weight),
      fontVariations: [
        FontVariation('wght', weight.toDouble()),
        FontVariation('opsz', size.clamp(9, 144).toDouble()),
        const FontVariation('SOFT', 0),
        const FontVariation('WONK', 0),
      ],
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
      fontVariations: [
        FontVariation('wght', weight.toDouble()),
        const FontVariation('wdth', 100),
      ],
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );

/// Named text roles of the "Piedra y luz" type system. Sizes/weights/tracking
/// are **shared** across modes; only the resolved colour differs, so the whole
/// object is built per-mode from that mode's palette (passed in by the theme
/// builder).
@immutable
class StoicText {
  const StoicText({
    required this.displayHero,
    required this.displayGreeting,
    required this.title,
    required this.virtueName,
    required this.quote,
    required this.promptDisplay,
    required this.reflection,
    required this.numeral,
    required this.eyebrow,
    required this.eyebrowSub,
    required this.body,
    required this.bodyStrong,
    required this.caption,
    required this.chip,
    required this.attribution,
    required this.navLabel,
  });

  /// Onboarding/crisis hero statements.
  final TextStyle displayHero;
  final TextStyle displayGreeting;

  /// Card/section titles.
  final TextStyle title;
  final TextStyle virtueName;

  /// The editorial quote voice (home hero).
  final TextStyle quote;
  final TextStyle promptDisplay;
  final TextStyle reflection;

  /// Big tabular figures (streak count). Renders plain digits.
  final TextStyle numeral;
  final TextStyle eyebrow;
  final TextStyle eyebrowSub;
  final TextStyle body;
  final TextStyle bodyStrong;
  final TextStyle caption;
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
      displayHero: _display(40, 580, ink, height: 1.08),
      displayGreeting: _display(34, 560, ink, height: 1.15),
      title: _display(20, 540, ink),
      virtueName: _display(21, 540, ink),
      quote: _display(30, 420, ink, height: 1.25),
      promptDisplay: _display(24, 500, ink, height: 1.25),
      reflection: _display(17, 420, soft, height: 1.4, italic: true),
      numeral: _display(56, 480, ink, height: 1.0),
      eyebrow: _sans(11, 640, faint, letterSpacing: 11 * 0.16),
      eyebrowSub: _sans(10, 600, eyebrowSubColor, letterSpacing: 10 * 0.12),
      body: _sans(15, 430, ink, height: 1.5),
      bodyStrong: _sans(15, 600, ink),
      caption: _sans(12, 450, soft, height: 1.4),
      chip: _sans(13.5, 520, ink),
      attribution: _sans(12, 540, attributionColor, letterSpacing: 12 * 0.04),
      navLabel: _sans(10.5, 620, navInactive),
    );
  }

  static StoicText lerp(StoicText a, StoicText b, double t) {
    TextStyle s(TextStyle x, TextStyle y) => TextStyle.lerp(x, y, t)!;
    return StoicText(
      displayHero: s(a.displayHero, b.displayHero),
      displayGreeting: s(a.displayGreeting, b.displayGreeting),
      title: s(a.title, b.title),
      virtueName: s(a.virtueName, b.virtueName),
      quote: s(a.quote, b.quote),
      promptDisplay: s(a.promptDisplay, b.promptDisplay),
      reflection: s(a.reflection, b.reflection),
      numeral: s(a.numeral, b.numeral),
      eyebrow: s(a.eyebrow, b.eyebrow),
      eyebrowSub: s(a.eyebrowSub, b.eyebrowSub),
      body: s(a.body, b.body),
      bodyStrong: s(a.bodyStrong, b.bodyStrong),
      caption: s(a.caption, b.caption),
      chip: s(a.chip, b.chip),
      attribution: s(a.attribution, b.attribution),
      navLabel: s(a.navLabel, b.navLabel),
    );
  }
}
