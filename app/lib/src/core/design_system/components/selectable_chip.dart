import 'package:flutter/material.dart';

import '../tokens/stoic_tokens.dart';

/// The workhorse selection primitive. Reused for mood/energy, evening
/// reflection chips, and virtue/habit selection — never reinvented.
///
/// Soft pill (radius from the `chip` token), warm terracotta-tinted paper when
/// selected with a fine accent stroke; the real tap target is ≥48dp.
class SelectableChip extends StatelessWidget {
  const SelectableChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final c = tokens.colors;
    final scheme = Theme.of(context).colorScheme;

    final radius = BorderRadius.circular(tokens.radii.chip);
    final textColor = selected ? c.chipSelectedText : scheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onSelected == null ? null : () => onSelected!(!selected),
        borderRadius: radius,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: 1,
            child: AnimatedContainer(
              duration: tokens.motion.fast,
              curve: tokens.motion.standard,
              padding: EdgeInsets.symmetric(
                horizontal: tokens.spacing.gap,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: selected ? c.chipSelectedFill : Colors.transparent,
                borderRadius: radius,
                border: Border.all(
                  color: selected
                      ? c.chipSelectedText.withValues(alpha: 0.45)
                      : c.line,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Text(
                label,
                style: tokens.text.chip.copyWith(color: textColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
