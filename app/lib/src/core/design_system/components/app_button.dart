import 'package:flutter/material.dart';

import '../tokens/stoic_tokens.dart';

enum AppButtonVariant {
  /// Warm interactive fill (`slate`) — the main forward action.
  primary,

  /// Quiet, bordered — "ahora no", dismiss, secondary paths.
  secondary,
}

/// The one button in the system. No strident colour in any mode; radius from
/// the `affordance` token; ≥48dp tall (DESIGN_BRIEF §5).
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final scheme = Theme.of(context).colorScheme;
    final isPrimary = variant == AppButtonVariant.primary;

    final radius = BorderRadius.circular(tokens.radii.affordance);
    final labelStyle = tokens.text.chip.copyWith(
      fontSize: 14,
      color: isPrimary ? scheme.onPrimary : scheme.onSurface,
    );

    return Material(
      color: isPrimary ? scheme.primary : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: isPrimary
            ? BorderSide.none
            : BorderSide(color: tokens.colors.line, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 88),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: tokens.spacing.xl),
          child: Text(label, style: labelStyle),
        ),
      ),
    );
  }
}
