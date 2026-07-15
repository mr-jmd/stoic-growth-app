import 'package:flutter/material.dart';

import '../tokens/stoic_tokens.dart';

/// Persistent entry to crisis mode (DESIGN_BRIEF §5). A 44px slab, radius 14,
/// with a calm grounding glyph (concentric circles). **Never red, never alarm,
/// in any mode.** In dark it reads as a slightly cooler/brighter "charco de
/// calma" against the warm-dark surround — an invitation into a calm place,
/// not a status indicator.
class CrisisAccessButton extends StatelessWidget {
  const CrisisAccessButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final c = tokens.colors;
    final radius = BorderRadius.circular(tokens.radii.affordance);

    return Material(
      color: c.crisisSurface,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.spacing.md,
            vertical: tokens.spacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CustomPaint(
                  painter: _GroundingGlyphPainter(c.crisisStroke),
                ),
              ),
              SizedBox(width: tokens.spacing.sm),
              Text(
                label,
                style: tokens.text.chip.copyWith(color: c.crisisStroke),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroundingGlyphPainter extends CustomPainter {
  const _GroundingGlyphPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = color;
    final maxR = size.width / 2;
    for (final r in [maxR, maxR * 0.62, maxR * 0.26]) {
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(_GroundingGlyphPainter oldDelegate) =>
      oldDelegate.color != color;
}
