# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project state

`README.md` (Spanish) is the **product proposal** — design intent, not documentation of existing code. `docs/SPRINT_PLAN.md` is the **implementation roadmap**: an 8-sprint plan (Sprint 0 → Sprint 7) that takes the scaffold to a Fase 1 / MVP build, with concrete tasks, acceptance criteria, and standing invariants (no paywalled streaks, no ads, no aggressive push notifications, 100% offline, no required account) for every sprint. **Read `docs/SPRINT_PLAN.md` before starting or resuming any implementation work** — it is the authoritative source for what to build next and in what order, and records decisions (e.g. i18n scaffolded from Sprint 1, mood/energy included in the MVP journal) that aren't in the README.

**Sprint 0 (bootstrap) is complete.** The app is no longer the bare `flutter create` scaffold:
- `lib/main.dart` boots `StoicApp` (`lib/src/app.dart`) via `ProviderScope` + a Riverpod-provided `GoRouter` (`lib/src/core/routing/app_router.dart`). The router now has the real routes and onboarding gate (Sprint 3); `StoicApp` shows a startup splash until the onboarding flag loads.
- Feature-first folder structure exists under `lib/src/{core,features,shared}` (see Architecture below); `core/design_system`, `core/l10n` and `shared/` are populated (Sprint 1), `features/` is still empty pending Sprint 3+.
- A minimal Drift database (`lib/src/core/database/app_database.dart`, initially one `AppMeta` table) proved the Drift + `riverpod_generator` + `build_runner` codegen toolchain works on this SDK; the full MVP schema was then built on top in Sprint 2 (see below).
- The `appDatabase` provider (`lib/src/core/database/database_provider.dart`, `@Riverpod(keepAlive: true)`) exposes the DB and disposes it — the pattern Sprint 2+ repositories follow.
- Dependencies added: `flutter_riverpod`, `riverpod_annotation`, `go_router`, `drift` + `drift_flutter`, `path_provider`, `path`; dev: `riverpod_generator`, `build_runner`, `drift_dev`.
- **`riverpod_lint`/`custom_lint` are intentionally NOT installed** — they don't yet support the `riverpod` 3.x / `riverpod_annotation` 4.x resolved by this project's SDK constraint. Re-check compatibility before adding them.
- **`sqlite3_flutter_libs` is intentionally NOT a direct dependency** — it's deprecated since 0.6.0 (native SQLite is now bundled via `drift_flutter`'s native-assets hooks); don't re-add it.

