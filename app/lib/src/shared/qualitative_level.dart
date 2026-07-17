/// A single-tap qualitative mood/energy level (README 10.1). The user only ever
/// sees "bajo/medio/alto" — never a clinical numeric scale — but it persists as
/// its [score] in `JournalEntries.moodScore` / `energyScore`. Always optional.
enum QualitativeLevel { low, medium, high }

extension QualitativeLevelScore on QualitativeLevel {
  /// Stored value. 1..3 (never 0, so a stored score is always truthy/present).
  int get score => switch (this) {
        QualitativeLevel.low => 1,
        QualitativeLevel.medium => 2,
        QualitativeLevel.high => 3,
      };

  /// Inverse of [score] for prefill; null for a null/unknown stored value.
  static QualitativeLevel? fromScore(int? score) => switch (score) {
        1 => QualitativeLevel.low,
        2 => QualitativeLevel.medium,
        3 => QualitativeLevel.high,
        _ => null,
      };
}
