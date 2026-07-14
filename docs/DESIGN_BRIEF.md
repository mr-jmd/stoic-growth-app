# Design Brief — Andamio

---

## 1. Tipografía

Dos familias, ambas **OFL** (se empaquetan en `assets/fonts/`, se declaran en `pubspec.yaml`;
**nunca** `google_fonts` en runtime — rompe el offline).

- **Display — Cormorant Garamond** (serif inscripcional). Pesos 400/500/600 + itálica 400/500.
  Uso: saludo, nombres de virtud, citas, y la pregunta de reflexión (en itálica).
- **Cuerpo — Source Sans 3** (humanista sobria). Pesos 400/500/600.
  Uso: toda la UI, labels, chips, navegación.

### Escala tipográfica

| Token | Familia | Tamaño / peso | Uso |
|---|---|---|---|
| `displayGreeting` | Cormorant | 32 / 500 | "Buenos días", títulos de pantalla |
| `virtueName` | Cormorant | 22 / 400–500 | Nombre de virtud en la losa |
| `quote` | Cormorant | 24 / 400, line 1.32 | Cita del día |
| `promptDisplay` | Cormorant | 20 / 500 | "Hoy depende de mí:" |
| `reflection` | Cormorant *italic* | 17 / 400, color `soft` | Pregunta de reflexión |
| `eyebrow` | Source Sans | 10–10.5 / 600, UPPER, tracking .18–.20em, color `faint` | Encabezado de sección ("CITA DE HOY") |
| `eyebrowSub` | Source Sans | 9.5 / 600, UPPER, tracking .16em, color `#a99d88` | Sub-label ("ÁNIMO · OPCIONAL") |
| `body` | Source Sans | 14.5 / 400 | Texto de ítems |
| `chip` | Source Sans | 12.5 / 500 | Chips |
| `attribution` | Source Sans | 11 / 500, color `#8a7f6c` | Autor de la cita |
| `navLabel` | Source Sans | 10 / 500–600 | Etiquetas de navegación |

---

## 2. Paleta base (neutrals tierra/mármol)

| Token | Hex | Rol sugerido en `ColorScheme` |
|---|---|---|
| `ink` | `#2C2822` | `onSurface` (texto principal, negro cálido) |
| `soft` | `#6B6355` | `onSurfaceVariant` (texto secundario) |
| `faint` | `#9A8F7C` | labels terciarios |
| `labelWarm` | `#8A7F6C` / `#A99D88` | labels alternos, nav inactivo |
| `ivory` | `#F3EDE1` | `surface` |
| `card` | `#FAF6EE` | `surfaceContainer` (tarjeta elevada) |
| `bone` | `#EAE1D1` | superficie alterna |
| `line` | `#2C2822` @ 8% | `outline` / divisores |
| `appBg` | radial `#DED5C3` → `#D0C7B3` | fondo de `AppScaffold` (gradiente, no color plano) |
| `slate` | `#5B6B78` | `primary` (interactivo, links) |
| `slatePressed` | `#3F4A54` | `primary` pressed / nav activo |
| `error` | `#9C5A44` (arcilla apagada) | `error` — **solo** para errores reales de input; nunca para recaída ni crisis |

**Nota sobre `ColorScheme.fromSeed`:** sembrar desde `#D7CEBB` y luego **corregir a mano**
`surface`, `surfaceContainer`, `outline` y `error` a los valores de arriba. `fromSeed` solo
tiende a saturar; estos neutrals son deliberadamente apagados.

**Sombras (mármol):** difusas, de bajo contraste, **tinte cálido** `rgba(60,48,30,·)` — nunca
gris/negro neutro.
- `elevCard`: `0 1px 2px /.04`, `0 8px 22px /.05`
- `elevRaised`: `0 1px 2px /.05`, `0 14px 38px /.08`, `0 40px 72px /.05`
- highlight interior en losas/tiles: `inset 0 1px 0 rgba(255,255,255,.2–.55)`

---

## 3. Virtudes: color + estados de progreso

Cuatro acentos apagados, uno por virtud (enum fijo `Virtue { templanza, coraje, sabiduria, justicia }`).
El progreso **no es número ni barra**: es estado del material + una etiqueta cualitativa.

| Virtud | Gradiente "activo/pleno" (158°) | Texto sobre losa |
|---|---|---|
| Templanza (pizarra) | `#7F8B96` → `#5F6D79` | `#F2EFE8` |
| Coraje (arcilla) | `#B07A5F` → `#8A5540` | `#F2EFE8` |
| Sabiduría (oliva) | `#A0A27C` → `#83855C` | `#F4F1E6` |
| Justicia (ocre/bronce) | `#B89A5E` → `#9A824F` | `#F2EFE8` |

### Estados de progreso (metáfora de material)

Escala ascendente de consistencia, más un estado especial de recaída:

