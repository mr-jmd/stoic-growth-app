# Onboarding — primer arranque y elección de hábitos

## Qué hace

En el primer uso, guía a la persona por un flujo corto de tres pasos para elegir **al menos un** hábito (sin tope) para trabajar. Sin cuenta, sin login, sin presión. Al terminar, entra al dashboard.

## Flujo

1. **Intro** — framing breve ("Sin cuentas y sin presión…"), un botón "Empezar".
2. **Selección** — hábitos sugeridos agrupados por virtud, elegidos con chips (multi-select, libre desde 1, sin tope). Copy no clínico (`onboarding_suggestions.dart`). Un contador "N elegidos".
3. **Confirmación** — muestra lo elegido; botón "Comenzar" persiste los hábitos y marca el onboarding como completado.

## Reglas

- El estado de onboarding es **persistido, no inferido**: un flag `onboardingCompleted` en `AppMeta` (vía `OnboardingRepository`), expuesto como `onboardingCompletedProvider`.
- El **gate del router** se apoya en ese flag, nunca en el conteo de hábitos. Así, si alguien archiva todos sus hábitos después, ve un empty-state cálido — no se le fuerza a re-onboardear.
- El redirect del router y su `refreshListenable` leen el **mismo** provider para evitar una condición de carrera que dejaba al usuario atascado en la pantalla de confirmación. `StoicApp` muestra un splash hasta que el flag carga.

## Datos y archivos

- **Módulo:** `lib/src/features/onboarding/` (`onboarding_controller.dart`, `onboarding_screen.dart`, `onboarding_suggestions.dart`).
- **Persistencia:** `AppMetaDao` (fila única) + `OnboardingRepository`.
- **Router:** ruta `/onboarding`, gate en `core/routing/app_router.dart`.
- **Tests:** `test/features/onboarding_flow_test.dart` (instalación limpia → onboarding; completar → home sin rebote).
