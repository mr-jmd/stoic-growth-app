# Tour guiado — recorrido por la app real

## Qué hace

Tras completar el onboarding, un recorrido de 6 pasos oscurece la app real y va iluminando cada zona con un foco animado y una tarjeta explicativa (Siguiente / Saltar): virtudes → cita del día → pestaña Hábitos (el tour cambia de pestaña solo) → pestaña Diario → banda de calma → cierre. Se ejecuta **una sola vez** automáticamente; se puede repetir desde el icono `?` junto a la fecha en la portada (Hoy).

## Cómo funciona

- **Código:** `lib/src/features/tour/` — `tour_targets.dart` (GlobalKeys atadas con `KeyedSubtree` en home, lista de hábitos, hub de diario y la banda de calma del shell), `tour_steps.dart` (los 6 pasos con su rama del shell y copy l10n), `tour_controller.dart` (`@riverpod`, estado `int?`: null = inactivo), `tour_overlay.dart` (scrim con recorte animado vía `CustomPaint` + `Path.combine(difference)`, tarjeta posicionada según el rect).
- **Integración:** `AppShell` monta el overlay en un `Stack` sobre todo el shell (barra y banda incluidas) y lo auto-arranca en post-frame cuando `tutorialCompletedProvider` resuelve a `false` (el shell solo existe tras el gate de onboarding, así que eso es el primer aterrizaje).
- **Persistencia:** columna `tutorialCompleted` en la tabla single-row `AppMeta` (esquema **v4**), con el trío watch/is/set en `AppMetaDao` y `TutorialRepository` (mismo patrón que onboarding). Saltar y terminar la marcan por igual.
- **Degradación:** si un target no puede medirse (tras varios reintentos post-frame), la tarjeta se centra sin recorte — el tour nunca crashea ni bloquea.

## Reglas de producto

- Saltable en **todos** los pasos; el scrim absorbe taps pero "Saltar" siempre está a un toque (crisis queda accesible saltando primero).
- Copy calmo, sin exclamaciones; la recaída se nombra como aprendizaje.
- Sin paquetes de terceros (invariante offline + control del diseño).

## Tests

`test/features/tour_flow_test.dart`: auto-arranque tras onboarding, Saltar persiste el flag, el avance cruza a la rama Hábitos, un tour ya visto nunca reaparece. Los tests que aterrizan en el shell usan `completeFirstRun(db)` (`test/support/test_app.dart`) para pre-completar ambos flags.
