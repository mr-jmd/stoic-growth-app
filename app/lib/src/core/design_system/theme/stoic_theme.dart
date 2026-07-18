import 'package:flutter/material.dart';

import '../tokens/palette.dart';
import '../tokens/stoic_tokens.dart';
import '../tokens/typography.dart';

/// Builds the two `ThemeData`s of "Piedra y luz" from a single token source.
/// `MaterialApp.router` gets both plus `ThemeMode.system`.
///
/// Component themes here (input, dialog, snackbar, text button) are how the
/// stock Material widgets used inside features (TextField, AlertDialog,
/// SnackBar) pick up the new identity without wrappers.
ThemeData stoicLightTheme() => _build(Brightness.light);
ThemeData stoicDarkTheme() => _build(Brightness.dark);

ThemeData _build(Brightness brightness) {
  final isLight = brightness == Brightness.light;
  final tokens = isLight ? StoicTokens.light() : StoicTokens.dark();

  final ink = isLight ? inkLight : inkDark;
  final soft = isLight ? softLight : softDark;
  final faint = isLight ? faintLight : faintDark;
  final surface = isLight ? ivoryLight : ivoryDark;
  final surfaceContainer = isLight ? cardLight : cardDark;
  final surfaceContainerHigh = isLight ? containerHighLight : containerHighDark;
  final bone = isLight ? boneLight : boneDark;
  final line = isLight ? lineLight : lineDark;
  final accent = isLight ? accentLight : accentDark;
  final onAccent = isLight ? onAccentLight : onAccentDark;
  final error = isLight ? errorLight : errorDark;

  // ColorScheme.fromSeed over-saturates in both modes; correct the load-bearing
  // roles by hand to the muted marble/basalt neutrals.
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
    primary: accent,
    onPrimary: onAccent,
    error: error,
    onError: onAccentLight,
  );

  final baseText = tokens.text.body;
  final textTheme = TextTheme(
    displayLarge: tokens.text.displayHero,
    displayMedium: tokens.text.displayGreeting,
    headlineMedium: tokens.text.displayGreeting,
    titleLarge: tokens.text.promptDisplay,
    titleMedium: tokens.text.bodyStrong,
    bodyLarge: baseText,
    bodyMedium: baseText,
    bodySmall: tokens.text.attribution,
    labelLarge: tokens.text.chip,
    labelMedium: tokens.text.navLabel,
    labelSmall: tokens.text.eyebrow,
  );

  final radii = tokens.radii;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: fontBody,
    textTheme: textTheme,
    scaffoldBackgroundColor: surface,
    // Quiet ripple, not the flashy sparkle — fits the calm aesthetic.
    splashFactory: InkRipple.splashFactory,
    // Text inputs: warm inset paper, hairline at rest, accent when focused.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bone,
      hintStyle: baseText.copyWith(color: faint),
      counterStyle: tokens.text.caption,
      contentPadding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.lg,
        vertical: tokens.spacing.md + 2,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radii.tile),
        borderSide: BorderSide(color: line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radii.tile),
        borderSide: BorderSide(color: accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radii.tile),
        borderSide: BorderSide(color: error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radii.tile),
        borderSide: BorderSide(color: error, width: 1.5),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radii.tile),
        borderSide: BorderSide(color: line),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceContainer,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radii.sheet),
      ),
      titleTextStyle: tokens.text.title,
      contentTextStyle: baseText,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: ink,
      contentTextStyle: baseText.copyWith(color: surface),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radii.tile),
      ),
      elevation: 0,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: soft,
        textStyle: tokens.text.bodyStrong,
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radii.affordance),
        ),
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: ink,
        borderRadius: BorderRadius.circular(tokens.radii.chip),
      ),
      textStyle: tokens.text.caption.copyWith(color: surface),
    ),
    dividerTheme: DividerThemeData(color: line, thickness: 1, space: 1),
    extensions: [tokens],
  );
}
