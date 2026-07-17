# Hábitos — configuración y tope de 3 activos

## Qué hace

Permite ver, agregar y archivar los hábitos activos que la persona trabaja. Cada hábito pertenece a una de las cuatro virtudes. Hay un tope de **3 hábitos activos** a la vez (los archivados no cuentan).

## Flujo

- **Lista** (`/habits`): tarjetas de los hábitos activos (nombre + virtud), con acceso a agregar y archivar. Con 0 hábitos activos tras el onboarding, muestra un empty-state cálido (distinto de re-onboardear). Tocar una tarjeta abre el detalle del hábito.
- **Crear** (`/habits/new`): un nombre + una virtud. Si ya hay 3 activos, muestra un mensaje claro y no punitivo y no crea el cuarto.
- **Archivar:** quita el hábito de la lista activa sin borrar su historial.

## Reglas

- El tope de 3 activos es una restricción de **repositorio/UI**, no del esquema. Se valida dentro de una transacción (`createHabit`), así dos creaciones concurrentes no lo saltan; lanza `MaxActiveHabitsException` (que lleva el límite para el mensaje).
- Archivar **nunca borra historial** (check-ins ni recaídas).
- Las cuatro virtudes (`Templanza`, `Coraje`, `Sabiduría`, `Justicia`) son un enum fijo, no configurable por el usuario.

## Datos y archivos

- **Módulo:** `lib/src/features/habits/` (`habits_list_screen.dart`, `habit_form_screen.dart`).
- **Tabla:** `Habits` (`label`, `virtue` como `textEnum`, `currentStreakCount`, `archived`, `sortOrder`).
- **Repositorio:** `HabitRepository` (`createHabit`, `archiveHabit`, `watchActiveHabits`), provider `activeHabitsProvider`.
- **Relacionado:** el detalle del hábito, las rachas y la recaída viven en [streaks-and-relapse.md](streaks-and-relapse.md).
- **Tests:** `test/features/onboarding_flow_test.dart` (bloqueo del 4º hábito), `test/core/database/data_layer_test.dart`.