| Estado | Etiqueta UI | Render |
|---|---|---|
| Bajo / recién empieza | `sin desbastar` | mármol pálido, tinte más claro de la virtud, texto oscuro-sobre-claro (ej. Justicia `#EDE4D2`→`#E2D5BE`, texto `#9A824F`) |
| Medio | `tomando color` | gradiente a media saturación |
| Alto / constante | `pulida` | gradiente pleno de la virtud, texto claro-sobre-oscuro, highlight y sombra más marcados |
| **Recaída** | `en reposo` | vuelve a **mármol claro cálido** (ej. `#ECDCCD`→`#DDC7B6`, texto `#8A6A56`). **Nunca vacío. Nunca rojo.** Comunica reposo/re-inicio, es re-construible |

El mapeo consistencia → estado lo calcula `VirtueProgressCalculator` (Sprint 7). Este brief
solo define los estados visuales. La losa mide 104px de alto, radio 10px, padding 15px.

---

## 4. Escalas

**Radios** (más contenidos que el mockup 1b original, acordes a piedra tallada):

| Token | px | Uso |
|---|---|---|
| `radiusChip` | 7 | chips |
| `radiusTile` | 10 | losas de virtud, filas de hábito |
| `radiusCard` | 12 | tarjetas (cita, mañana, noche) |
| `radiusAffordance` | 14 | acceso de crisis, botones |

(El frame de 32px del mockup es *chrome de presentación* del teléfono — la app real es
full-bleed, no lleva un contenedor redondeado exterior.)

**Espaciado** (el diseño usa valores ajustados): `4, 8, 12, 14, 16, 20, 24`.
Gap entre tarjetas ≈ 14; padding interno de tarjeta ≈ 20; espacio sobre bloque de virtudes ≈ 24.

---

## 5. Componentes (mapeo directo a Sprint 1)

- **`AppScaffold`** — fondo radial `appBg`, safe areas, hospeda la barra inferior y el
  acceso de crisis persistente.
- **Barra de navegación inferior** — 3 destinos: Hoy / Diario / Hábitos. Activo `#3F4A54`,
  inactivo `#A99D88`; fondo `linear-gradient(180°, transparent, #EFE8DB)`, borde superior `line`.
- **Acceso a modo de crisis** — losa 44px radio 14, fondo `#EFE8DB`, ícono de grounding
  (círculos concéntricos) trazo `#7F8B96`, etiqueta calma. Persistente, alcanzable en ≤2 taps.
  **Nunca rojo, nunca alarma.** (En v2 vive arriba a la derecha del header; confirmar que se
  lee como *entrada a un lugar de calma*, no como indicador de estado.)
- **`SelectableChip`** — radio 7, padding ~6–7 × 12. Objetivo táctil real ≥48dp aunque el
  visual sea menor. Seleccionado = relleno tenue (`#EEF1F0`/texto `#4F5F57`); no seleccionado
  = transparente + borde `line`. Reutilizado en ánimo, energía, chips nocturnos y selección
  de virtud/hábito.
- **`AppCard`** — fondo `card` `#FAF6EE`, radio 12, borde `line`, sombra `elevCard`.
- **`VirtueIndicator`** — la losa de material de §3 (gradiente por estado + nombre Cormorant
  + etiqueta cualitativa). Es el elemento de progreso no-gamificado.
- **Fila de hábito** — fila-tarjeta radio 10; check 22px (hecho = círculo relleno `#7B7D52`
  con check marfil; pendiente = círculo transparente borde `line` reforzado).
- **`AppButton`** — desde tokens: `slate` como acción primaria o neutro cálido, radio ~14,
  sin color estridente.
- **`EmptyState`** — cálido, para el caso "0 hábitos activos".

---

## 6. Reglas duras (invariantes de diseño)

- Sin gamificación: sin emoji de fuego/racha, sin confetti, sin badges/medallas, sin sonidos
  de logro, sin barras de progreso "de juego".
- **Recaída = `en reposo`** (mármol cálido), nunca vacío, nunca rojo, nunca "rompiste tu racha".
- **Crisis** = tratamiento más espacioso y calmo que el resto; nunca rojo ni countdown alarmante.
- El color `error` es solo para errores reales de formulario, apagado, jamás para framing de
  recaída/crisis.
- Copy sin signos de exclamación y sin lenguaje clínico/patologizante.
- Progreso por virtud siempre como estado de material, nunca como puntaje o porcentaje.

---

## 7. Notas de implementación

- Fuentes: vendorizar los `.ttf` OFL (Cormorant Garamond, Source Sans 3) a `assets/fonts/`
  y declararlos en `pubspec.yaml`. Sin fetch en runtime.
- Tokens vía `StoicTokens extends ThemeExtension<StoicTokens>`, aplicados una vez en
  `StoicApp` sobre un único `ThemeData`. Sin overrides de tema por pantalla.
- `Virtue` es enum Dart fijo; sus etiquetas de display y las etiquetas de estado
  (`pulida`, `en reposo`, etc.) van en `app_es.arb`.
- Verificación de Sprint 1: grep de `Color(0x` y de tamaños/fuentes literales fuera de
  `core/design_system/` debe dar vacío.
