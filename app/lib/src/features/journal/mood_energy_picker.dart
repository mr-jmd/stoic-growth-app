import 'package:flutter/material.dart';

import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import '../../shared/journal_l10n.dart';
import '../../shared/qualitative_level.dart';

/// Optional single-tap mood/energy selector, shared by the morning and evening
/// screens (README 10.1). Reuses [SelectableChip] — never a numeric slider. It
/// is always optional: tapping the selected level again clears it back to null.
class MoodEnergyPicker extends StatelessWidget {
  const MoodEnergyPicker({
    super.key,
    required this.question,
    required this.selected,
    required this.onChanged,
  });

  final String question;
  final QualitativeLevel? selected;
  final ValueChanged<QualitativeLevel?> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final l = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(question, style: tokens.text.eyebrow),
            SizedBox(width: tokens.spacing.sm),
            Text(
              l.journalOptionalHint,
              style: tokens.text.eyebrowSub,
            ),
          ],
        ),
        SizedBox(height: tokens.spacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final level in QualitativeLevel.values)
              SelectableChip(
                label: level.label(l),
                selected: selected == level,
                // Re-tapping the current level clears it (stays optional).
                onSelected: (_) =>
                    onChanged(selected == level ? null : level),
              ),
          ],
        ),
      ],
    );
  }
}
