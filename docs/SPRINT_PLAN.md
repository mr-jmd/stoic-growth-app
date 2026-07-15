# Sprint Plan — Scaffold → MVP (Fase 1)

## Contexto

El repo hoy es solo el scaffold por defecto de `flutter create` (`app/lib/main.dart` es el counter demo) corriendo en un teléfono físico, más el documento de propuesta `README.md` (intención de diseño, no código existente) y `CLAUDE.md` (guía de arquitectura). No hay `docs/`, no hay dependencias más allá de `flutter`/`cupertino_icons`/`flutter_lints`, no hay `lib/src`, no hay CI.

Este plan lleva ese scaffold a un MVP funcional, ciñéndose estrictamente a la Fase 1 del README (sección 8): diario de baja fricción, configuración de 1-3 hábitos/virtudes, streaks + registro de recaída sin culpa, cita estoica diaria, modo de crisis estático con orden "alivio primero, pregunta después", 100% offline sin cuenta obligatoria. El Interlocutor con IA, backend .NET/Postgres, cohortes, rutinas físicas configurables y metas de vida quedan explícitamente fuera (Fase 2/3).

Decisiones ya confirmadas:
1. **Estructura de 8 sprints** (separar habit-config de streak/relapse; crisis mode casi al final, aislado por ser safety-critical).
2. **i18n desde el Sprint 1** (flutter_localizations + gen-l10n, un solo `app_es.arb`).
3. **Mood/energy en el diario** (README 4.1) — se agrega al MVP. Afecta el schema de `JournalEntries` (Sprint 2) y la UI del diario (Sprint 5).
4. **Voz "best-effort"** — `speech_to_text` preferentemente on-device; si no se puede garantizar, se degrada silenciosamente sin bloquear chip/texto (que siempre funciona offline).

---

## Estructura de sprints

| # | Sprint | Depende de |
|---|---|---|
| 0 | Bootstrap & Toolchain | — |
| 1 | Sistema de diseño + i18n | 0 |
| 2 | Capa de datos local (Drift) | 0 |
| 3 | Onboarding & configuración de hábitos/virtudes | 1, 2 |
| 4 | Streaks de consistencia + registro de recaída sin culpa | 2, 3 |
| 5 | Diario de baja fricción (mañana/noche + mood/energy) | 1, 2 |
| 6 | Modo de crisis (respiración + dicotomía de control) | 1 |
| 7 | Dashboard de virtudes, cita diaria y hardening del MVP | 3, 4, 5, 6 |

**Racional de la reestructuración** frente a agrupar todo en 4 bloques de features: separar configuración de hábitos y streak/relapse en dos sprints evita un sprint sobrecargado con criterios de aceptación difíciles de verificar juntos; mover crisis mode casi al final (en vez de agruparlo con las otras features) le da atención dedicada a un flujo con una restricción de orden safety-relevant, en vez de construirlo bajo presión de tiempo de un sprint de integración.

---

## Invariantes de proyecto (aplican a todos los sprints, no son tareas de un sprint específico)

1. **Nunca condicionar racha-en-riesgo a un pago.** No hay sistema de pago en este MVP; el guardrail concreto es que ningún sprint introduce un paywall/entitlement check en el código de hábitos/streaks/recaída.
2. **Nunca anuncios.** Ningún SDK de ads debe aparecer en `pubspec.yaml` en ningún sprint.
3. **Nunca notificaciones push agresivas de reenganche.** El MVP no incluye infraestructura de push en absoluto (sin `firebase_messaging`, sin setup APNs/FCM) — la garantía es por omisión. Recordatorios suaves y opt-in (`flutter_local_notifications` para un nudge diario del diario) quedan como decisión explícita de Fase 2+, no de este MVP.
4. **100% offline, sin llamadas de red.** Introducir un test-guardia desde el Sprint 1 (override de `HttpOverrides.global` con un cliente que falla si intenta abrir conexión) y extender su cobertura sprint a sprint hasta cubrir el recorrido completo en el Sprint 7.
5. **Sin cuenta/auth obligatoria.** La lógica de redirect del router nunca depende de un provider de sesión/auth; ningún sprint introduce pantalla de login, almacenamiento de token, o paquete de identidad (`firebase_auth`, `supabase_flutter`, etc.).

---

## Sprint 0 — Bootstrap & Toolchain

**Objetivo:** Eliminar el boilerplate del counter, establecer estructura de carpetas feature-first, y probar que todo el stack de dependencias (Riverpod, GoRouter, Drift + codegen) compila y corre en el SDK fijado, antes de que el trabajo de features dependa de él.

**Tareas técnicas:**
- Quitar `MyApp`/`MyHomePage`/contador de `app/lib/main.dart`; nuevo `main.dart` solo llama `runApp(const ProviderScope(child: StoicApp()))`.
- Agregar a `pubspec.yaml` (usar `flutter pub add` para resolver versiones compatibles, no hardcodear números — ver sección de racional de versiones): `flutter_riverpod`, `riverpod_annotation`; dev: `riverpod_generator`, `build_runner`, `custom_lint`, `riverpod_lint`; `go_router`; `drift`, `drift_flutter`, `sqlite3_flutter_libs`, `path_provider`, `path`; dev: `drift_dev`.
- Estructura de carpetas:
  ```
  lib/
    main.dart
    src/
      app.dart                     # StoicApp: MaterialApp.router
      core/
        routing/                   # app_router.dart (GoRouter provider)
        database/                  # drift database + generated code
        design_system/             # (Sprint 1)
        l10n/                      # .arb files (Sprint 1)
        utils/
      features/
        onboarding/
        habits/
        journal/
        daily_quote/
        crisis/
      shared/
  ```