**Sprint 1 (design system + i18n) is complete.** The visual language and localization scaffolding are built and verified (`flutter analyze` clean, `flutter test` green under an offline guard, `flutter build apk --debug` bundles the fonts):
- **Design system** under `lib/src/core/design_system/` — a single material system with **two themes**: light ("mármol pulido") / dark ("basalto pulido"), toggled by `ThemeMode.system`. `tokens/` holds `StoicTokens` (a `ThemeExtension` with `.light()`/`.dark()` factories: shared spacing/radii/typography, per-mode color/elevation/virtue-slab gradients) and `palette.dart` — **the only file allowed to contain `Color(0x…)` literals** (enforced by DESIGN_BRIEF §7 greps). `theme/stoic_theme.dart` builds two `ThemeData` from that one token source via `ColorScheme.fromSeed(#D7CEBB)` corrected by hand. `components/` has the base widgets (`AppScaffold`, `AppButton`, `SelectableChip`, `AppCard`, `VirtueIndicator`, `EmptyState`, `AppBottomNav`, `CrisisAccessButton`); all read `context.stoic` / `ColorScheme`, never `if (isDark)`. `gallery/design_gallery_screen.dart` is a debug-only reference (served at `/` under `kDebugMode`) with a local brightness toggle. The "no gamification" checklist lives in the `design_system.dart` barrel doc.
- **Fonts:** Cormorant Garamond + Source Sans 3 vendored as **variable fonts** (`wght` axis) in `app/assets/fonts/`, declared in `pubspec.yaml`. **Never** add `google_fonts` (runtime fetch breaks the offline invariant).
- **i18n:** `flutter_localizations` + `gen-l10n`, single `app_es.arb` in `lib/src/core/l10n/`. Every user-facing string goes through `AppLocalizations` from here on — no literals. `l10n.yaml` configures codegen (`generate: true`).
- **Shared domain:** `lib/src/shared/virtue.dart` (`Virtue` enum, fixed 4 values — Sprint 2's Drift type converter imports this, not vice-versa) and `virtue_progress_state.dart` (`VirtueProgressState { sinDesbastar, tomandoColor, pulida, enReposo }`; `enReposo` is the relapse "resting stone" state — never red/empty).
- **Offline guard:** `test/support/no_network_http_overrides.dart` (`HttpOverrides` that throws on any connection + `withNoNetwork` helper). Extend its coverage each sprint through Sprint 7.
- Dependencies added this sprint: `flutter_localizations` (SDK), `intl`.

**Sprint 2 (local data layer) is complete.** The full MVP schema, DAOs, repositories and a real migration are built and verified (`build_runner` clean, `flutter analyze` clean, 11 tests green against `NativeDatabase.memory()`, debug APK builds):
- **Schema** — 6 Drift tables under `lib/src/core/database/tables/` (one class per file): `UserProfiles` (no auth fields), `Habits` (`virtue` via `textEnum`; `currentStreakCount` is a directly-editable int), `JournalEntries` (day-precision `date`; nullable `moodScore`/`energyScore`), `JournalEntryTags` (join, FK cascade), `HabitCheckIns` (**append-only** event log — the real "streak record"), `RelapseEvents` (FK to habit + nullable check-in). `HabitCheckIns`/`RelapseEvents` are pure history — never deleted or mutated by a streak reset.
- **Enums** in `lib/src/shared/` stored as `textEnum` (the `.name`): `JournalType`, `JournalInputMethod`, `EveningTag`, `CheckInStatus` (plus `Virtue` from Sprint 1). Display copy stays in l10n.
- **DAOs** per cluster via `@DriftAccessor` (`daos/`): `HabitsDao`, `JournalDao`, `UserProfileDao` — not monolithic.
- **Repositories** in `lib/src/core/database/repositories/` (kept in the data layer, not `features/`, until Sprint 3+ consumes them), exposed via `@riverpod` over `appDatabaseProvider`, **no abstract interfaces**. `HabitRepository.recordCheckIn` inserts a check-in and recomputes the streak in one `db.transaction`; `JournalRepository.saveEntry` writes entry + tags atomically.
- **Migration** — `schemaVersion` is 2; `onUpgrade` creates the Sprint 2 tables when upgrading from the Sprint 0 v1 (AppMeta-only) DB; `beforeOpen` sets `PRAGMA foreign_keys = ON`. `AppDatabase.forTesting(executor)` injects an in-memory DB for tests.
- **`drift_dev schema dump` is currently unusable** on this dependency set (`drift_dev` ≥2.34.1+1 needs `analyzer ^13`, but `riverpod_generator ^4.0.4` needs `analyzer ^12` — a hard conflict). The migration path is instead covered by the `onUpgrade` implementation + a round-trip test. Re-check when analyzer/riverpod_generator/drift_dev realign before relying on schema-export migration tests.

**Sprint 3 (onboarding & habit config) is complete.** First-run flow, habit management and the router onboarding gate are built and verified (`flutter analyze` clean, 13 tests green, debug APK builds, tested on device):
- **Features** under `lib/src/features/{onboarding,habits,home}/`. Onboarding is a 3-step flow (intro → 1–3 selection via `SelectableChip` grouped by virtue → confirmation) driven by `OnboardingController`; copy is non-clinical (see `onboarding_suggestions.dart`). Habits has a list (with archive/add + warm empty state) and a create form enforcing the 3-active cap. `home/` is a minimal shell (placeholder until the Sprint 7 dashboard) with entry to habits and, in debug, `/gallery`.
- **Onboarding state** is persisted, not inferred: `AppMetaDao` (single-row `onboardingCompleted`) + `OnboardingRepository` (`watchCompleted`/`complete`), exposed as `onboardingCompletedProvider`. The router gate keys off this flag, never the habit count, so archiving all habits shows an empty state instead of re-onboarding.
- **Router** (`core/routing/app_router.dart`): the redirect **and** its `refreshListenable` read the *same* `onboardingCompletedProvider` (bridged to a `ValueNotifier` via `ref.listen`). Using two independent DB streams here caused a race that stranded the user on the confirmation screen — keep them on one source. `StoicApp` shows a splash until the flag first loads, so the redirect never reads an unresolved value. `/gallery` is exempt from the gate.
- **`HabitRepository`** gained `createHabit` (transactional 3-active cap; throws `MaxActiveHabitsException`), `updateStreakManually` (renamed from `setStreakCount`), and the **manual** `activeHabitsProvider` (not `@riverpod` — riverpod_generator can't emit a drift-generated return type; use manual providers for drift-entity streams).
- **Theme:** `splashFactory` is `InkRipple` (not `InkSparkle`) — the sparkle leaked a `Timer` on nav-unmount and clashed with the sober aesthetic.
- **Widget-test helpers** in `test/support/test_app.dart` (`testApp`/`wrapScreen` with an in-memory DB override). Drift streams schedule a zero-duration close `Timer` on disposal, so DB-backed widget tests end by unmounting + `pump(50ms)`; tests with a focused `TextField` use `pump`, not `pumpAndSettle` (cursor-blink timer).

**Sprint 4 (streaks + no-guilt relapse) is complete.** The habit-detail screen, the guilt-free relapse flow and the consistency history are built and verified (`flutter analyze` clean, 18 tests green, debug APK builds):
- **Features** under `lib/src/features/habits/`: `habit_detail_screen.dart` (route `/habits/:id`) shows the live consistency count with a directly-editable value (stepper ±1 **and** tap-to-edit dialog for an arbitrary number), a first-class "registrar hoy" (success check-in) action, a first-class "registrar una recaída" action, and the append-only check-in history (newest first; past relapses stay visible as data). `relapse_form_screen.dart` (route `/habits/:id/relapse`) is a short learning-framed form (contexto/detonante/aprendizaje, all optional). Habit list rows now tap through to detail.
- **`HabitRepository.logRelapse`** is the Sprint 4 relapse flow: inserts a `relapse` check-in **and** its paired `RelapseEvents` row **and** resets the streak to 0, all in one `db.transaction` (atomic — never observable half-applied). The reset is only a re-editable default via `updateStreakManually`, never locked. `logRelapseEvent` stays as the low-level history primitive; `recordCheckIn` still handles the success path. New **manual** family providers `habitByIdProvider` / `habitCheckInsProvider` (drift-return-type reason, same as `activeHabitsProvider`); DAO gained `watchHabit(id)`.
- **Copy/visual line (hard here):** no red (`scheme.error` reserved for real form errors), no "rompiste tu racha", no exclamation marks, no gamified framing. A relapse is `VirtueProgressState.enReposo` (resting stone), and the history's relapse dot uses the `reposo` tone, success uses `colors.habitCheckFill` — neither red. History dates via `MaterialLocalizations.formatMediumDate` (locale-aware, no `intl` init needed).
- **Router:** `/habits/new` is declared **before** `/habits/:id` so "new" isn't captured as an id. Widget tests that need routing build a minimal local `GoRouter` with just the habit routes (avoids the onboarding gate); the SnackBar auto-dismiss timer is flushed by the same unmount + `pump(50ms)` teardown as Drift's stream-close timer.

Sprints 5–7 (journal, crisis mode, dashboard) are not yet built — see `docs/SPRINT_PLAN.md` for what each entails.

The repo name `stoic-growth-app` is a technical placeholder. **"Andamio" is the working name** used in design/development (see `docs/DESIGN_BRIEF.md`); "Virtude" is the backup alternative if Andamio fails domain/social validation. The final brand name isn't locked yet (see README section 12).

## Commands

All Flutter commands run from the `app/` directory. The project pins an exact Flutter SDK via **FVM** (`.fvmrc` → `3.44.6`, not a floating channel); prefix commands with `fvm` (e.g. `fvm flutter`, `fvm dart`).

```bash
cd app

fvm flutter pub get                                    # install dependencies
fvm dart run build_runner build                        # regenerate Drift/Riverpod codegen (.g.dart files) after touching @DriftDatabase or @riverpod code
fvm flutter gen-l10n                                    # regenerate AppLocalizations after editing lib/src/core/l10n/app_es.arb (also runs on pub get)
fvm flutter run                                         # run on a connected device/emulator
fvm flutter analyze                                     # static analysis (uses analysis_options.yaml / flutter_lints)
fvm flutter test                                         # run all tests
fvm flutter test test/widget_test.dart                  # run a single test file
fvm flutter build apk --debug                            # Android build (works headless, no device needed — useful to sanity-check native deps like sqlite3)
fvm flutter build ios                                    # iOS build (requires macOS/Xcode)
```

There is no CI config, Linux/macOS/Windows desktop platform support (Android/iOS only), Melos workspace, or lint/format scripts beyond the standard Flutter toolchain.

## Target architecture (per README section 6)

The proposal specifies this stack — `docs/SPRINT_PLAN.md` sequences it into sprints, and Sprint 0 has already wired up Riverpod, GoRouter, and Drift (see Project state above). Use this as the default unless the user directs otherwise:

- **Frontend:** Flutter/Dart (chosen over React Native and Kotlin Multiplatform for rendering consistency across iOS/Android).
- **State management / navigation:** Riverpod + GoRouter.
- **Local persistence:** SQLite via Drift, local-first — the app must work fully offline. This is the source of truth on-device.
- **Backend (sync/backup only, not required for MVP):** ASP.NET Core Minimal API + PostgreSQL, split into independent services (auth, sync, AI) for independent scaling. Supabase is noted as a faster-to-launch alternative with less long-term scalability control.
- **AI layer ("El Interlocutor"):** external LLM API (e.g., Anthropic), Socratic-questioning persona (asks questions, never diagnoses or gives emotional advice). Two-tier cost architecture:
  - Crisis/grounding mode: **fixed templates, no generative AI, always free, no external dependency** (safety-critical — must not depend on API availability/latency).
  - Reflective/Socratic mode: generative AI, free tier capped at 15 interactions/month/user, then degrades to a pre-written reflection library (never a hard block).
  - Risk classification must run before any generative response; high-risk signals (self-harm, crisis) route to fixed templates and human help lines, never to freeform generation.
- **i18n:** implemented in Sprint 1 (`flutter_localizations` + `gen-l10n`, single `app_es.arb`); every user-facing string goes through `AppLocalizations`.

## Product/domain model (for feature work)

The app is organized around three Stoic disciplines mapped to app modules, and progress is tracked via four cardinal virtues rather than generic streaks:

| Discipline | Module |
|---|---|
| Desire (deseo) | Habits/addictions/temperance |
| Action (acción) | Routines, physical discipline, purposeful work |
| Judgment (juicio) | Journaling, mindfulness, guided reflection |

Virtues used for progress metrics: **Templanza** (temperance), **Coraje** (courage), **Sabiduría** (wisdom), **Justicia** (justice).

Key UX constraints from README section 10, relevant to any journaling/AI-chat feature work:
- Journaling defaults to low-friction tap/voice input (chips, pre-written options); free-text is optional and expands only if the user chooses it — never the reverse.
- In crisis flows, deliver immediate relief (breathing exercise / reframing statement) **before** any Socratic question — never open a crisis interaction with a question.
- Never gate streaks behind payment, never show ads, never use aggressive re-engagement push notifications (README section 9.6 — explicit "never implement" list).

## Data entities (initial model, README section 7)

Local user profile, Habit/target virtue, Journal entry, Streak record, Relapse event, Physical discipline session, Interlocutor conversation (risk-classified, auditable), Life goal, Cohort (5-8 users in a shared challenge).
