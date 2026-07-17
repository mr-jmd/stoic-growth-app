import 'package:flutter/material.dart';

import '../../core/design_system/design_system.dart';
import 'crisis_content.dart';

/// A calm box-breathing guide: a soft circle that grows/holds/shrinks through
/// the script's phases, repeated for [BreathingScript.cycles], then calls
/// [onComplete] exactly once. Built on a single [AnimationController] — no
/// external animation package (SPRINT_PLAN). No countdown digits, no red, no
/// alarm: the pace itself is the only signal.
class BreathingTimer extends StatefulWidget {
  const BreathingTimer({
    super.key,
    required this.script,
    required this.onComplete,
  });

  final BreathingScript script;
  final VoidCallback onComplete;

  @override
  State<BreathingTimer> createState() => _BreathingTimerState();
}

class _BreathingTimerState extends State<BreathingTimer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _phaseIndex = 0;
  int _cycle = 0;
  bool _finished = false;

  double _fromScale = 0;
  double _toScale = 0;

  List<BreathingPhase> get _phases => widget.script.phases;
  BreathingPhase get _phase => _phases[_phaseIndex];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)
      ..addStatusListener(_onStatus);
    // Rest at the last phase's scale so the first inhale grows from there.
    _fromScale = _phases.last.scale;
    _startPhase();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startPhase() {
    _fromScale = _toScale == 0 ? _fromScale : _toScale;
    _toScale = _phase.scale;
    _controller
      ..duration = Duration(milliseconds: (_phase.seconds * 1000).clamp(1, 60000))
      ..reset()
      ..forward();
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _finished) return;
    // Advance to the next phase, wrapping into the next cycle.
    var nextPhase = _phaseIndex + 1;
    var nextCycle = _cycle;
    if (nextPhase >= _phases.length) {
      nextPhase = 0;
      nextCycle += 1;
    }
    if (nextCycle >= widget.script.cycles) {
      _finished = true;
      widget.onComplete();
      return;
    }
    setState(() {
      _phaseIndex = nextPhase;
      _cycle = nextCycle;
    });
    _startPhase();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.stoic;
    final c = tokens.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 220,
          width: 220,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = Curves.easeInOut.transform(_controller.value);
              final scale = _fromScale + (_toScale - _fromScale) * t;
              return Center(
                child: Container(
                  width: 220 * scale,
                  height: 220 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.crisisSurface,
                    border: Border.all(color: c.crisisStroke, width: 1.4),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: tokens.spacing.xl),
        // The phase label is the only text — a gentle cue, not a stopwatch.
        Text(
          _phase.label,
          style: tokens.text.promptDisplay.copyWith(color: c.crisisStroke),
        ),
      ],
    );
  }
}