- `GoRouter` placeholder con una sola ruta (`/`) → `Scaffold` con texto plano (sin theming, eso es Sprint 1).
- Drift mínimo (`core/database/app_database.dart`) con una tabla real pequeña (`AppMeta`: `onboardingCompleted: bool`, `schemaVersion`) — el objetivo es probar que `dart run build_runner build --delete-conflicting-outputs` funciona en este SDK, no modelar el schema completo (eso es Sprint 2).
- Reemplazar `test/widget_test.dart` (borrar aserciones del counter) por un smoke test que monta `StoicApp` y encuentra el texto placeholder.
- Resolver el gap de reproducibilidad de `.fvmrc` (hoy fija canal `"stable"`, no versión exacta): correr `fvm use <versión resuelta>` una vez y dejar `.fvmrc`/`.fvm/fvm_config.json` apuntando a una versión concreta, no a un canal móvil.
- `flutter run` completo (no solo hot reload) en el teléfono físico para confirmar que el plugin nativo `sqlite3_flutter_libs` registra correctamente.

**Tareas de arquitectura:**
- Convención de un provider (`@riverpod`) por repositorio desde ya, aunque solo exista un placeholder.
- Documentar (breve, en comentario de `app_router.dart`) que habrá un único `GoRouter` top-level expuesto vía provider (`appRouterProvider`), con redirects de onboarding añadidos en Sprint 3.

**Tareas de diseño/UX:** Ninguna — deliberadamente diferido a Sprint 1 (Material defaults sin branding para evitar trabajo desechable).

**Criterios de aceptación:**
- `flutter analyze` sin warnings.
- `dart run build_runner build --delete-conflicting-outputs` sin errores (el ítem de mayor riesgo de compatibilidad de todo el stack — ver racional de versiones).
- App bootea en el teléfono a la pantalla placeholder vía `flutter run`; cero referencias a `MyApp`/`MyHomePage`/`Counter` en `lib/`/`test/` (chequeo por grep).
- `flutter test` pasa (smoke test).

**Dependencias:** ninguna.

---

## Sprint 1 — Sistema de diseño + i18n

> **Estado: COMPLETO.** Sistema de diseño dual claro/oscuro, i18n y galería implementados y verificados (`flutter analyze` limpio, `flutter test` en verde con guardia offline, `flutter build apk --debug` OK con fuentes empaquetadas). Ubicación: `app/lib/src/core/design_system/` (tokens, theme, components, gallery), `app/lib/src/core/l10n/` (i18n), `app/lib/src/shared/` (`Virtue`, `VirtueProgressState` y sus labels), `app/assets/fonts/` (OFL vendorizadas).
>
> **Decisiones cerradas en este sprint:**
> - **Tipografía = variable fonts.** Google Fonts ya solo publica Cormorant Garamond y Source Sans 3 como *variable fonts* (eje `wght`); se vendorizaron esos VF (roman + itálica de Cormorant) en `assets/fonts/` con sus licencias OFL. Flutter mapea `fontWeight`→`wght` y los tokens fijan además `FontVariation('wght', …)`. No se usan instancias estáticas ni `google_fonts` runtime.
> - **`ThemeMode.system`** (opción recomendada del DESIGN_BRIEF §8.4): cero persistencia nueva, sin tocar el schema de Drift. El toggle manual persistido queda como follow-up aditivo de Fase 2+.
> - **Tonos claros de "sin desbastar"** para Templanza/Coraje/Sabiduría (el brief solo daba Justicia explícito) se derivaron como tintes pálidos análogos y viven en `tokens/palette.dart` (único archivo con literales `Color(0x…)`). Candidatos a afinar visualmente en device.
> - **Home en debug = galería.** Mientras no exista el dashboard (Sprint 7), `GoRouter` sirve la galería debug-only en `/` bajo `kDebugMode`, y un placeholder en release. La galería trae un toggle de brightness **local** que no altera el tema global.
> - **Enum `Virtue` en `lib/src/shared/`** (no en la capa de Drift): fuente única que Sprint 2 importará para el type converter, sin que ninguna capa sea dueña de la otra. Se agregó `VirtueProgressState { sinDesbastar, tomandoColor, pulida, enReposo }` en el mismo lugar.
> - **Guardia offline** implementada como `HttpOverrides` que lanza ante cualquier conexión (`test/support/no_network_http_overrides.dart` + helper `withNoNetwork`); los tests de galería corren bajo ella. Es la base a extender hasta Sprint 7.
> - **Dependencias agregadas:** `flutter_localizations` (SDK) + `intl`. Se activó `generate: true` y `l10n.yaml`. Sin nuevos paquetes de UI/estado.

