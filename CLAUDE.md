# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project state

`README.md` (Spanish) is the **product proposal** — design intent, not documentation of existing code. `docs/SPRINT_PLAN.md` is the **implementation roadmap**: an 8-sprint plan (Sprint 0 → Sprint 7) that takes the scaffold to a Fase 1 / MVP build, with concrete tasks, acceptance criteria, and standing invariants (no paywalled streaks, no ads, no aggressive push notifications, 100% offline, no required account) for every sprint. **Read `docs/SPRINT_PLAN.md` before starting or resuming any implementation work** — it is the authoritative source for what to build next and in what order, and records decisions (e.g. i18n scaffolded from Sprint 1, mood/energy included in the MVP journal) that aren't in the README.

**Sprint 0 (bootstrap) is complete.** The app is no longer the bare `flutter create` scaffold:
- `lib/main.dart` boots `StoicApp` (`lib/src/app.dart`) via `ProviderScope` + a Riverpod-provided `GoRouter` (`lib/src/core/routing/app_router.dart`), currently routing to a single placeholder screen.
- Feature-first folder structure exists under `lib/src/{core,features,shared}` (see Architecture below), mostly still empty pending Sprint 1+.
- A minimal Drift database (`lib/src/core/database/app_database.dart`, one `AppMeta` table) proves the Drift + `riverpod_generator` + `build_runner` codegen toolchain works on this SDK; the real MVP schema (5 entities) is Sprint 2 work, not yet done.
- Dependencies added: `flutter_riverpod`, `riverpod_annotation`, `go_router`, `drift` + `drift_flutter`, `path_provider`, `path`; dev: `riverpod_generator`, `build_runner`, `drift_dev`.
- **`riverpod_lint`/`custom_lint` are intentionally NOT installed** — they don't yet support the `riverpod` 3.x / `riverpod_annotation` 4.x resolved by this project's SDK constraint. Re-check compatibility before adding them.
- **`sqlite3_flutter_libs` is intentionally NOT a direct dependency** — it's deprecated since 0.6.0 (native SQLite is now bundled via `drift_flutter`'s native-assets hooks); don't re-add it.

Sprints 1–7 (design system, full data layer, onboarding, streaks/relapse, journal, crisis mode, dashboard) are not yet built — see `docs/SPRINT_PLAN.md` for what each entails.

The repo name `stoic-growth-app` is a placeholder; the final product name is undecided between "Andamio" and "Virtude" (see README section 12).

## Commands

All Flutter commands run from the `app/` directory. The project pins an exact Flutter SDK via **FVM** (`.fvmrc` → `3.44.6`, not a floating channel); prefix commands with `fvm` (e.g. `fvm flutter`, `fvm dart`).

```bash
cd app

fvm flutter pub get                                    # install dependencies
fvm dart run build_runner build                        # regenerate Drift/Riverpod codegen (.g.dart files) after touching @DriftDatabase or @riverpod code
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
- **i18n:** planned from the first sprint if expansion beyond LATAM is expected.

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
