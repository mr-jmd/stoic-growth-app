// Journal-domain enums. Stored in Drift as `textEnum` (the enum `.name`), so
// renaming a value is a schema migration — pick stable identifiers. Display
// copy lives in the localization layer (Sprint 5), never next to the enum.

/// Which of the two daily entries this is (README 4.1 / 10.1).
enum JournalType { morning, evening }

/// How the entry text was captured. `voice` degrades to `typed` when on-device
/// speech isn't available offline (Sprint 5) — the enum still records intent.
enum JournalInputMethod { typed, voice }

/// The three fixed, pre-written evening reflection chips (README 10.1). Exact
/// user-facing copy is finalized in Sprint 5; these are the stable keys behind
/// `JournalEntryTags.tag`. The morning entry does not use tags.
enum EveningTag { calm, reacted, advanced }
