import 'package:flutter/material.dart';

import '../tokens/stoic_tokens.dart';

/// The consistency "stele": a giant editorial numeral flanked by two circular
/// stepper buttons. The count renders as a plain `Text('$count')` (digits only)
/// and stays directly editable — tapping the numeral opens the caller's edit
/// dialog. Tooltips are supplied by the caller (they carry l10n copy and are
/// also how tests find the buttons).
class StepperControl extends StatelessWidget {
  const StepperControl({
    super.key,
    required this.count,
    required this.onIncrement,
    required this.onDecrement,
    required this.incrementTooltip,
    required this.decrementTooltip,
    this.onTapCount,
    this.caption,
  });

  final int count;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final String incrementTooltip;
  final String decrementTooltip;

  /// Tap on the numeral itself (arbitrary edit).
  final VoidCallback? onTapCount;

  /// Small label under the numeral ("días de constancia").
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _RoundStep(
          icon: Icons.remove,
          tooltip: decrementTooltip,
          onPressed: onDecrement,
        ),
        Expanded(
          child: InkWell(
            onTap: onTapCount,
            borderRadius: BorderRadius.circular(tokens.radii.tile),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: tokens.spacing.sm),
              child: Column(
                children: [
                  Text('$count', style: tokens.text.numeral),
                  if (caption != null) ...[
                    SizedBox(height: tokens.spacing.xs),
                    Text(caption!, style: tokens.text.caption),
                  ],
                ],
              ),
            ),
          ),
        ),
        _RoundStep(
          icon: Icons.add,
          tooltip: incrementTooltip,
          onPressed: onIncrement,
        ),
      ],
    );
  }
}

class _RoundStep extends StatelessWidget {
  const _RoundStep({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final scheme = Theme.of(context).colorScheme;
    final enabled = onPressed != null;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: tokens.colors.bone,
        shape: CircleBorder(
          side: BorderSide(color: tokens.colors.line, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: 52,
            height: 52,
            child: Icon(
              icon,
              size: 22,
              color: enabled
                  ? scheme.onSurface
                  : tokens.colors.faint.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
