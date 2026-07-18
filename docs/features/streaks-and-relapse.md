# Rachas de constancia y recaída sin culpa

## Qué hace

En el detalle de un hábito, la persona ve su constancia (días seguidos), puede **registrar el día de hoy**, **editar el contador directamente**, y **registrar una recaída** como evento de aprendizaje — nunca como fracaso, y sin borrar jamás el historial.

## Flujo

Detalle del hábito (`/habits/:id`):

- **Contador de constancia** editable directamente: botones −/+ y tocar el número para poner un valor arbitrario. La edición es tan visible como registrar; no está escondida en un menú.
- **"Registrar hoy":** agrega un check-in de éxito e incrementa la constancia. **Solo un éxito por día natural**: registrado el día, el botón pasa a "Registrado hoy" (deshabilitado, tono calmo) y volver a llamar `recordCheckIn` es un no-op idempotente (devuelve el id existente). Las recaídas **no** se limitan por día.
- **"Registrar una recaída"** (`/habits/:id/relapse`): un formulario corto con contexto / detonante / aprendizaje, **todos opcionales**, enmarcado en aprendizaje ("¿qué pasó, y qué aprendes de esto?").
- **Historial:** lista append-only de check-ins (éxitos y recaídas), para que "sin culpa" sea demostrable — las recaídas pasadas quedan visibles como dato, no ocultas ni borradas.

## Reglas

- El **historial es append-only**: `HabitCheckIns` y `RelapseEvents` **nunca** se borran ni mutan por un reset.
- **`logRelapse` es atómico**: inserta el check-in de recaída + su evento de aprendizaje + resetea la constancia a 0, todo en una transacción, para que nunca se observe a medias.
- El reset a 0 es solo un **valor por defecto inmediatamente re-editable**, nunca un reset bloqueado.
- **Un éxito por día natural** es un guard de repositorio (dentro de la transacción de `recordCheckIn`, vía `HabitsDao.successCheckInOn` + `shared/dates.dart`) — silencioso, sin excepción. La edición manual del contador queda fuera de la regla (el número es de la persona).
- **Sin culpa, sin gamificación:** sin lenguaje de "rompiste tu racha", sin signos de exclamación. Una recaída es un estado "en reposo", re-construible.
- La constancia editada persiste tras reiniciar la app.

## Datos y archivos

- **Módulo:** `lib/src/features/habits/` (`habit_detail_screen.dart`, `relapse_form_screen.dart`).
- **Tablas:** `HabitCheckIns` (log append-only; `status` éxito/recaída), `RelapseEvents` (contexto/detonante/aprendizaje, ligado al check-in), `Habits.currentStreakCount` (entero editable).
- **Repositorio:** `HabitRepository` (`recordCheckIn`, `logRelapse`, `updateStreakManually`, `watchHabit`, `watchCheckIns`); providers `habitByIdProvider`, `habitCheckInsProvider`.
- **Tests:** `test/core/database/data_layer_test.dart` (recaída atómica, historial intacto), `test/features/habit_detail_flow_test.dart` (recaída alcanzable en ≤2 taps, edición de constancia persiste, registrar hoy).
