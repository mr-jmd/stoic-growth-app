import 'package:flutter/material.dart';

import '../../../shared/virtue.dart';
import '../../../shared/virtue_l10n.dart';
import '../../../shared/virtue_progress_state.dart';
import '../../l10n/app_localizations.dart';
import '../tokens/stoic_tokens.dart';

/// The non-gamified progress element (DESIGN_BRIEF §3 / §5): a stone slab whose
/// **material** expresses progress — never a number, bar or percentage. The
/// gradient is chosen by (virtue, state) from tokens and already carries the
/// light/dark direction; this widget just renders it.
///
/// Fixed geometry (both modes): 104px tall, radius 10, padding 15.
class VirtueIndicator extends StatelessWidget {
  const VirtueIndicator({
    super.key,
    required this.virtue,
    required this.state,
  });

  final Virtue virtue;
  final VirtueProgressState state;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final l = AppLocalizations.of(context);
    final slab = tokens.virtueSlab(virtue, state);

    return Container(
      height: 104,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: slab.gradient,
        borderRadius: BorderRadius.circular(tokens.radii.tile),
        border: Border(
          top: BorderSide(color: tokens.elevation.innerHighlight, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            virtue.label(l),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tokens.text.virtueName.copyWith(color: slab.onColor),
          ),
          Text(
            state.label(l),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tokens.text.chip.copyWith(
              color: slab.onColor.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
