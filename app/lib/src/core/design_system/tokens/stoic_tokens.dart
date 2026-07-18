import 'package:flutter/material.dart';

import '../../../shared/virtue.dart';
import '../../../shared/virtue_progress_state.dart';
import 'dimensions.dart';
import 'elevation.dart';
import 'motion.dart';
import 'palette.dart';
import 'stoic_colors.dart';
import 'typography.dart';
import 'virtue_slab.dart';

/// The single source of design tokens, exposed as a [ThemeExtension] so every
/// widget reads it via `Theme.of(context).extension<StoicTokens>()!` with no
/// `if (isDark)` branch. Two factories — [StoicTokens.light] / [StoicTokens.dark]
/// — are built once each and attached to their `ThemeData` (see stoic_theme.dart).
///
/// Structure follows DESIGN_BRIEF §8.2:
/// - **Shared** (identical across modes, not interpolated): [spacing], [radii].
/// - **Per-mode** (differ, interpolated by [lerp] for smooth `AnimatedTheme`):
///   [text], [elevation], [colors], and the virtue slab gradients.
@immutable
class StoicTokens extends ThemeExtension<StoicTokens> {
  const StoicTokens({
    required this.spacing,
    required this.radii,
    required this.motion,
    required this.text,
    required this.elevation,
    required this.colors,
    required this.virtueHigh,
    required this.virtueLow,
    required this.reposo,
  });

  final StoicSpacing spacing;
  final StoicRadii radii;
  final StoicMotion motion;
  final StoicText text;
  final StoicElevation elevation;
  final StoicColors colors;

  /// Prefer [virtueSlab] over reading these maps directly.
  final Map<Virtue, VirtueSlab> virtueHigh;
  final Map<Virtue, VirtueSlab> virtueLow;
  final VirtueSlab reposo;

  /// Resolves the material slab for a virtue at a progress state. Brightness is
  /// already baked in (this token object belongs to one mode); the caller only
  /// supplies the qualitative state (DESIGN_BRIEF §3.2).
  VirtueSlab virtueSlab(Virtue virtue, VirtueProgressState state) {
    switch (state) {
      case VirtueProgressState.sinDesbastar:
        return virtueLow[virtue]!;
      case VirtueProgressState.pulida:
        return virtueHigh[virtue]!;
      case VirtueProgressState.tomandoColor:
        return virtueLow[virtue]!.midpointTo(virtueHigh[virtue]!);
      case VirtueProgressState.enReposo:
        return reposo;
    }
  }

  factory StoicTokens.light() => StoicTokens(
        spacing: const StoicSpacing(),
        radii: const StoicRadii(),
        motion: const StoicMotion(),
        elevation: StoicElevation.light(),
        colors: StoicColors.light,
        text: StoicText.build(
          ink: inkLight,
          soft: softLight,
          faint: faintLight,
          eyebrowSubColor: eyebrowSubLight,
          attributionColor: attributionLight,
          navInactive: navInactiveLight,
        ),
        virtueHigh: const {
          Virtue.templanza: VirtueSlab(colors: templanzaHighLight, onColor: templanzaHighOnLight),
          Virtue.coraje: VirtueSlab(colors: corajeHighLight, onColor: corajeHighOnLight),
          Virtue.sabiduria: VirtueSlab(colors: sabiduriaHighLight, onColor: sabiduriaHighOnLight),
          Virtue.justicia: VirtueSlab(colors: justiciaHighLight, onColor: justiciaHighOnLight),
        },
        virtueLow: const {
          Virtue.templanza: VirtueSlab(colors: templanzaLowLight, onColor: templanzaLowTextLight),
          Virtue.coraje: VirtueSlab(colors: corajeLowLight, onColor: corajeLowTextLight),
          Virtue.sabiduria: VirtueSlab(colors: sabiduriaLowLight, onColor: sabiduriaLowTextLight),
          Virtue.justicia: VirtueSlab(colors: justiciaLowLight, onColor: justiciaLowTextLight),
        },
        reposo: const VirtueSlab(colors: reposoLight, onColor: reposoTextLight),
      );

