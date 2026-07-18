import 'package:flutter/widgets.dart';

import '../../core/l10n/app_localizations.dart';
import 'tour_targets.dart';

/// One stop of the guided tour: which shell branch to be on, what to spotlight
/// (null → centered card, no cutout), and its copy.
class TourStep {
  const TourStep({
    required this.branchIndex,
    required this.title,
    required this.body,
    this.targetKey,
  });

  final int branchIndex;
  final GlobalKey? targetKey;
  final String Function(AppLocalizations) title;
  final String Function(AppLocalizations) body;
}

/// The tour, in order. It crosses tabs on purpose — the point is showing the
/// real app where things actually happen.
final List<TourStep> kTourSteps = [
  TourStep(
    branchIndex: 0,
    targetKey: tourVirtueGridKey,
    title: (l) => l.tourStepVirtuesTitle,
    body: (l) => l.tourStepVirtuesBody,
  ),
  TourStep(
    branchIndex: 0,
    targetKey: tourQuoteHeroKey,
    title: (l) => l.tourStepQuoteTitle,
    body: (l) => l.tourStepQuoteBody,
  ),
  TourStep(
    branchIndex: 1,
    targetKey: tourHabitsAddKey,
    title: (l) => l.tourStepHabitsTitle,
    body: (l) => l.tourStepHabitsBody,
  ),
  TourStep(
    branchIndex: 2,
    targetKey: tourJournalMomentsKey,
    title: (l) => l.tourStepJournalTitle,
    body: (l) => l.tourStepJournalBody,
  ),
  TourStep(
    branchIndex: 2,
    targetKey: tourCalmBandKey,
    title: (l) => l.tourStepCalmTitle,
    body: (l) => l.tourStepCalmBody,
  ),
  TourStep(
    branchIndex: 0,
    title: (l) => l.tourStepDoneTitle,
    body: (l) => l.tourStepDoneBody,
  ),
];
