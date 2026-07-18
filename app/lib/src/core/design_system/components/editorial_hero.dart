import 'package:flutter/material.dart';

import '../tokens/stoic_tokens.dart';

/// The editorial hero of the home page: the daily quote set full-width like a
/// magazine opening — no card box. Eyebrow, large Fraunces quote with a hanging
/// opening mark, then a short accent rule and the attribution.
class EditorialHero extends StatelessWidget {
  const EditorialHero({
    super.key,
    required this.eyebrow,
    required this.quote,
    required this.attribution,
    this.footnote,
  });

  final String eyebrow;
  final String quote;
  final String attribution;

  /// Optional reflection question set under the attribution.
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(eyebrow.toUpperCase(), style: tokens.text.eyebrow),
        SizedBox(height: tokens.spacing.gap),
        Text('«$quote»', style: tokens.text.quote),
        SizedBox(height: tokens.spacing.lg),
        Row(
          children: [
            Container(
              width: 28,
              height: 2,
              color: scheme.primary.withValues(alpha: 0.75),
            ),
            SizedBox(width: tokens.spacing.md),
            Text(attribution, style: tokens.text.attribution),
          ],
        ),
        if (footnote != null) ...[
          SizedBox(height: tokens.spacing.gap),
          Text(footnote!, style: tokens.text.reflection),
        ],
      ],
    );
  }
}