**Objetivo:** Establecer el lenguaje visual sobrio tierra/mármol (tokens, paleta, tipografía, tema, componentes base) y el scaffolding de i18n, para que toda la app posterior consuma un sistema consistente desde el día uno.

**Tareas técnicas:**
- Tipografía: dos tipos con licencia abierta (OFL), display "clásico/inscripcional" + body humanista sobrio. **No usar el fetch runtime por defecto de `google_fonts`** (rompe offline) — empaquetar `.ttf`/`.otf` en `assets/fonts/` vía `pubspec.yaml`.
- `flutter_localizations` + `gen-l10n`: un solo `app_es.arb` en `core/l10n/`. Todo string user-facing pasa por `AppLocalizations.of(context)` desde este sprint en adelante — sin excepciones, incluidos los sprints de features posteriores.
- Tokens de diseño como `ThemeExtension<StoicTokens>`: colores de acento por virtud (4 tonos apagados, uno por Templanza/Coraje/Sabiduría/Justicia), escala de espaciado, escala de radios, tono de elevación/sombra (suave, tipo mármol).
- `ColorScheme` desde semilla tierra/mármol (piedra cálida, arcilla, oliva/salvia apagado, marfil), ajustado a mano en roles específicos (surface, error) — `ColorScheme.fromSeed` por sí solo tiende a colores saturados que chocan con "sobrio, sin estridencia".
- Componentes base en `core/design_system/components/`: `AppButton`, `SelectableChip` (tap target ~48dp, usado en chips de diario y selección de hábito/virtud), `AppCard`, `VirtueIndicator` (representación sutil, no badge gamificado), `EmptyState`, `AppScaffold`.

**Tareas de arquitectura:**
- Un solo `ThemeData` construido desde tokens + `ColorScheme`, aplicado una vez en `StoicApp` (`MaterialApp.router(theme: ...)`); sin overrides de tema por pantalla en sprints posteriores sin justificación.
- Checklist "sin gamificación" documentado para contribuidores futuros: sin emoji de racha/fuego, sin confetti, sin framing rojo/alarma para recaída, sin sonidos de logro.

**Tareas de diseño/UX:**
- Pantalla-galería de componentes (debug-only) mostrando todos los componentes base y los 4 colores de virtud juntos, como referencia de consistencia para sprints posteriores.
- Diseñar ahora el lenguaje visual de "recaída" (tono neutro/cálido, no rojo/alerta) aunque la feature se construya en Sprint 4 — evita retrabajo de tono sobre una feature ya construida.

**Criterios de aceptación:**
- `flutter analyze` sin warnings.
- Pantalla-galería renderiza todos los componentes y fuentes en el teléfono físico con cero actividad de red (verificado con el test-guardia offline de este sprint).
- Cero valores de color/spacing/fuente hardcodeados fuera de `core/design_system/` (grep de `Color(0x...)` literal).
- Todos los strings de este sprint pasan por `AppLocalizations`, no literales.

**Dependencias:** Sprint 0.

---

## Sprint 2 — Capa de datos local (Drift)

> **Estado: COMPLETO.** Schema completo del MVP, DAOs, repositorios y migración implementados y verificados (`build_runner` sin errores, `flutter analyze` limpio, 11 tests en verde con `NativeDatabase.memory()`, `flutter build apk --debug` OK con la SQLite nativa). Ubicación: `app/lib/src/core/database/{tables,daos,repositories}/`, enums de dominio en `app/lib/src/shared/`, tests en `app/test/core/database/data_layer_test.dart`.
>
> **Decisiones cerradas en este sprint:**
> - **Enums vía `textEnum`** (no `intEnum`): `Virtue`, `JournalType`, `JournalInputMethod`, `EveningTag`, `CheckInStatus` se guardan por `.name` — más estable ante reordenamientos; renombrar un valor es una migración. Todos viven en `lib/src/shared/`.
> - **Repositorios en `core/database/repositories/`** (no en `features/*/data/`): mantiene la capa de datos cohesionada mientras `features/` sigue vacío; Sprint 3+ los consume. Expuestos vía `@riverpod` sobre `appDatabaseProvider`, sin interfaces abstractas.
> - **Constructor `AppDatabase.forTesting(executor)`** para inyectar `NativeDatabase.memory()` en tests, en vez de override de provider (más directo para tests de capa de datos pura; el override de `appDatabaseProvider` sigue disponible para tests de widget/integración).
> - **Migración v1→v2 real, no stub vacío:** `schemaVersion` sube a 2 y `onUpgrade` crea las 6 tablas nuevas cuando viene de v1 (Sprint 0 dejó solo `AppMeta`). `beforeOpen` activa `PRAGMA foreign_keys = ON`. FKs con `onDelete: cascade` en join/historial.
> - **`recordCheckIn` ya transaccional** (insert de check-in + recálculo de streak en `db.transaction`); Sprint 4 extiende con el flujo recaída de dos tablas (check-in + `RelapseEvents`) atómico. `logRelapseEvent` queda como primitiva de historial.
> - **Export de schema de `drift_dev` NO realizado — bloqueado por conflicto de dependencias.** `drift_dev schema dump` está roto en este set: `drift_dev ≥2.34.1+1` exige `analyzer ^13` pero `riverpod_generator ^4.0.4` exige `analyzer ^12` (incompatibles; no se puede subir `drift_dev` sin romper el codegen de Riverpod). Es el riesgo de tooling que anticipa la sección "Racional de versiones". **Mitigación aplicada:** el camino de migración queda establecido y probado vía la implementación de `onUpgrade` + un test de round-trip que confirma `schemaVersion == 2` y que `onUpgrade` es invocable. **Pendiente:** re-checar compatibilidad y generar el export cuando `analyzer`/`riverpod_generator`/`drift_dev` se realineen.
> - **Dependencias:** ninguna nueva (el stack de Drift/Riverpod ya estaba desde Sprint 0).

