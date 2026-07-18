import 'package:flutter/widgets.dart';

/// GlobalKeys for the guided tour's spotlight targets. Screens attach them via
/// [KeyedSubtree]; the overlay measures the rendered rects after layout. They
/// are plain top-level finals so the same key survives branch rebuilds inside
/// the shell's IndexedStack.
final GlobalKey tourVirtueGridKey = GlobalKey(debugLabel: 'tour.virtueGrid');
final GlobalKey tourQuoteHeroKey = GlobalKey(debugLabel: 'tour.quoteHero');
final GlobalKey tourHabitsAddKey = GlobalKey(debugLabel: 'tour.habitsAdd');
final GlobalKey tourJournalMomentsKey =
    GlobalKey(debugLabel: 'tour.journalMoments');
final GlobalKey tourCalmBandKey = GlobalKey(debugLabel: 'tour.calmBand');
