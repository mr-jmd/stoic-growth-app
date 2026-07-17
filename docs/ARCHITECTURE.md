# Arquitectura — Andamio (MVP / Fase 1)

Este documento describe la arquitectura **en uso** del proyecto de software. Es la referencia técnica del MVP ya construido. La visión de producto vive en `README.md`; el detalle funcional de cada pantalla, en `docs/features/`.

> **Nota:** el sistema visual (colores, tipografía, componentes) se va a **replantear desde cero**. Este documento no fija reglas de diseño; solo describe la estructura técnica.

## Stack

| Capa | Tecnología |
|---|---|
| Lenguaje / UI | Dart + Flutter (Android e iOS) |
| SDK | Fijado con **FVM** a Flutter `3.44.6` (`.fvmrc`) — builds reproducibles; todos los comandos con prefijo `fvm` |
| Estado | **Riverpod** (`flutter_riverpod` 3.x, `riverpod_annotation` + `riverpod_generator`) |
| Navegación | **GoRouter** — un único router top-level expuesto por provider |
| Persistencia | **SQLite vía Drift** (ORM reactivo), local-first, fuente de verdad en el dispositivo |
| i18n | `flutter_localizations` + `gen-l10n` (un `app_es.arb`) |
| Voz (opcional) | `speech_to_text` + `permission_handler` |
| Codegen | `build_runner` orquesta `riverpod_generator` y `drift_dev`; `gen-l10n` para localización |

No hay backend, cuenta, ni autenticación en el MVP. No hay SDK de anuncios, notificaciones push ni analítica.

## Invariantes

- **100% offline.** La app funciona completa sin red. Un *guardia de red* en tests (`test/support/no_network_http_overrides.dart`) hace fallar cualquier flujo que intente abrir una conexión. La única excepción es el **dictado por voz opcional**, que usa el reconocedor del sistema (puede reconocer en la nube); nunca bloquea completar una entrada y el resto de la app sigue offline.
- **Sin cuenta.** La navegación nunca depende de un provider de sesión. No existe ruta de login/registro.
- **Local-first.** Drift en el dispositivo es la fuente de verdad. El sync/backup es Fase 2, no existe en el código.

## Estructura del código (feature-first)

```
lib/src/
├── app.dart                 # StoicApp: ProviderScope + MaterialApp.router + splash de arranque
├── core/
│   ├── database/            # Drift: tablas, DAOs, repositorios, providers
│   │   ├── tables/          # una tabla por archivo
│   │   ├── daos/            # un DAO por clúster de tablas
│   │   └── repositories/    # lógica de datos, expuesta por provider @riverpod
│   ├── design_system/       # tema + componentes (INTERIM — se va a replantear)
│   ├── l10n/                # app_es.arb + AppLocalizations generado
│   └── routing/             # app_router.dart (GoRouter + gate de onboarding)
├── features/                # una carpeta por funcionalidad (UI + controladores)
│   ├── onboarding/
│   ├── habits/
│   ├── journal/  (+ speech/)
│   ├── crisis/
│   ├── daily_quote/
│   └── home/
└── shared/                  # enums de dominio y helpers de l10n compartidos
```

## Capa de datos (Drift)

- **6 tablas** (`core/database/tables/`): `UserProfiles` (sin campos de auth), `Habits`, `JournalEntries` (índice único `(date, type)`), `JournalEntryTags` (join), `HabitCheckIns` (log **append-only** de check-ins — el verdadero "registro de racha"), `RelapseEvents` (evento de recaída como aprendizaje). Más `AppMeta` (flag de onboarding).
- **Enums de dominio** en `shared/`, guardados como `textEnum`: `Virtue`, `JournalType`, `JournalInputMethod`, `EveningTag`, `CheckInStatus`, `QualitativeLevel`.
- **DAOs** por clúster (`@DriftAccessor`), no monolíticos.
- **Repositorios** (`core/database/repositories/`) exponen la lógica vía provider `@riverpod` sobre `appDatabaseProvider`. Sin interfaces abstractas: hay una sola implementación y los tests inyectan una BD en memoria (`AppDatabase.forTesting(NativeDatabase.memory())`). *La única excepción es el seam de voz `Dictation`, que sí es una interfaz porque el plugin nativo no corre en tests headless.*
- **Escrituras compuestas van en una transacción** (`db.transaction`): recaída = check-in + evento + reset de racha; guardar entrada de diario = entrada + tags (con upsert por día). Los logs append-only nunca se borran ni mutan por un reset.
- **Migraciones:** `schemaVersion` 3. `onUpgrade` construye incrementalmente (v1 solo AppMeta → v2 esquema MVP → v3 índice único de diario). `beforeOpen` activa `PRAGMA foreign_keys = ON`.

## Estado y navegación

- Providers `@riverpod` (o manuales cuando el tipo de retorno viene del `part` generado por Drift, p. ej. streams de entidades Drift).
- **Gate de onboarding:** el redirect del router y su `refreshListenable` leen el **mismo** provider del flag persistido (`onboardingCompletedProvider`), nunca el conteo de hábitos. `StoicApp` muestra un splash hasta que el flag carga, para que el redirect nunca lea un valor sin resolver.
- **Crisis siempre alcanzable:** la ruta `/crisis` está exenta del gate — nadie en crisis queda bloqueado por el setup.

## Contenido estático empaquetado

El contenido editable/traducible (no dato de usuario) vive como **JSON en `assets/content/`**, fuera de Drift, cargado por `rootBundle` (nunca fetch):
- `crisis_content.json` — afirmación, guion de respiración, prompts socráticos.
- `quotes.json` — citas de dominio público + pregunta de reflexión.

## Testing

- `flutter test` contra `NativeDatabase.memory()` (unidad de repositorios) y widgets con BD en memoria inyectada (`test/support/test_app.dart`).
- Guardia de red (`withNoNetwork`) en flujos clave.
- Seams inyectables para lo que no corre headless: `dictationProvider` (voz) y `crisisContentProvider` se sobreescriben con fakes/valores fijos en tests.
- Auditoría automatizada de líneas rojas (`test/core/dashboard_logic_test.dart`): sin SDKs de ads/push/analítica en `pubspec`, sin rutas de login/auth.

## Comandos

Todos desde `app/`:

```bash
fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs   # tras tocar @riverpod / esquema Drift
fvm flutter gen-l10n                                            # tras editar app_es.arb
fvm flutter analyze
fvm flutter test
fvm flutter run
fvm flutter build apk --debug                                  # sanity de deps nativas, sin dispositivo
```