**Objetivo:** Modelar y persistir las 5 entidades del MVP (usuario local, hábito/virtud, entrada de diario, registro de racha, evento de recaída) con Drift, con estrategia de migración desde el día uno.

**Tareas técnicas — tablas** (`core/database/tables/`, una clase `Table` por archivo):
- `UserProfiles` — `id`, `displayName` (nullable), `createdAt`. Sin campos de auth.
- `Habits` — `id`, `label`, `virtue` (enum Dart `Virtue { templanza, coraje, sabiduria, justicia }` vía type converter de Drift), `createdAt`, `archived` (bool), `sortOrder`, `currentStreakCount` (int, mutable — ver Sprint 4).
- `JournalEntries` — `id`, `date` (DateTime, precisión de día), `type` (enum morning/evening), `freeText` (nullable), `inputMethod` (enum typed/voice), **`moodScore` (nullable int)**, **`energyScore` (nullable int)** — ambos agregados por decisión confirmada de incluir mood/energy en el MVP (README 4.1), sin lenguaje clínico en la UI (Sprint 5 define la escala como chips cualitativos, no un formulario tipo escala clínica), `createdAt`.
- `JournalEntryTags` — join table: `id`, `journalEntryId` (FK), `tag` (enum con los 3 chips fijos de la noche). El morning entry no usa esta tabla (es una frase corta, no chips de opción fija).
- `HabitCheckIns` — `id`, `habitId` (FK), `date`, `status` (enum success/relapse), `note` (nullable), `createdAt`. Es el log histórico append-only — el "Registro de racha" real, modelado como event log (no una fila mutable única) para que el historial nunca se pierda.
- `RelapseEvents` — `id`, `habitId` (FK), `checkInId` (FK nullable), `context` (nullable), `trigger` (nullable), `learning` (nullable), `createdAt`.

**Tareas técnicas — resto:**
- DAOs por cluster de tabla vía `@DriftAccessor` (`HabitsDao`, `JournalDao`, `UserProfileDao`), no un DAO monolítico.
- Repositorios concretos (`HabitRepository`, `JournalRepository`, `UserProfileRepository`) expuestos vía `@riverpod`. **No introducir interfaces abstractas solo por testabilidad** — con una sola implementación y entorno, `overrideWith` de Riverpod sobre el provider de la base de datos (`NativeDatabase.memory()` en tests) alcanza sin la ceremonia de interfaces.
- `MigrationStrategy` con `onCreate: (m, schema) => m.createAll()` + stub explícito de `onUpgrade`, y exportación de schema de `drift_dev` para que adiciones de Fase 2 tengan un camino de migración probado.

**Tareas de arquitectura:**
- `Virtue` como enum Dart fijo (4 valores), no tabla — el set es fijo y core a la identidad del producto. Las etiquetas de display van en la capa de localización (`.arb`), nunca hardcodeadas junto al enum.
- `currentStreakCount` en `Habits` es un entero plano editable directamente por UI (satisface "user-editable, no solo auto-incrementable"); normalmente se recalcula al insertar una fila en `HabitCheckIns`, pero una edición manual simplemente sobreescribe la columna — mismo mecanismo, sin caso especial a nivel de schema. `HabitCheckIns`/`RelapseEvents` son historial puro — **nunca se borran ni mutan** por un reset de racha.
- Contenido estático (citas, contenido de respiración/dicotomía de control) queda **fuera de Drift** — no es dato de usuario, es contenido de build-time. Se diseña en Sprint 6/7 como JSON empaquetado parseado a modelos inmutables al arrancar, separado del schema de Drift.

**Tareas de diseño/UX:** ninguna (sprint solo de capa de datos, sin superficie visible).

**Criterios de aceptación:**
- `dart run build_runner build --delete-conflicting-outputs` genera todas las tablas/DAOs sin errores.
- Tests unitarios (con `NativeDatabase.memory()`) cubren: insertar hábito; insertar check-in y confirmar actualización de `currentStreakCount`; insertar evento de recaída y confirmar que filas previas de `HabitCheckIns` siguen intactas/consultables; edición manual de racha persistiendo correctamente.
- Test de round-trip de schema (crear DB v1, confirmar que el stub de `onUpgrade` está conectado y es invocable) como placeholder para migraciones futuras.
- `flutter analyze` sin warnings.

