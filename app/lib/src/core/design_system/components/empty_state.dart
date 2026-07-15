import 'package:flutter/material.dart';

import '../tokens/stoic_tokens.dart';
import 'app_button.dart';

/// Warm empty state (DESIGN_BRIEF §5). Used e.g. for "0 active habits" (the
/// post-archive case, distinct from onboarding). Warm-dark in dark mode — never
/// cold/void. Copy is calm, no exclamation, no clinical language.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.icon,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.spa_outlined,
              size: 40,
              color: tokens.colors.faint,
            ),
            SizedBox(height: tokens.spacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: tokens.text.promptDisplay,
            ),
            SizedBox(height: tokens.spacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: tokens.text.body.copyWith(color: scheme.onSurfaceVariant),
            ),
            if (actionLabel != null) ...[
              SizedBox(height: tokens.spacing.xl),
              AppButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
