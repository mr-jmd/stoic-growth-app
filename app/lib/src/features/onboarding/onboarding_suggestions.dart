import '../../core/l10n/app_localizations.dart';
import '../../shared/virtue.dart';

/// Curated starter habits offered during onboarding, grouped by virtue. Copy is
/// deliberately neutral — no clinical/pathologising language ("adicción",
/// "trastorno", "recuperación"). Labels resolve through l10n; the enum key is
/// the stable identity used for selection state.
enum HabitSuggestionKey {
  screenTime,
  consumption,
  move,
  discomfort,
  read,
  reflect,
  kindness,
  keepWord,
}

class HabitSuggestion {
  const HabitSuggestion(this.key, this.virtue);

  final HabitSuggestionKey key;
  final Virtue virtue;

  String label(AppLocalizations l) => switch (key) {
        HabitSuggestionKey.screenTime => l.suggestionScreenTime,
        HabitSuggestionKey.consumption => l.suggestionConsumption,
        HabitSuggestionKey.move => l.suggestionMove,
        HabitSuggestionKey.discomfort => l.suggestionDiscomfort,
        HabitSuggestionKey.read => l.suggestionRead,
        HabitSuggestionKey.reflect => l.suggestionReflect,
        HabitSuggestionKey.kindness => l.suggestionKindness,
        HabitSuggestionKey.keepWord => l.suggestionKeepWord,
      };
}

/// One or two suggestions per cardinal virtue.
const List<HabitSuggestion> kHabitSuggestions = [
  HabitSuggestion(HabitSuggestionKey.screenTime, Virtue.templanza),
  HabitSuggestion(HabitSuggestionKey.consumption, Virtue.templanza),
  HabitSuggestion(HabitSuggestionKey.move, Virtue.coraje),
  HabitSuggestion(HabitSuggestionKey.discomfort, Virtue.coraje),
  HabitSuggestion(HabitSuggestionKey.read, Virtue.sabiduria),
  HabitSuggestion(HabitSuggestionKey.reflect, Virtue.sabiduria),
  HabitSuggestion(HabitSuggestionKey.kindness, Virtue.justicia),
  HabitSuggestion(HabitSuggestionKey.keepWord, Virtue.justicia),
];