**Dependencias:** Sprint 0 (prueba de toolchain); no requiere Sprint 1.

---

## Sprint 3 — Onboarding & configuración de hábitos/virtudes

> **Estado: COMPLETO.** Onboarding, configuración de hábitos y el gate de router implementados y verificados (`flutter analyze` limpio, 13 tests en verde incl. flujo onboarding end-to-end, greps de invariantes de diseño vacíos, `flutter build apk --debug` OK, probado en dispositivo físico). Ubicación: `app/lib/src/features/{onboarding,habits,home}/`, estado de onboarding en `app/lib/src/core/database/{daos/app_meta_dao.dart,repositories/onboarding_repository.dart}`, router en `app/lib/src/core/routing/app_router.dart`, tests en `app/test/features/onboarding_flow_test.dart`.
>
> **Decisiones cerradas en este sprint:**
> - **Gate keyed en el flag persistido, no en el conteo de hábitos.** `AppMetaDao` (single-row upsert) + `OnboardingRepository` guardan `onboardingCompleted`; el redirect lee eso. Archivar todos los hábitos después lleva a un empty-state, nunca de vuelta a onboarding.
> - **Router de fuente única (fix de carrera).** El `redirect` y el `refreshListenable` deben leer el flag del **mismo** provider (`onboardingCompletedProvider`, puenteado a un `ValueNotifier` vía `ref.listen`). La primera implementación usó dos streams de Drift independientes y una carrera dejaba al usuario clavado en la pantalla de confirmación al pulsar "Comenzar" (el redirect leía el valor viejo). Verificado en dispositivo.
> - **Startup splash en `StoicApp`.** Mientras el flag carga por primera vez, se muestra un splash calmo; así el redirect nunca lee un valor sin resolver (evita flash de pantalla equivocada).
> - **Onboarding controller resiliente al tope.** Si al crear los hábitos elegidos se alcanza el tope de 3 activos (p. ej. datos residuales de un intento previo), se salta la creación pero **igual** se completa el onboarding — nunca falla el flujo por el cap.
> - **`createHabit` con tope de 3 en transacción** (lanza `MaxActiveHabitsException` con el límite), `updateStreakManually` (rename de `setStreakCount`), `activeHabitsProvider`. Reutilizados por Sprint 4.
> - **`activeHabitsProvider` es un provider manual, no `@riverpod`:** riverpod_generator no puede emitir un tipo generado por Drift (`Habit`) como retorno de un provider anotado (orden de generadores). Mezclar codegen + provider manual es válido y se usará igual en sprints siguientes para streams de entidades Drift.
> - **`InkSparkle` → `InkRipple`** en el tema: la chispa dejaba un `Timer` huérfano al desmontar por navegación (rompía tests con "A Timer is still pending") y, además, una chispa no encaja con la estética sobria del brief. Ripple discreto es mejor en ambos frentes.
> - **Home shell mínimo** (`features/home/`) como placeholder hasta el dashboard de Sprint 7; incluye acceso a hábitos y —solo en debug— a la galería (`/gallery`, ruta exenta del gate).
> - **Estabilidad de tests de widget con Drift:** al desmontar, Drift agenda un `Timer(Duration.zero)` (`markAsClosed`) para cerrar sus streams; los tests terminan con `pumpWidget(SizedBox()) + pump(50ms)` para que dispare antes del chequeo de invariantes. Tests con `TextField` usan `pump` en vez de `pumpAndSettle` (timer de parpadeo del cursor). Helper `test/support/test_app.dart`.

**Objetivo:** Permitir que en el primer uso el usuario elija 1-3 hábitos/virtudes a trabajar, sin lenguaje clínico, con el resto de la app bloqueado detrás de este setup mínimo vía redirect del router.

**Tareas técnicas:**
- `features/onboarding/`: intro (framing breve, sin login), selector de virtud/hábito con `SelectableChip`, pantalla de confirmación.
- `features/habits/`: lista de hábitos configurados (con acceso a agregar/archivar), formulario de creación (label + selector de virtud), tope de 3 hábitos activos (constraint a nivel UI/repositorio, no schema — hábitos archivados no cuentan contra el tope).
- Redirect de router: `GoRouter.redirect` chequea un provider (`hasActiveHabitsProvider`, respaldado por `HabitRepository`) — si cero hábitos activos, redirige a `/onboarding` desde cualquier otra ruta.

**Tareas de arquitectura:**
- Métodos `HabitRepository.createHabit`, `.archiveHabit`, `.updateStreakManually` establecidos aquí, reutilizados (no duplicados) por Sprint 4.
- Estado de onboarding completado guardado en `AppMeta`/`UserProfiles` (no inferido solo del conteo de hábitos — un usuario que archiva todos sus hábitos después no debe ser forzado de vuelta a onboarding, eso es un empty-state distinto).

**Tareas de diseño/UX:**
- Copy sin lenguaje clínico/patologizante (nada de "adicción", "trastorno", "programa de recuperación") — usar framing neutro ("qué quieres trabajar", "hábito a moderar").
- Empty-state (del sistema de diseño) para "0 hábitos activos, no es el primer uso" (caso post-archivar-todo), distinto del flujo de onboarding.

