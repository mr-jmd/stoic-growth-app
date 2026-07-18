import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_localizations.dart';
import 'tour_controller.dart';
import 'tour_steps.dart';

/// The guided-tour layer: dims the real app and spotlights one zone per step
/// with an animated soft-edged cutout plus an explanation card. Lives above the
/// whole shell (nav bar and calm band included) and switches branches itself,
/// so the user sees their actual screens where things happen.
///
/// Every step is skippable; skipping or finishing persists the seen-flag. If a
/// target can't be measured the card centers itself without a cutout — the
/// tour degrades, it never crashes or hangs.
class TourOverlay extends ConsumerStatefulWidget {
  const TourOverlay({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<TourOverlay> createState() => _TourOverlayState();
}

class _TourOverlayState extends ConsumerState<TourOverlay> {
  Rect? _targetRect;
  int? _measuredStep;
  int _retriesLeft = 0;

  static const int _maxMeasureRetries = 8;

  @override
  Widget build(BuildContext context) {
    final stepIndex = ref.watch(tourControllerProvider);
    if (stepIndex == null) return const SizedBox.shrink();
    final step = kTourSteps[stepIndex];

    // React to step changes (build is where we can safely read the provider).
    if (_measuredStep != stepIndex) {
      _measuredStep = stepIndex;
      _targetRect = null;
      _retriesLeft = _maxMeasureRetries;
      _syncToStep();
    }

    final tokens = context.stoic;
    final l = AppLocalizations.of(context);
    final isLast = stepIndex >= kTourSteps.length - 1;

    return Positioned.fill(
      child: Stack(
        children: [
          // The scrim with the animated spotlight cutout. Absorbs every tap
          // (the card's buttons are the only way forward — crisis stays one
          // "Saltar" away).
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: _targetRect == null
                  // No measured target (yet) — plain scrim, no cutout.
                  ? CustomPaint(
                      painter: _SpotlightPainter(
                        cutout: null,
                        scrim: Theme.of(context)
                            .colorScheme
                            .scrim
                            .withValues(alpha: 0.55),
                        radius: tokens.radii.tile,
                      ),
                    )
                  : TweenAnimationBuilder<Rect?>(
                      tween: RectTween(end: _targetRect),
                      duration: tokens.motion.base,
                      curve: tokens.motion.emphasized,
                      builder: (context, rect, _) => CustomPaint(
                        painter: _SpotlightPainter(
                          cutout: rect,
                          scrim: Theme.of(context)
                              .colorScheme
                              .scrim
                              .withValues(alpha: 0.55),
                          radius: tokens.radii.tile,
                        ),
                      ),
                    ),
            ),
          ),
          _StepCard(
            key: ValueKey(stepIndex),
            targetRect: _targetRect,
            title: step.title(l),
            body: step.body(l),
            skipLabel: l.tourSkip,
            nextLabel: isLast ? l.tourDone : l.tourNext,
            onSkip: () => ref.read(tourControllerProvider.notifier).skip(),
            onNext: () => ref.read(tourControllerProvider.notifier).next(),
          ),
        ],
      ),
    );
  }

  /// Ensures the shell shows the step's branch, then measures its target after
  /// layout (retrying a few frames — a freshly switched branch needs a pass).
  /// Everything runs post-frame: switching branches or setState during build
  /// is not allowed.
  void _syncToStep() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final stepIndex = ref.read(tourControllerProvider);
      if (stepIndex == null) return;
      final step = kTourSteps[stepIndex];

      if (widget.navigationShell.currentIndex != step.branchIndex) {
        widget.navigationShell.goBranch(step.branchIndex);
        if (_retriesLeft > 0) {
          _retriesLeft--;
          _syncToStep(); // measure once the new branch has laid out
        }
        return;
      }

      final key = step.targetKey;
      if (key == null) {
        setState(() => _targetRect = null);
        return;
      }
      final box = key.currentContext?.findRenderObject() as RenderBox?;
      final overlayBox = context.findRenderObject() as RenderBox?;
      if (box == null || overlayBox == null || !box.hasSize) {
        if (_retriesLeft > 0) {
          _retriesLeft--;
          _syncToStep();
        }
        // Retries exhausted → keep _targetRect null (centered card, no cutout).
        return;
      }
      final topLeft = box.localToGlobal(Offset.zero, ancestor: overlayBox);
      setState(() {
        _targetRect = (topLeft & box.size).inflate(8);
      });
    });
  }
}

/// Dimmed layer with a soft-edged rounded-rect hole.
class _SpotlightPainter extends CustomPainter {
  const _SpotlightPainter({
    required this.cutout,
    required this.scrim,
    required this.radius,
  });

  final Rect? cutout;
  final Color scrim;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final screen = Path()..addRect(Offset.zero & size);
    final paint = Paint()..color = scrim;

    final hole = cutout;
    if (hole == null) {
      canvas.drawPath(screen, paint);
      return;
    }

    final rrect = RRect.fromRectAndRadius(hole, Radius.circular(radius));
    final holePath = Path()..addRRect(rrect);
    canvas.drawPath(
      Path.combine(PathOperation.difference, screen, holePath),
      paint,
    );
    // A soft luminous edge around the cutout, so the spotlight reads as light,
    // not as a hard stencil.
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = scrim.withValues(alpha: 0.9)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) =>
      oldDelegate.cutout != cutout || oldDelegate.scrim != scrim;
}

/// The explanation card, placed under the spotlight when there's room, above
/// it otherwise, centered when there's no target. Fades up on each step.
class _StepCard extends StatelessWidget {
  const _StepCard({
    super.key,
    required this.targetRect,
    required this.title,
    required this.body,
    required this.skipLabel,
    required this.nextLabel,
    required this.onSkip,
    required this.onNext,
  });

  final Rect? targetRect;
  final String title;
  final String body;
  final String skipLabel;
  final String nextLabel;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;

    final card = TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: tokens.motion.base,
      curve: tokens.motion.standard,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * 12), child: child),
      ),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: tokens.text.title),
            SizedBox(height: tokens.spacing.sm),
            Text(body, style: tokens.text.body),
            SizedBox(height: tokens.spacing.gap),
            Row(
              children: [
                TextButton(onPressed: onSkip, child: Text(skipLabel)),
                const Spacer(),
                AppButton(label: nextLabel, onPressed: onNext),
              ],
            ),
          ],
        ),
      ),
    );

    final rect = targetRect;
    if (rect == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing.page),
          child: card,
        ),
      );
    }

    // Below the spotlight when there's room in the lower half, else above it.
    final size = MediaQuery.sizeOf(context);
    final placeBelow = rect.center.dy < size.height / 2;
    return Positioned(
      left: tokens.spacing.page,
      right: tokens.spacing.page,
      top: placeBelow ? rect.bottom + tokens.spacing.lg : null,
      bottom: placeBelow ? null : (size.height - rect.top) + tokens.spacing.lg,
      child: card,
    );
  }
}
