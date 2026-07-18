# Hábitos — configuración, registro diario y archivado

## Qué hace

Permite ver, agregar y archivar los hábitos activos que la persona trabaja. Cada hábito pertenece a una de las cuatro virtudes. **No hay tope de hábitos activos** — la recomendación de empezar con pocos es solo copy de onboarding, nunca un bloqueo (decisión 2026-07).

## Flujo

- **Lista** (`/habits`): tarjetas de los hábitos activos (nombre + virtud), con acceso a agregar y archivar. Con 0 hábitos activos tras el onboarding, muestra un empty-state cálido (distinto de re-onboardear). Tocar una tarjeta abre el detalle del hábito.
- **Crear** (`/habits/new`): un nombre + una virtud. Sin límite de cantidad.
- **Archivar:** quita el hábito de la lista activa sin borrar su historial.

## Reglas

- **Un registro de éxito por día natural** (`recordCheckIn`): un segundo éxito el mismo día es un no-op idempotente dentro de la transacción (devuelve el id existente). Las recaídas nunca se limitan y la edición manual del contador sigue libre. El botón muestra "Registrado hoy" (deshabilitado) cuando el día ya está registrado.
- **Archivar exige dos pasos deliberados**: menú ⋯ de la tarjeta → "Archivar hábito" → diálogo de confirmación. Tocar la tarjeta nunca archiva; archivar no borra historia.
- Archivar **nunca borra historial** (check-ins ni recaídas).
- Las cuatro virtudes (`Templanza`, `Coraje`, `Sabiduría`, `Justicia`) son un enum fijo, no configurable por el usuario.

## Datos y archivos

- **Módulo:** `lib/src/features/habits/` (`habits_list_screen.dart`, `habit_form_screen.dart`).
- **Tabla:** `Habits` (`label`, `virtue` como `textEnum`, `currentStreakCount`, `archived`, `sortOrder`).
- **Repositorio:** `HabitRepository` (`createHabit`, `archiveHabit`, `watchActiveHabits`), provider `activeHabitsProvider`.
- **Relacionado:** el detalle del hábito, las rachas y la recaída viven en [streaks-and-relapse.md](streaks-and-relapse.md).
- **Tests:** `test/features/onboarding_flow_test.dart` (bloqueo del 4º hábito), `test/core/database/data_layer_test.dart`.