**Criterios de aceptación:**
- Instalación limpia (DB vacía) lanza directo a `/onboarding`; no se puede llegar a otra ruta sin completarlo.
- Tras elegir 1-3 hábitos y confirmar, la app llega a la ruta home (placeholder hasta Sprint 7) y no redirige de vuelta.
- Intentar agregar un 4º hábito activo se bloquea en UI con mensaje claro y no punitivo.
- Test de widget cubre el flujo completo de onboarding end-to-end.
- Revisión de copy confirma cero lenguaje clínico en strings user-facing.

**Dependencias:** Sprints 1, 2.

---

## Sprint 4 — Streaks de consistencia + registro de recaída sin culpa

**Objetivo:** Permitir trackear y editar directamente la racha de consistencia por hábito, y registrar una recaída como evento de aprendizaje (contexto/detonante/aprendizaje) sin framing de culpa, sin borrar nunca el historial.

**Tareas técnicas:**
- Pantalla de detalle de hábito: racha actual, acción "registrar hoy" (inserta `HabitCheckIns` success, incrementa racha), número de racha editable directamente (tap-to-edit o stepper, sin fricción de confirmación oculta).
- Flujo de registro de recaída: formulario corto (contexto/detonante/aprendizaje, todos opcionales) que inserta `HabitCheckIns` (status=relapse) + `RelapseEvents` en una transacción; resetea `currentStreakCount` a 0 solo como valor *default* inmediatamente re-editable, nunca un reset bloqueado.
- Vista de historial de consistencia (lista o tira de calendario de `HabitCheckIns`) para que "sin culpa" sea demostrable: recaídas pasadas visibles como dato, no ocultas/borradas.

**Tareas de arquitectura:**
- Extender `HabitRepository` con `logCheckIn(habitId, status)` y `logRelapse(habitId, context, trigger, learning)`, ambos envolviendo el insert de dos tablas en una sola transacción Drift (`db.transaction(...)`).
- Reutilizar el patrón de providers de Sprint 3 (`NotifierProvider` observando streams reactivos de Drift `.watch()`) para displays de racha en vivo.

**Tareas de diseño/UX:**
- Sprint donde más pesa el principio "sin gamificación/sin culpa": sin color rojo, sin lenguaje "rompiste tu racha", sin copy con signos de exclamación. Encabezado del formulario de recaída centrado en aprendizaje ("¿qué pasó, y qué aprendes de esto?"), no en confesión.
- El control de edición de racha debe verse tan de primer nivel como "registrar éxito" — no escondido en un menú de configuración.

**Criterios de aceptación:**
- Registrar una recaída no borra ni muta filas previas de `HabitCheckIns`/`RelapseEvents` (test unitario: sembrar historial, registrar recaída, confirmar conteo/contenido de filas previas sin cambios).
- La racha se puede editar a un valor arbitrario vía UI y persiste tras reiniciar la app.
- Test de widget confirma que el formulario de recaída es alcanzable en ≤2 taps desde el detalle de hábito.
- Revisión de copy: cero lenguaje clínico/de culpa en el flujo de recaída.

**Dependencias:** Sprints 2, 3.

---

## Sprint 5 — Diario de baja fricción (mañana/noche + mood/energy)

**Objetivo:** Shippear el diario tap-primero (voz opcional, texto al final) de mañana y noche exactamente según README 10.1, con mood/energy como registro opcional sin lenguaje clínico, y texto libre siempre opt-in.

**Tareas técnicas:**
- Pantalla matutina: un input único estilo chip para "Hoy depende de mí: ___" (frase corta tipeada o dictada, con tope de caracteres corto para que siga siendo una frase, no un párrafo).
- Pantalla nocturna: 3 `SelectableChip` multi-select pre-escritos (copy exacto de README 10.1), más una affordance colapsada "agregar más" que revela un campo de texto opcional solo con tap explícito — nunca expandido por defecto.
- **Mood/energy** (agregado al MVP por decisión confirmada): selector rápido de 3-5 niveles cualitativos (no escala numérica clínica visible al usuario — ej. "bajo/medio/alto" o íconos sutiles no-emoji), opcional, presente tanto en mañana como noche, un solo tap, consistente con el principio de baja fricción. Mapea a `moodScore`/`energyScore` (Sprint 2).
- Voz: `speech_to_text` para dictado en los campos de texto libre, + `permission_handler` con prompt de permiso de micrófono pedido solo al tocar el ícono de mic (no al abrir la app).
- **Riesgo offline de voz (decidido: best-effort):** `speech_to_text` puede usar reconocimiento en la nube según SO/idioma. Preferir reconocimiento on-device donde el SO lo exponga; si no está disponible, deshabilitar silenciosamente el input de voz y caer a chip/texto (que siempre funciona offline) — nunca bloquear la finalización de una entrada de diario por indisponibilidad de voz. Verificar explícitamente en el dispositivo físico en modo avión antes de dar por cerrado el sprint.

