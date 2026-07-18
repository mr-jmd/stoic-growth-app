import 'package:flutter/material.dart';

import '../tokens/stoic_tokens.dart';

enum AppButtonVariant {
  /// Terracotta pill — the single forward action of a screen.
  primary,

  /// Hairline-bordered quiet pill — "ahora no", dismiss, secondary paths.
  secondary,

  /// Terracotta-tinted paper fill — warm emphasis without full weight.
  tonal,

  /// Text-only — the quietest affordance.
  quiet,
}

/// The one button in the system. Full-pill silhouette, one accent, no strident
/// colour in any mode; ≥48dp tall.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.expanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;

  /// When true the button stretches to the available width.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final c = tokens.colors;
    final scheme = Theme.of(context).colorScheme;

    final (Color fill, Color text, BorderSide side) = switch (variant) {
      AppButtonVariant.primary => (
          scheme.primary,
          scheme.onPrimary,
          BorderSide.none,
        ),
      AppButtonVariant.secondary => (
          Colors.transparent,
          scheme.onSurface,
          BorderSide(color: c.line, width: 1),
        ),
      AppButtonVariant.tonal => (
          c.accentSoft,
          c.onAccentSoft,
          BorderSide.none,
        ),
      AppButtonVariant.quiet => (
          Colors.transparent,
          scheme.onSurfaceVariant,
          BorderSide.none,
        ),
    };

    final radius = BorderRadius.circular(tokens.radii.full);
    final labelStyle =
        tokens.text.bodyStrong.copyWith(fontSize: 14.5, color: text);

    return Material(
      color: fill,
      shape: RoundedRectangleBorder(borderRadius: radius, side: side),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52, minWidth: 88),
          alignment: Alignment.center,
          width: expanded ? double.infinity : null,
          padding: EdgeInsets.symmetric(horizontal: tokens.spacing.xl),
          child: Text(label, style: labelStyle),
        ),
      ),
    );
  }
}
