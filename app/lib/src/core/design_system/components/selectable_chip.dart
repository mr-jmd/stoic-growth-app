import 'package:flutter/material.dart';

import '../tokens/stoic_tokens.dart';

/// The workhorse selection primitive (DESIGN_BRIEF §5). Reused for mood/energy,
/// evening reflection chips, and virtue/habit selection — never reinvented.
///
/// Visual is compact (radius 7, ~6–7 × 12 padding) but the real tap target is
/// ≥48dp so it stays comfortable to hit.
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
              duration: const Duration(milliseconds: 120),
              padding: EdgeInsets.symmetric(
                horizontal: tokens.spacing.md,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: selected ? c.chipSelectedFill : Colors.transparent,
                borderRadius: radius,
                border: Border.all(
                  color: selected ? Colors.transparent : c.line,
                  width: 1,
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
