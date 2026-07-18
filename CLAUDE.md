# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project state

The **MVP (Fase 1) is fully built and verified** (analyze clean, full test suite green, debug APK builds). Documentation of record:

- `docs/ARCHITECTURE.md` — the technical architecture **in use** (stack, layers, data model, invariants, testing). Read this first.
- `docs/features/` — one doc per MVP feature (onboarding, habits, streaks/relapse, journal+voice, crisis, dashboard), with flow, data and product rules.
- `docs/SPRINT_PLAN.md` — historical record of the 8-sprint build, plus the **package-version rationale** (why `riverpod_lint` is absent, why `drift_dev schema dump` is unusable, etc.) and the Fase 2 seams.
- `README.md` (Spanish) — the product proposal / vision, including Fase 2+ (AI Interlocutor, backend sync, cohorts) which does **not** exist in code.

**The visual identity is "Piedra y luz"** (July 2026 full UI redesign, user-approved direction): warm Mediterranean minimalism — luminous marble/sand light mode, warm basalt dark mode (never pure black), near-black warm ink, **one accent (terracotta)**, and editorial type (vendored OFL variable fonts: **Fraunces** display with opsz pinned per size, **Instrument Sans** body). Virtues are near-monochrome undertone shifts of stone, not four hues. Navigation is a `StatefulShellRoute.indexedStack` with three tabs (Hoy `/`, Hábitos `/habits`, Diario `/journal` — a hub screen), an always-visible `CalmBand` (→ `/crisis`) above the `AppNavBar` on every tab, and detail/form/entry/crisis routes pushed on the root navigator (full-screen over the shell). Feature code reads all visuals through the theme (`context.stoic` tokens + `ColorScheme` + component themes like `InputDecorationTheme`), never hardcoded values — `tokens/palette.dart` is the only file allowed `Color(0x…)` literals (grep-audited).

Remaining owed item: full-journey QA on a physical device in airplane mode (voice dictation itself is already confirmed working on device). iOS release also still needs the `permission_handler` Podfile macro (`PERMISSION_MICROPHONE=1`).

The repo name `stoic-growth-app` is a placeholder — **"Andamio"** is the working name ("Virtude" is the backup; see README section 12).

## Commands

All Flutter commands run from `app/`. The Flutter SDK is pinned via **FVM** (`.fvmrc` → `3.44.6`); always prefix with `fvm`.

```bash
cd app

fvm flutter pub get
fvm dart run build_runner build          # regenerate Drift/Riverpod codegen after touching @DriftDatabase/@riverpod code
fvm flutter gen-l10n                     # regenerate AppLocalizations after editing lib/src/core/l10n/app_es.arb
fvm flutter analyze
fvm flutter test                         # full suite
fvm flutter test test/features/journal_flow_test.dart   # single test file
fvm flutter run
fvm flutter build apk --debug            # headless native-deps sanity check, no device needed
fvm flutter build ios                    # requires macOS/Xcode
```

No CI config, no desktop platforms (Android/iOS only), no lint/format scripts beyond standard Flutter tooling.

## Architecture (summary — details in docs/ARCHITECTURE.md)

Flutter + Riverpod (3.x, annotation/generator) + GoRouter + Drift (SQLite), feature-first under `lib/src/{core,features,shared}`. Local-first: Drift on-device is the source of truth; there is no backend, account, or auth.

Conventions that aren't obvious from any single file:

- **Repositories** live in `core/database/repositories/` (data layer, not `features/`), exposed via `@riverpod` providers over `appDatabaseProvider`. **No abstract interfaces** — single implementation, tests inject `AppDatabase.forTesting(NativeDatabase.memory())`. The one deliberate exception is the `Dictation` seam (`features/journal/speech/`), because the native speech plugin can't run headlessly.
- **Manual (non-generated) providers for Drift-entity streams** (`activeHabitsProvider`, `habitByIdProvider`, `habitCheckInsProvider`): riverpod_generator can't emit a drift-generated return type. Use manual providers whenever the return type comes from a Drift `part` file.
- **Composite writes are transactional**: relapse = check-in + `RelapseEvents` row + streak reset in one `db.transaction`; journal save = entry + tags with upsert on the unique `(date, type)` index. `HabitCheckIns`/`RelapseEvents` are **append-only history** — never deleted or mutated by a streak reset.
- **Onboarding gate**: the router redirect **and** its `refreshListenable` must read the *same* `onboardingCompletedProvider` (persisted flag, never the habit count). Two independent DB streams here caused a redirect race in the past. `/crisis` is exempt from the gate. `/habits/new` is declared before `/habits/:id` so "new" isn't captured as an id.
- **Static content** (crisis script, daily quotes) is bundled JSON in `assets/content/` loaded via `rootBundle` — out of Drift, never fetched. `pickQuoteForDate` is a pure date-seeded pick; `VirtueProgressCalculator.fromHabits` is a pure aggregation function — keep such logic widget-independent.
- **i18n**: every user-facing string goes through `AppLocalizations` (single `app_es.arb`) — no literals. Domain enums are stored as `textEnum` (`.name`); their display copy lives in l10n / `shared/journal_l10n.dart`.

