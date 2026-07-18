# Sprint Plan — Scaffold → MVP (Fase 1) · **completado**

Registro histórico de la implementación del MVP (Fase 1), construido en 8 sprints (0→7) más el dictado por voz. **Todo el MVP está terminado y verificado.**

> **Post-MVP (julio 2026):** sobre este MVP se construyó el rediseño visual completo **"Piedra y luz"** (nueva identidad, shell de pestañas, hub de diario) y un paquete de reglas de negocio: un éxito por día natural, **eliminación del tope de 3 hábitos** (decisión de producto — supera el "1-3" de este plan), archivado en dos pasos y el tour guiado (esquema v4). El detalle vive en `ARCHITECTURE.md` y `features/`; este documento queda como registro del build original.

- Arquitectura técnica: [`ARCHITECTURE.md`](ARCHITECTURE.md).
- Detalle de cada funcionalidad: [`features/`](features/).
- Visión de producto: [`../README.md`](../README.md).

> **Diseño:** el sistema visual actual es **interino y se va a replantear desde cero**. Este documento ya no contiene reglas de diseño; las tareas de diseño/UX de cada sprint quedaron superadas por ese replanteo.

## Alcance (Fase 1)

Diario de baja fricción, configuración de 1-3 hábitos/virtudes, streaks + registro de recaída sin culpa, cita estoica diaria, modo de crisis estático con orden "alivio primero, pregunta después", 100% offline sin cuenta obligatoria. El Interlocutor con IA, backend .NET/Postgres, cohortes, rutinas físicas configurables y metas de vida quedan fuera (Fase 2/3).

## Invariantes de proyecto (se mantuvieron en todos los sprints)

1. **Nunca condicionar racha-en-riesgo a un pago.** No hay sistema de pago; no existe paywall/entitlement en el código de hábitos/streaks/recaída.
2. **Nunca anuncios.** Ningún SDK de ads en `pubspec.yaml` (auditado por test).
3. **Nunca notificaciones push agresivas.** El MVP no incluye infraestructura de push. Recordatorios suaves opt-in quedan como decisión explícita de Fase 2+.
4. **100% offline, sin llamadas de red.** Un test-guardia (`HttpOverrides` que falla al abrir conexión) cubre el recorrido. Única excepción: el dictado por voz opcional usa el reconocedor del sistema; nunca bloquea completar una entrada.
5. **Sin cuenta/auth obligatoria.** El redirect del router nunca depende de un provider de sesión; no hay pantalla de login ni paquete de identidad (auditado por test).

## Estructura de sprints (entregado)

| # | Sprint | Estado | Qué entregó (técnico) |
|---|---|---|---|
| 0 | Bootstrap & Toolchain | ✅ | Scaffold feature-first; Riverpod + GoRouter + Drift cableados; codegen (`build_runner`) validado; FVM con SDK fijo. |
| 1 | Sistema de tema + i18n | ✅ | Capa de tema por tokens (`ThemeExtension`), fuentes OFL vendorizadas (offline), `gen-l10n` con `app_es.arb`, guardia de red en tests. *(El sistema visual se replanteará.)* |
| 2 | Capa de datos local (Drift) | ✅ | Esquema MVP (6 tablas), DAOs por clúster, repositorios por provider, migración real, tests contra `NativeDatabase.memory()`. |
| 3 | Onboarding & configuración de hábitos | ✅ | Flujo de 3 pasos, gestión de hábitos con tope de 3 activos, gate de onboarding en el router sobre flag persistido. → [features/onboarding.md](features/onboarding.md), [features/habits.md](features/habits.md) |
| 4 | Streaks + recaída sin culpa | ✅ | Detalle de hábito, contador editable, `logRelapse` atómico, historial append-only. → [features/streaks-and-relapse.md](features/streaks-and-relapse.md) |
| 5 | Diario de baja fricción | ✅ | Mañana/noche, ánimo/energía opcional, upsert por (día, tipo), nota nocturna opt-in. → [features/journal.md](features/journal.md) |
| 6 | Modo de crisis | ✅ | Flujo estático sin IA, orden alivio→pregunta forzado estructuralmente, respiración con `AnimationController`, contenido JSON empaquetado. → [features/crisis-mode.md](features/crisis-mode.md) |
| 7 | Dashboard de virtudes + cita diaria + hardening | ✅ | Home enmarcado en las 4 virtudes (función pura de agregación), cita diaria determinística, back en pantallas que faltaban, auditoría de líneas rojas por test. → [features/dashboard.md](features/dashboard.md) |
| + | Dictado por voz (carry-over de Sprint 5) | ✅ | `speech_to_text` + `permission_handler`, micrófono opt-in en los campos de texto, seam `Dictation` testeable. → [features/journal.md](features/journal.md#dictado-por-voz) |

**Racional de la estructura:** separar configuración de hábitos (Sprint 3) de streak/relapse (Sprint 4) evitó un sprint sobrecargado; mover el modo de crisis casi al final y aislado le dio atención dedicada a un flujo con restricción de orden safety-relevant.

## Racional de versiones de paquetes

El SDK fijado (Flutter `3.44.6`) es nuevo. Notas que siguen vigentes:

- **Mayor riesgo de codegen:** `drift_dev`, `riverpod_generator` y transitivas compartidas (`build_runner`, `source_gen`, `analyzer`). `drift_dev schema dump` quedó inutilizable por un conflicto `analyzer` entre `drift_dev` y `riverpod_generator`; la migración se cubre con la implementación de `onUpgrade` + test de round-trip. Re-chequear cuando realineen.
- **`riverpod_lint`/`custom_lint` NO instalados:** aún no soportan la `riverpod` 3.x / `riverpod_annotation` 4.x de este SDK. Re-chequear compatibilidad antes de agregarlos.
- **`sqlite3_flutter_libs` NO es dependencia directa** (deprecado; la SQLite nativa la aporta `drift_flutter`).
- **Voz:** `speech_to_text` aplica el Kotlin Gradle Plugin al estilo legacy (warning no-fatal upstream); el APK compila.

## Seams para Fase 2 (no bloquean)

- **`linkedGoalId` en `Habits`:** cuando llegue Metas de vida, asociar hábito↔meta. No agregada aún (migración barata a futuro).
- **Virtue como enum vs. tabla:** modelado como enum Dart fijo de 4 valores; se mantiene como enum (las 4 virtudes cardinales no son configurables por el usuario).
- **iOS release de voz:** falta el macro `PERMISSION_MICROPHONE=1` en el Podfile de `permission_handler` (no agregado — no se puede construir iOS en este entorno).

## Verificación

- `cd app && fvm flutter analyze && fvm flutter test` pasa (analyze limpio, suite verde).
- El test de integración offline-guardia cubre el recorrido completo.
- Pendiente de dispositivo: correr el recorrido completo (incl. voz) en un teléfono físico en modo avión. El dictado por voz ya se confirmó funcionando en dispositivo.
