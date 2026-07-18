import 'package:flutter/material.dart';

import '../tokens/stoic_tokens.dart';

enum AppCardVariant {
  /// Raised paper: card surface + hairline + soft warm shadow.
  paper,

  /// Quiet inset: bone fill, hairline only, no shadow. For secondary tiles.
  inset,
}

/// The elevated surface of the system. Light: paper floating on marble (soft
/// two-layer warm shadow). Dark: the surface luminance step + hairline + inner
/// highlight carry the separation. All from tokens — no `if (isDark)` here.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.variant = AppCardVariant.paper,
    this.onTap,
    this.padding,
  });

  final Widget child;
  final AppCardVariant variant;

  /// When set, the whole card is tappable (ink-rippled).
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final scheme = Theme.of(context).colorScheme;
    final elevation = tokens.elevation;
    final isPaper = variant == AppCardVariant.paper;
    final radius = BorderRadius.circular(tokens.radii.card);

    final inner = DecoratedBox(
      // 1px top inner-highlight (marble/basalt sheen).
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border(
          top: BorderSide(color: elevation.innerHighlight, width: 1),
        ),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(tokens.spacing.xl),
        child: child,
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: isPaper ? scheme.surfaceContainer : tokens.colors.bone,
        borderRadius: radius,
        border: elevation.border,
        boxShadow: isPaper ? elevation.card : null,
      ),
      clipBehavior: onTap == null ? Clip.none : Clip.antiAlias,
      child: onTap == null
          ? inner
          : Material(
              color: Colors.transparent,
              child: InkWell(onTap: onTap, borderRadius: radius, child: inner),
            ),
    );
  }
}