  factory StoicTokens.dark() => StoicTokens(
        spacing: const StoicSpacing(),
        radii: const StoicRadii(),
        motion: const StoicMotion(),
        elevation: StoicElevation.dark(),
        colors: StoicColors.dark,
        text: StoicText.build(
          ink: inkDark,
          soft: softDark,
          faint: faintDark,
          eyebrowSubColor: eyebrowSubDark,
          attributionColor: attributionDark,
          navInactive: navInactiveDark,
        ),
        virtueHigh: const {
          Virtue.templanza: VirtueSlab(colors: templanzaHighDark, onColor: templanzaHighOnDark),
          Virtue.coraje: VirtueSlab(colors: corajeHighDark, onColor: corajeHighOnDark),
          Virtue.sabiduria: VirtueSlab(colors: sabiduriaHighDark, onColor: sabiduriaHighOnDark),
          Virtue.justicia: VirtueSlab(colors: justiciaHighDark, onColor: justiciaHighOnDark),
        },
        virtueLow: const {
          Virtue.templanza: VirtueSlab(colors: templanzaLowDark, onColor: templanzaLowTextDark),
          Virtue.coraje: VirtueSlab(colors: corajeLowDark, onColor: corajeLowTextDark),
          Virtue.sabiduria: VirtueSlab(colors: sabiduriaLowDark, onColor: sabiduriaLowTextDark),
          Virtue.justicia: VirtueSlab(colors: justiciaLowDark, onColor: justiciaLowTextDark),
        },
        reposo: const VirtueSlab(colors: reposoDark, onColor: reposoTextDark),
      );

  @override
  StoicTokens copyWith({
    StoicSpacing? spacing,
    StoicRadii? radii,
    StoicMotion? motion,
    StoicText? text,
    StoicElevation? elevation,
    StoicColors? colors,
    Map<Virtue, VirtueSlab>? virtueHigh,
    Map<Virtue, VirtueSlab>? virtueLow,
    VirtueSlab? reposo,
  }) {
    return StoicTokens(
      spacing: spacing ?? this.spacing,
      radii: radii ?? this.radii,
      motion: motion ?? this.motion,
      text: text ?? this.text,
      elevation: elevation ?? this.elevation,
      colors: colors ?? this.colors,
      virtueHigh: virtueHigh ?? this.virtueHigh,
      virtueLow: virtueLow ?? this.virtueLow,
      reposo: reposo ?? this.reposo,
    );
  }

  @override
  StoicTokens lerp(covariant ThemeExtension<StoicTokens>? other, double t) {
    if (other is! StoicTokens) return this;
    Map<Virtue, VirtueSlab> lerpMap(
      Map<Virtue, VirtueSlab> a,
      Map<Virtue, VirtueSlab> b,
    ) =>
        {for (final v in Virtue.values) v: VirtueSlab.lerp(a[v]!, b[v]!, t)};
    return StoicTokens(
      // Shared fields don't interpolate — geometry is identical across modes.
      spacing: spacing,
      radii: radii,
      motion: motion,
      // Per-mode fields cross-fade.
      text: StoicText.lerp(text, other.text, t),
      elevation: StoicElevation.lerp(elevation, other.elevation, t),
      colors: StoicColors.lerp(colors, other.colors, t),
      virtueHigh: lerpMap(virtueHigh, other.virtueHigh),
      virtueLow: lerpMap(virtueLow, other.virtueLow),
      reposo: VirtueSlab.lerp(reposo, other.reposo, t),
    );
  }
}

/// Ergonomic access: `context.stoic` → the active [StoicTokens].
extension StoicTokensContext on BuildContext {
  StoicTokens get stoic => Theme.of(this).extension<StoicTokens>()!;
}
