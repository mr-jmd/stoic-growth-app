import 'package:flutter/material.dart';

import '../tokens/stoic_tokens.dart';

/// Base scaffold: a warm radial `appBg` gradient (never a flat colour),
/// safe areas, and slots for a bottom bar and a persistent crisis access
/// (DESIGN_BRIEF §5). Reads the gradient from tokens, so it flips between
/// "mármol" and "basalto" with the theme, no branch here.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.bottomBar,
    this.crisisAccess,
    this.onBack,
  });

  final Widget body;
  final Widget? bottomBar;

  /// Optional persistent crisis affordance, pinned bottom-end above the bar.
  final Widget? crisisAccess;

  /// When set, a back control is shown at the top-start. Pushed screens without
  /// their own back affordance pass this (there's no AppBar) so they're never
  /// dead-ends on platforms without a system back button.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final c = context.stoic.colors;

    Widget content = body;
    if (onBack != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: context.stoic.spacing.sm,
              top: context.stoic.spacing.sm,
            ),
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
              color: c.faint,
            ),
          ),
          Expanded(child: body),
        ],
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.6),
          radius: 1.3,
          colors: [c.appBgInner, c.appBgOuter],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: bottomBar,
        body: SafeArea(
          child: crisisAccess == null
              ? content
              : Stack(
                  children: [
                    Positioned.fill(child: content),
                    Positioned(
                      right: context.stoic.spacing.lg,
                      bottom: context.stoic.spacing.lg,
                      child: crisisAccess!,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
