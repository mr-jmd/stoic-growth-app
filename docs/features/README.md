# Funcionalidades del MVP

Un documento por funcionalidad del MVP (Fase 1), ya construida y verificada. Cada uno describe qué hace, cómo funciona (flujo, datos, archivos) y las reglas de producto — **sin contenido de diseño visual** (eso se replantea aparte).

| Funcionalidad | Documento | Módulo |
|---|---|---|
| Primer arranque y elección de hábitos | [onboarding.md](onboarding.md) | `features/onboarding/` |
| Configuración de hábitos (tope de 3 activos) | [habits.md](habits.md) | `features/habits/` |
| Rachas de constancia + recaída sin culpa | [streaks-and-relapse.md](streaks-and-relapse.md) | `features/habits/` |
| Diario de baja fricción (mañana/noche + ánimo/energía + voz) | [journal.md](journal.md) | `features/journal/` |
| Modo de crisis (respiración + reflexión) | [crisis-mode.md](crisis-mode.md) | `features/crisis/` |
| Dashboard de virtudes + cita diaria | [dashboard.md](dashboard.md) | `features/home/`, `features/daily_quote/` |

Contexto técnico general: [`../ARCHITECTURE.md`](../ARCHITECTURE.md). Visión de producto: [`../../README.md`](../../README.md).

## El loop del MVP

```
Primer arranque → elegir 1–3 hábitos → Dashboard (4 virtudes + cita)
   ├─ Hábitos → detalle → registrar día / registrar recaída
   ├─ Diario → reflexión de la mañana / de la noche (chips, ánimo, voz opcional)
   └─ Un momento de calma (crisis) → respiración → invitación a reflexionar
```

Todo 100% offline, sin cuenta.
