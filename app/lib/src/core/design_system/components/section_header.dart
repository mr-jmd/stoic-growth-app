import 'package:flutter/material.dart';

import '../tokens/stoic_tokens.dart';

/// An editorial section header: uppercase eyebrow + hairline rule, with an
/// optional quiet trailing action ("Ver hábitos").
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.eyebrow,
    this.trailingLabel,
    this.onTrailing,
  });

  final String eyebrow;
  final String? trailingLabel;
  final VoidCallback? onTrailing;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final c = tokens.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(eyebrow.toUpperCase(), style: tokens.text.eyebrow),
        SizedBox(width: tokens.spacing.md),
        Expanded(child: Container(height: 1, color: c.line)),
        if (trailingLabel != null) ...[
          SizedBox(width: tokens.spacing.md),
          InkWell(
            onTap: onTrailing,
            borderRadius: BorderRadius.circular(tokens.radii.chip),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Align(
                widthFactor: 1,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: tokens.spacing.sm),
                  child: Text(
                    trailingLabel!,
                    style: tokens.text.bodyStrong.copyWith(
                      fontSize: 13.5,
                      color: c.onAccentSoft,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
