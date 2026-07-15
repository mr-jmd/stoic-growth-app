import 'package:flutter/material.dart';

import '../tokens/palette.dart';
import '../tokens/stoic_tokens.dart';
import '../tokens/typography.dart';

/// Builds the two `ThemeData`s from a single token source (DESIGN_BRIEF §8).
/// `MaterialApp.router` gets both plus `ThemeMode.system` — the whole system is
/// mode-aware from Sprint 1; a manual toggle is an additive follow-up (§8.4).
ThemeData stoicLightTheme() => _build(Brightness.light);
ThemeData stoicDarkTheme() => _build(Brightness.dark);

ThemeData _build(Brightness brightness) {
  final isLight = brightness == Brightness.light;
  final tokens = isLight ? StoicTokens.light() : StoicTokens.dark();

  final ink = isLight ? inkLight : inkDark;
  final soft = isLight ? softLight : softDark;
  final surface = isLight ? ivoryLight : ivoryDark;
  final surfaceContainer = isLight ? cardLight : cardDark;
  final surfaceContainerHigh = isLight ? containerHighLight : containerHighDark;
  final line = isLight ? lineLight : lineDark;
  final primary = isLight ? slateLight : slateDark;
  final error = isLight ? errorLight : errorDark;

  // ColorScheme.fromSeed over-saturates in both modes; correct the load-bearing
  // roles by hand to the deliberately muted neutrals of DESIGN_BRIEF §2.
  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: brightness,
  ).copyWith(
    surface: surface,
    surfaceContainer: surfaceContainer,
    surfaceContainerHigh: surfaceContainerHigh,
    surfaceContainerHighest: surfaceContainerHigh,
    onSurface: ink,
    onSurfaceVariant: soft,
    outline: line,
    outlineVariant: line,
    primary: primary,
    onPrimary: onSlabWarm,
    error: error,
    onError: onSlabWarm,
  );

  final baseText = tokens.text.body;
  final textTheme = TextTheme(
    displayLarge: tokens.text.displayGreeting,
    displayMedium: tokens.text.displayGreeting,
    headlineMedium: tokens.text.displayGreeting,
    titleLarge: tokens.text.promptDisplay,
    titleMedium: baseText.copyWith(fontWeight: FontWeight.w600),
    bodyLarge: baseText,
    bodyMedium: baseText,
    bodySmall: tokens.text.attribution,
    labelLarge: tokens.text.chip,
    labelMedium: tokens.text.navLabel,
    labelSmall: tokens.text.eyebrow,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: fontBody,
    textTheme: textTheme,
    scaffoldBackgroundColor: surface,
    // Quiet ripple, not the flashy sparkle — fits the sober aesthetic.
    splashFactory: InkRipple.splashFactory,
    extensions: [tokens],
  );
}
