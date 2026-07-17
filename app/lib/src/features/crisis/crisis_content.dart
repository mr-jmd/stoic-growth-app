import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where the bundled crisis content lives (declared in pubspec `assets:`).
const String kCrisisContentAsset = 'assets/content/crisis_content.json';

/// Immutable, parsed-once crisis content (README 10.2). Loaded from a bundled
/// JSON asset — deliberately **out of Drift** (build-time content, not user
/// data) and **never fetched** (the whole flow must work in airplane mode).
@immutable
class CrisisContent {
  const CrisisContent({
    required this.affirmation,
    required this.breathing,
    required this.socraticPrompts,
  });

  /// A calm reframing statement, delivered as an affirmation — never a question.
  final String affirmation;
  final BreathingScript breathing;

  /// Offered only *after* the breathing relief, as a dismissible invitation.
  final List<String> socraticPrompts;

  factory CrisisContent.fromJson(Map<String, dynamic> json) => CrisisContent(
        affirmation: json['affirmation'] as String,
        breathing:
            BreathingScript.fromJson(json['breathing'] as Map<String, dynamic>),
        socraticPrompts: (json['socraticPrompts'] as List<dynamic>)
            .cast<String>()
            .toList(growable: false),
      );
}

/// A simple box-breathing script: a fixed list of phases repeated [cycles]
/// times. Timing/labels are data so they can be tuned without code.
@immutable
class BreathingScript {
  const BreathingScript({required this.cycles, required this.phases});

  final int cycles;
  final List<BreathingPhase> phases;

  factory BreathingScript.fromJson(Map<String, dynamic> json) => BreathingScript(
        cycles: json['cycles'] as int,
        phases: (json['phases'] as List<dynamic>)
            .map((p) => BreathingPhase.fromJson(p as Map<String, dynamic>))
            .toList(growable: false),
      );
}

/// One breathing phase: a [label] shown to the user, a [seconds] duration, and
/// the target circle [scale] the guide animates toward (a "hold" phase simply
/// shares the previous phase's scale, so nothing moves).
@immutable
class BreathingPhase {
  const BreathingPhase({
    required this.label,
    required this.seconds,
    required this.scale,
  });

  final String label;
  final int seconds;
  final double scale;

  factory BreathingPhase.fromJson(Map<String, dynamic> json) => BreathingPhase(
        label: json['label'] as String,
        seconds: json['seconds'] as int,
        scale: (json['scale'] as num).toDouble(),
      );
}

/// Loads + parses the crisis content once. Overridable in tests with a fixed
/// [CrisisContent] so the flow tests don't depend on asset-load timing.
final crisisContentProvider = FutureProvider<CrisisContent>((ref) async {
  final raw = await rootBundle.loadString(kCrisisContentAsset);
  return CrisisContent.fromJson(jsonDecode(raw) as Map<String, dynamic>);
});
