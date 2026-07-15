import 'package:flutter/material.dart';

import '../tokens/stoic_tokens.dart';

/// Elevated surface (DESIGN_BRIEF §5). Light: warm diffuse shadow. Dark: the
/// `surface → surfaceContainer` luminance step + hairline `line` + a top
/// inner-highlight carry the separation; the drop shadow is secondary. All of
/// that comes from the elevation token, so this widget has no `if (isDark)`.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final scheme = Theme.of(context).colorScheme;
    final elevation = tokens.elevation;
    final radius = BorderRadius.circular(tokens.radii.card);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: radius,
        border: elevation.border,
        boxShadow: elevation.card,
      ),
      child: DecoratedBox(
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
      ),
    );
  }
}