**Tareas de arquitectura:**
- `JournalRepository` con `saveMorningEntry`, `saveEveningEntry(tags, freeText, moodScore, energyScore)`; inserts de `JournalEntryTags` en la misma transacción que la fila de `JournalEntries`.
- Un entry por (fecha, tipo) — índice único Drift (`date`, `type`) para que reabrir el diario del mismo día edite en vez de duplicar.

**Tareas de diseño/UX:**
- Reutilizar `SelectableChip` de Sprint 1 para chips de mood/energy y de reflexión nocturna — no reinventar.
- Verificar en la UI construida que el campo de texto libre nocturno no está visible/expandido en el primer render.
- Afordance de mic con tono cálido/invitante (no un punto rojo pulsante tipo "grabando" con connotación de alarma) — pulso sutil en tono tierra.

**Criterios de aceptación:**
- Entrada matutina completable con un solo tap (frase corta por default o voz) — verificado informalmente en dispositivo contra el target de "10-15 segundos" del README.
- Test de widget confirma que el campo de texto libre nocturno está ausente del árbol hasta que se toca "agregar más".
- Dictado por voz verificado en el dispositivo físico para ambos tipos de entrada; comportamiento offline (modo avión) probado explícitamente y no crashea — la voz se degrada, no cuelga la app.
- Entradas persisten y son recuperables por fecha tras reiniciar la app; guardar dos veces para la misma fecha+tipo actualiza, no duplica.
- Selector de mood/energy es opcional — guardar una entrada sin seleccionarlo funciona sin error.

**Dependencias:** Sprints 1, 2.

---

## Sprint 6 — Modo de crisis (respiración + dicotomía de control)

**Objetivo:** Shippear un flujo de crisis 100% estático y sin IA donde el alivio inmediato (temporizador de respiración / afirmación) siempre precede a cualquier pregunta socrática, según la restricción de orden safety-relevant de README 10.2.

**Tareas técnicas:**
- Contenido estático empaquetado (`assets/content/crisis_content.json`: guion/timing de respiración, texto de afirmación, set pequeño de prompts socráticos post-timer) parseado a modelos Dart inmutables al arrancar — fuera de Drift, igual que la decisión de Sprint 2. JSON en vez de const Dart porque es contenido editable/traducible por alguien no necesariamente cómodo con Dart.
- Widget de temporizador de respiración (patrón simple tipo box-breathing) con `AnimationController`/`Timer` — sin dependencia de paquete de animación externo.
- Punto de entrada a crisis alcanzable en 1-2 taps desde cualquier parte de la app (ícono persistente en el app shell, no escondido en configuración).
- Control de salida "estoy bien ahora" siempre visible durante todo el flujo — nunca atrapar al usuario en un wizard sin escape.

**Tareas de arquitectura:**
- Estado del flujo como sealed class/enum (`CrisisFlowState`: `relief` → `reliefComplete` → `socraticOffered` → `dismissed`) en un `NotifierProvider` local a la pantalla (no estado global de la app).
- El widget de pregunta socrática debe estar estrictamente condicionado a `reliefComplete == true` **en el árbol de widgets mismo** (no solo oculto visualmente), para que la restricción de orden esté forzada estructuralmente.

**Tareas de diseño/UX:**
- Afirmación entregada como declaración calma, no pregunta, durante el alivio (según ejemplo exacto del README). Tratamiento visual más espacioso/calmo de toda la app — sin rojo urgente, sin countdown que se sienta alarmante.
- El prompt socrático post-timer se enmarca como invitación dismissible, nunca avanza automáticamente.

**Criterios de aceptación:**
- Test de widget monta la pantalla de crisis y confirma que el prompt socrático está **ausente** del árbol al render inicial, y **presente** solo después de forzar el estado de timer completado (vía el controller del flujo en el test) — el test más importante de este sprint.
- Modo de crisis alcanzable en ≤2 taps desde el home (placeholder hasta Sprint 7).
- Cero llamadas de red durante todo el flujo (cubierto por el test-guardia offline).
- Contenido de crisis carga desde el JSON empaquetado con cero fetch externo; flujo funciona correctamente en modo avión.

**Dependencias:** Sprint 1; no requiere Sprints 3-5 (puede construirse en paralelo/aislado).

---

## Sprint 7 — Dashboard de virtudes, cita diaria y hardening del MVP

**Objetivo:** Ensamblar la pantalla home alrededor del framing de las cuatro virtudes (no rachas genéricas), agregar la cita diaria estática + pregunta de reflexión, y cerrar el MVP con una auditoría de offline/líneas rojas.

**Tareas técnicas:**
- Pantalla home/dashboard: overview de las 4 virtudes (`VirtueIndicator` de Sprint 1, agregando consistencia de hábitos por virtud), entradas a diario, hábitos, e ícono de crisis (persistente desde Sprint 6).
- Cita diaria: `assets/content/quotes.json` (citas de dominio público — Epicteto/Séneca/Marco Aurelio, README 4.4), repositorio que elige determinísticamente la cita "de hoy" (índice sembrado por fecha, sin necesitar tabla Drift), con pregunta de reflexión emparejada en la misma entrada JSON.
- Test de integración offline-guardia completo, extendiendo el de Sprint 1, cubriendo: onboarding → configuración de hábitos → diario matutino → diario nocturno (incl. intento de voz) → check-in/recaída → modo de crisis → dashboard home. Asertar cero actividad de red.
- Pase final de `flutter analyze` + lint sobre todo el codebase; confirmar que `riverpod_lint` no tiene warnings sin resolver.

