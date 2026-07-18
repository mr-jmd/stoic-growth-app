import 'package:flutter/material.dart';

import '../tokens/stoic_tokens.dart';

/// The always-visible calm access: a full-width quiet band that sits between
/// the content and the tab bar on every tab. One tap opens the crisis flow.
/// Never red, never an alarm — a "charco de calma" with the grounding glyph.
class CalmBand extends StatelessWidget {
  const CalmBand({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final c = tokens.colors;

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: c.crisisSurface,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: c.line, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomPaint(
                  size: const Size(18, 18),
                  painter: _GroundingGlyphPainter(color: c.crisisStroke),
                ),
                SizedBox(width: tokens.spacing.md),
                Text(
                  label,
                  style: tokens.text.chip.copyWith(color: c.crisisStroke),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Three concentric circles — grounding, not warning.
class _GroundingGlyphPainter extends CustomPainter {
  const _GroundingGlyphPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = color;
    final r = size.shortestSide / 2;
    canvas.drawCircle(center, r, paint);
    canvas.drawCircle(center, r * 0.62, paint..color = color.withValues(alpha: 0.7));
    canvas.drawCircle(center, r * 0.26, paint..color = color.withValues(alpha: 0.45));
  }

  @override
  bool shouldRepaint(covariant _GroundingGlyphPainter oldDelegate) =>
      oldDelegate.color != color;
}
