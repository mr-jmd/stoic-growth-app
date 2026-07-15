/// The four Stoic cardinal virtues the product is organised around.
///
/// This is a **fixed** enum of exactly four values — it is core to the product
/// identity and is not user-configurable (see SPRINT_PLAN "Seams para Fase 2").
/// It lives here in `shared/` so both the design system (Sprint 1, virtue
/// accents / [VirtueIndicator]) and the data layer (Sprint 2, Drift type
/// converter on `Habits.virtue`) reference the **same** enum without either
/// owning the other.
///
/// Display labels are never hardcoded next to the enum — they resolve through
/// the localization layer (`app_es.arb`, see `AppLocalizations`).
enum Virtue { templanza, coraje, sabiduria, justicia }
