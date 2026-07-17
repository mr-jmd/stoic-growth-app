import '../core/l10n/app_localizations.dart';
import 'journal_enums.dart';
import 'qualitative_level.dart';

/// Localized display labels for journal enums. Copy lives in `app_es.arb`, never
/// hardcoded next to the enums (DESIGN_BRIEF §7). The evening tags carry the
/// exact README 10.1 wording.
extension EveningTagL10n on EveningTag {
  String label(AppLocalizations l) => switch (this) {
        EveningTag.calm => l.eveningTagCalm,
        EveningTag.reacted => l.eveningTagReacted,
        EveningTag.advanced => l.eveningTagAdvanced,
      };
}

extension QualitativeLevelL10n on QualitativeLevel {
  String label(AppLocalizations l) => switch (this) {
        QualitativeLevel.low => l.moodLevelLow,
        QualitativeLevel.medium => l.moodLevelMedium,
        QualitativeLevel.high => l.moodLevelHigh,
      };
}