## Hard product rules (red lines)

Enforced project-wide; some are asserted by tests (`test/core/dashboard_logic_test.dart`):

- Never gate streaks behind payment, never ads, never aggressive push, no login/auth route, **100% offline** (test guard: `test/support/no_network_http_overrides.dart`). The only network exception is optional voice dictation via the system recognizer — it must never block completing an entry.
- **Never add `google_fonts`** (runtime fetch breaks the offline invariant) — fonts are vendored OFL variable fonts in `app/assets/fonts/` (Fraunces + Instrument Sans).
- **Relapse copy/visuals**: no red (`scheme.error` is reserved for real form errors), no "you broke your streak" framing, no exclamation marks, no gamification. A relapse is `VirtueProgressState.enReposo` ("resting stone"). The streak counter is directly user-editable — a reset is a default, never locked.
- **One success check-in per local calendar day** (`recordCheckIn` is idempotent for same-day successes; button shows "Registrado hoy"). Relapses are never limited; manual streak edit stays free. Day helper: `shared/dates.dart`. **No cap on active habits** (removed 2026-07 — "start small" is onboarding copy only). **Archiving is two deliberate steps** (⋯ menu → confirm dialog), never a single tap.
- **Crisis flow**: relief (breathing) always comes **before** any question — enforced structurally (the socratic widget is absent from the tree until relief completes), not just visually. The "estoy bien ahora" exit exists in every state.
- **Journal is low-friction by default**: chips/one-tap first; free text is opt-in and its `TextField` is absent from the tree until requested — never expanded by default.

## Dependency constraints

See `docs/SPRINT_PLAN.md` § "Racional de versiones" for full reasoning. Short form: don't add `riverpod_lint`/`custom_lint` (incompatible with this SDK's riverpod 3.x/annotation 4.x), don't re-add `sqlite3_flutter_libs` (deprecated; `drift_flutter` bundles native SQLite), and `drift_dev schema dump` is unusable (analyzer version conflict with `riverpod_generator`) — migrations are covered by the `onUpgrade` implementation + round-trip test instead. Re-check all three when versions realign.

## Testing gotchas

Helpers in `test/support/` (`test_app.dart` for widget tests with an in-memory DB, `no_network_http_overrides.dart` for the offline guard — extend its coverage for new flows).

- Drift streams schedule a zero-duration close `Timer` on disposal: DB-backed widget tests end by unmounting + `pump(50ms)` (also flushes SnackBar timers).
- Tests with a focused `TextField` use `pump`, not `pumpAndSettle` (cursor-blink timer never settles).
- The dashboard home is a lazy `ListView`: off-screen buttons don't exist at the default 800×600 test size. Either set a tall viewport (`tester.view.physicalSize`) or — preferred for screen-focused tests — drive the screen directly via a minimal local `GoRouter` (avoids the onboarding gate too; see `journal_flow_test.dart`). With the editorial type scale, items can also sit below the fold at 800×600 — use `ensureVisible` (built items) or `scrollUntilVisible` (lazy lists) before tapping.
- The shell's nav-bar label "Hoy" is the only `es.homeTitle` text on the dashboard (home itself carries the date, not a heading) — `find.text(es.homeTitle)` counts on that.
- `dictationProvider` and `crisisContentProvider` are the injectable seams for what can't run headlessly — override them with fakes.
- Tests that land on the tab shell must call `completeFirstRun(db)` (in `test/support/test_app.dart`) or pre-set the tutorial flag — otherwise the auto-started guided-tour overlay absorbs their taps. Schema is v4 (`tutorialCompleted` on `AppMeta`).

## Product/domain model (for feature work)

The app maps three Stoic disciplines to modules — desire → habits/temperance, action → routines/discipline, judgment → journaling/reflection — and tracks progress via the four cardinal virtues (**Templanza, Coraje, Sabiduría, Justicia**, the fixed 4-value `Virtue` enum in `shared/`) rather than generic streaks. `VirtueProgressState` is `{ sinDesbastar, tomandoColor, pulida, enReposo }` — the user-facing scale is always qualitative (e.g. `QualitativeLevel` bajo/medio/alto, never numbers).
