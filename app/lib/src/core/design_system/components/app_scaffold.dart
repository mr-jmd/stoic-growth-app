import 'package:flutter/material.dart';

import '../tokens/stoic_tokens.dart';

/// Base scaffold of "Piedra y luz": a soft vertical wash of light (brighter at
/// the top, like morning light on marble — never a flat colour), safe areas,
/// and a slot for a bottom bar. Crisis access lives in the shell's [CalmBand],
/// not here. Reads the wash from tokens, so it flips between marble and basalt
/// with the theme.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.bottomBar,
    this.onBack,
  });

  final Widget body;
  final Widget? bottomBar;

  /// When set, a back control is shown at the top-start. Pushed screens without
  /// their own back affordance pass this (there's no AppBar) so they're never
  /// dead-ends on platforms without a system back button.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final c = tokens.colors;

    Widget content = body;
    if (onBack != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: tokens.spacing.sm,
              top: tokens.spacing.sm,
            ),
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
              color: c.faint,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            ),
          ),
          Expanded(child: body),
        ],
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.appBgInner, c.appBgOuter],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: bottomBar,
        body: SafeArea(child: content),
      ),
    );
  }
}
