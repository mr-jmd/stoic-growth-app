/// Local-calendar-day helpers, shared app-wide.
///
/// The app's "day" key is always **local midnight** — journal upserts, the
/// daily quote, and the one-success-check-in-per-day rule all agree on it.
library;

/// Truncates [dt] to local midnight — the app-wide "day" key.
DateTime dayOf(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// Whether two instants fall on the same local calendar day.
bool isSameLocalDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
