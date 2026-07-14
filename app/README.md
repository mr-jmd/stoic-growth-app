# app

Flutter app for the Stoic Growth App project (working name `stoic-growth-app`).

- Product proposal / vision: [`../README.md`](../README.md) (Spanish).
- Implementation plan (sprint by sprint, currently in progress): [`../docs/SPRINT_PLAN.md`](../docs/SPRINT_PLAN.md).
- Architecture and dev guidance for Claude Code: [`../CLAUDE.md`](../CLAUDE.md).

## Development

Flutter SDK version is pinned via [FVM](https://fvm.app/) (`.fvmrc`). Prefix commands with `fvm`:

```bash
fvm flutter pub get
fvm flutter run
fvm flutter analyze
fvm flutter test
fvm dart run build_runner build   # after touching @DriftDatabase or @riverpod code
```