**Tareas de arquitectura:**
- Lógica de agregación de virtud (cómo la consistencia por hábito se enrolla en una representación de "progreso" por virtud) en una función pura (`VirtueProgressCalculator`), testeada independiente de widgets — múltiples hábitos pueden mapear a la misma virtud, hábitos archivados probablemente no cuentan.
- Revisar todos los repositorios/providers desde Sprint 2 contra la convención "sin interfaces por testabilidad" — confirmar que no se coló ninguna.

**Tareas de diseño/UX:**
- Confirmar que el dashboard realmente pone al frente las 4 virtudes, no un layout streak-count-first (requisito explícito). Números de racha pueden seguir apareciendo (detalle de hábito, Sprint 4), no como framing primario del dashboard.
- Pase de QA de diseño en todas las pantallas de Sprints 3-6 contra los tokens/componentes de Sprint 1.

**Criterios de aceptación:**
- Dashboard home muestra las 4 virtudes con representación de progreso derivada, + cita diaria y pregunta de reflexión, en instalación fresca post-onboarding.
- Test de integración del recorrido completo pasa con cero actividad de red detectada.
- Auditoría confirma: cero SDK de ads en `pubspec.yaml`, cero pantalla de login/auth en el router, cero paquete de push notifications presente.
- `flutter analyze` sin warnings en todo `app/`.
- App corre el recorrido completo (onboarding → diario → hábitos/streak/recaída → crisis → dashboard) en el dispositivo físico sin crashes, en modo avión.

**Dependencias:** Sprints 3, 4, 5, 6.

---

## Racional de versiones de paquetes (dado `sdk: ^3.12.2`)

El SDK fijado es inusualmente nuevo. Implicación concreta: **no hardcodear números de versión ahora** — usar `flutter pub add <paquete>` en cada caso para que pub resuelva versiones compatibles, y verificar en pub.dev al momento de ejecutar cada sprint.

- **Mayor riesgo:** `drift_dev`, `riverpod_generator` y sus dependencias transitivas compartidas (`build_runner`, `source_gen`, `analyzer`). El tooling de codegen suele ir semanas/meses detrás de releases nuevos del SDK de Dart. Por esto Sprint 0 incluye correr `build_runner build` como gate explícito antes de que Sprint 2 dependa de él — si falla, el fallback es bajar temporalmente el constraint `environment.sdk` a la última versión que esos paquetes soportan oficialmente.
- **Menor riesgo pero verificar igual:** `go_router`, `flutter_riverpod`/`riverpod_annotation` (runtime, suelen seguir el SDK más rápido), `sqlite3_flutter_libs`/`drift_flutter` (revisar notas de release por caveats de Android 14+/versión de iOS), `speech_to_text` (plugin de canal de plataforma — revisar actividad de mantenimiento reciente), `permission_handler`.
- `flutter_lints: ^6.0.0` ya presente — tratar su ruleset como autoritativo para el proyecto.

---

## Seams para Fase 2 (no bloquean, notas breves)

- **`linkedGoalId` nullable en `Habits`:** Fase 2 (Metas de vida) probablemente querrá asociar un hábito a una meta. Agregar la columna ahora evita una migración futura sobre datos de usuario reales. Recomendación por defecto: **no agregarla aún** (mantener Sprint 2 mínimo); es una migración barata de hacer después si hace falta.
- **Virtue como enum vs. tabla:** modelado como enum Dart fijo de 4 valores (Sprint 2), ya que el set es core a la identidad del producto y no se espera que cambie. Si existiera alguna chance de que las 4 virtudes cardinales se reconfiguren/extiendan, una tabla lookup sería más flexible. Recomendación por defecto: **mantener como enum** — la filosofía estoica fija estas 4 virtudes, no es un dato configurable por el usuario.

---

## Verificación end-to-end

- `cd app && flutter analyze && flutter test` debe pasar en cada sprint cerrado.
- Cada sprint corre su propio criterio de aceptación en el dispositivo físico (no solo emulador) al menos una vez antes de considerarse cerrado, dado que el desarrollo ocurre contra un teléfono real.
- El test de integración offline-guardia (introducido Sprint 1, extendido hasta Sprint 7) es la verificación central de la invariante "100% offline" a través de todo el recorrido.

### Archivos críticos
- `app/pubspec.yaml` — stack de dependencias completo desde Sprint 0.
- `app/lib/main.dart` — boilerplate del counter a eliminar en Sprint 0.
- `app/lib/src/core/database/app_database.dart` (nuevo) — schema central Drift, Sprint 0 (smoke) → Sprint 2 (completo).
- `app/lib/src/core/routing/app_router.dart` (nuevo) — GoRouter + redirect de onboarding, crítico para Sprint 3.
- `CLAUDE.md` — mantener sincronizado a medida que se cierren decisiones (ej. Riverpod flavor exacto elegido, confirmación de virtue-as-enum).
