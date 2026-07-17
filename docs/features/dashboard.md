# Dashboard de virtudes + cita diaria

## Qué hace

La pantalla de inicio del MVP, enmarcada **alrededor de las cuatro virtudes** (no alrededor de conteos de racha). Muestra la cita del día con su pregunta de reflexión, una vista de las cuatro virtudes derivada de la constancia de los hábitos, y accesos calmos a hábitos, diario y modo de crisis.

## Flujo

Home (`/`), scrollable:

- **Cita del día** + pregunta de reflexión emparejada.
- **Las cuatro virtudes** como cuadrícula 2×2, cada una mostrando un estado de progreso derivado.
- **Accesos:** ver hábitos, reflexión de la mañana / de la noche.
- **Acceso persistente a crisis** ("Un momento de calma"), a un toque.

## Reglas

- **Las virtudes son el framing primario**, no los números de racha (esos viven en el detalle del hábito).
- **Progreso por virtud = función pura.** `VirtueProgressCalculator.fromHabits` mapea la constancia de los hábitos a un estado por virtud:
  - Varios hábitos en una virtud → toma la **mejor** (máxima) constancia (alentador, nunca punitivo).
  - Los **hábitos archivados no cuentan**.
  - Una virtud sin hábito activo se lee como "sin desbastar" (presente y re-construible, nunca vacío).
  - El estado "en reposo" (post-recaída) **no** se deriva aquí: una constancia reseteada a 0 es indistinguible de una nueva a este nivel, así que "en reposo" queda como estado contextual del detalle del hábito. Es widget-independiente y está testeado por separado.
- **Cita diaria determinística:** un índice sembrado por fecha (`pickQuoteForDate`) elige la misma cita todo el día y avanza una por día — sin tabla en Drift. Citas de dominio público (Epicteto, Séneca, Marco Aurelio) con su reflexión, en `quotes.json`.

## Datos y archivos

- **Módulos:** `lib/src/features/home/` (`home_screen.dart`, `virtue_progress_calculator.dart`), `lib/src/features/daily_quote/` (`daily_quote.dart`).
- **Contenido:** `assets/content/quotes.json` (cita + autor + reflexión), cargado por `dailyQuoteProvider` vía `rootBundle`.
- **Enums compartidos:** `Virtue`, `VirtueProgressState`.
- **Tests:** `test/core/dashboard_logic_test.dart` (calculador de virtudes; pick determinístico; validez del JSON; auditoría de líneas rojas), `test/features/dashboard_flow_test.dart` (dashboard muestra 4 virtudes + cita; recorrido completo offline).
