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
  });

  final Widget body;
  final Widget? bottomBar;

  /// Optional persistent crisis affordance, pinned bottom-end above the bar.
  final Widget? crisisAccess;

  @override
  Widget build(BuildContext context) {
    final c = context.stoic.colors;
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
              ? body
              : Stack(
                  children: [
                    Positioned.fill(child: body),
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
