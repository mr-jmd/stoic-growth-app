# Design Brief — Andamio

> **Modo claro + oscuro desde Sprint 1.** Este brief define un único sistema de material
> con dos temas: **claro = "mármol pulido"**, **oscuro = "basalto pulido"** (la contraparte
> nocturna de la misma piedra). Los tokens de forma, espacio y tipografía son **compartidos**
> entre ambos; solo **color y elevación/sombra** se bifurcan por `Brightness`. Cualquier valor
> con sufijo *(claro)* / *(oscuro)* vive centralizado en `core/design_system/` — nunca en código
> de feature.

---

## 1. Tipografía

Dos familias, ambas **OFL** (se empaquetan en `assets/fonts/`, se declaran en `pubspec.yaml`;
**nunca** `google_fonts` en runtime — rompe el offline). La tipografía es **mode-agnóstica**:
mismos tamaños, pesos y tracking en claro y oscuro. Solo cambia el **color** de cada rol (los
tokens `soft`, `faint`, etc. tienen su valor por modo — ver §2).

- **Display — Cormorant Garamond** (serif inscripcional). Pesos 400/500/600 + itálica 400/500.
  Uso: saludo, nombres de virtud, citas, y la pregunta de reflexión (en itálica).
- **Cuerpo — Source Sans 3** (humanista sobria). Pesos 400/500/600.
  Uso: toda la UI, labels, chips, navegación.

### Escala tipográfica

| Token | Familia | Tamaño / peso | Color (rol) | Uso |
|---|---|---|---|---|
| `displayGreeting` | Cormorant | 32 / 500 | `ink` | "Buenos días", títulos de pantalla |
| `virtueName` | Cormorant | 22 / 400–500 | según losa | Nombre de virtud en la losa |
| `quote` | Cormorant | 24 / 400, line 1.32 | `ink` | Cita del día |
| `promptDisplay` | Cormorant | 20 / 500 | `ink` | "Hoy depende de mí:" |
| `reflection` | Cormorant *italic* | 17 / 400 | `soft` | Pregunta de reflexión |
| `eyebrow` | Source Sans | 10–10.5 / 600, UPPER, tracking .18–.20em | `faint` | Encabezado de sección ("CITA DE HOY") |
| `eyebrowSub` | Source Sans | 9.5 / 600, UPPER, tracking .16em | `eyebrowSub` (§2) | Sub-label ("ÁNIMO · OPCIONAL") |
| `body` | Source Sans | 14.5 / 400 | `ink` | Texto de ítems |
| `chip` | Source Sans | 12.5 / 500 | según chip | Chips |
| `attribution` | Source Sans | 11 / 500 | `attribution` (§2) | Autor de la cita |
| `navLabel` | Source Sans | 10 / 500–600 | nav activo/inactivo (§2) | Etiquetas de navegación |

> **Nota de contraste en oscuro:** los roles terciarios (`faint`, `eyebrowSub`, `attribution`)
> son los que más riesgo tienen de caer bajo WCAG AA en oscuro, porque son texto pequeño y tenue.
> Sus valores de oscuro (§2) se subieron deliberadamente en luminancia respecto a un simple
> "aclarar el valor claro". Objetivo: `body`/`soft` ≥ 4.5:1 y display/eyebrow ≥ 3:1 sobre su
> superficie en **ambos** modos.

---

## 2. Paleta base

La paleta se define como **pares (claro, oscuro)** por token. En `ColorScheme` cada rol resuelve
al valor del modo activo. Regla dura: en oscuro **nunca** negro/gris neutro (`#000`, `#121212`) —
es piedra oscura **cálida**, con el mismo undertone tierra que el claro.

### 2.1 Texto

| Token | Claro | Oscuro | Rol en `ColorScheme` |
|---|---|---|---|
| `ink` | `#2C2822` | `#EDE6D8` | `onSurface` (texto principal) |
| `soft` | `#6B6355` | `#B7AD9C` | `onSurfaceVariant` (secundario) |
| `faint` | `#9A8F7C` | `#968C79` | labels terciarios |
| `labelWarm` | `#8A7F6C` | `#9A8F7C` | labels alternos |
| `attribution` | `#8A7F6C` | `#9C927E` | autor de la cita |
| `eyebrowSub` | `#A99D88` | `#928873` | sub-label de sección |
| `navInactive` | `#A99D88` | `#7C7360` | nav inactivo |

### 2.2 Superficies

| Token | Claro | Oscuro | Rol en `ColorScheme` |
|---|---|---|---|
| `ivory` | `#F3EDE1` | `#1E1A16` | `surface` |
| `card` | `#FAF6EE` | `#26221D` | `surfaceContainer` (tarjeta elevada) |
| `bone` | `#EAE1D1` | `#2E2822` | superficie alterna |
| `containerHigh` | — (usa `card`) | `#322C25` | superficie elevada / base de crisis |
| `line` | `#2C2822` @ 8% | `#EDE6D8` @ 8% | `outline` / divisores |
| `appBg` | radial `#DED5C3` → `#D0C7B3` | radial `#1F1B17` → `#17140F` | fondo de `AppScaffold` (gradiente, no color plano) |

### 2.3 Interactivo / estado

| Token | Claro | Oscuro | Rol |
|---|---|---|---|
| `slate` | `#5B6B78` | `#8FA2B0` | `primary` (interactivo, links) |
| `slatePressed` | `#3F4A54` | `#A9BBC7` | `primary` pressed / nav activo |
| `error` | `#9C5A44` (arcilla apagada) | `#C77E63` (arcilla clara apagada) | `error` — **solo** errores reales de input; nunca recaída ni crisis, en ningún modo |

> **`slate` en oscuro se aclara**, no se oscurece: sobre fondo oscuro el interactivo necesita subir
> luminancia para leerse como "tocable / link". El "pressed/activo" en oscuro es aún **más claro**
> que el resting (al revés que en claro), porque activo = "encendido".

**Nota sobre `ColorScheme.fromSeed`:** sembrar desde `#D7CEBB` para el tema claro
(`brightness: light`) y desde el mismo seed con `brightness: dark` para el oscuro; en **ambos casos
corregir a mano** `surface`, `surfaceContainer`, `outline`, `primary` y `error` a los valores de
arriba. `fromSeed` tiende a saturar en los dos modos; estos neutrals son deliberadamente apagados.

**Sombras (mármol / basalto):**
- **Claro** — difusas, de bajo contraste, **tinte cálido** `rgba(60,48,30,·)`, nunca gris/negro neutro:
  - `elevCard`: `0 1px 2px /.04`, `0 8px 22px /.05`
  - `elevRaised`: `0 1px 2px /.05`, `0 14px 38px /.08`, `0 40px 72px /.05`
  - highlight interior en losas/tiles: `inset 0 1px 0 rgba(255,255,255,.2–.55)`
- **Oscuro** — la elevación se comunica **sobre todo por el escalón de luminancia** de
  `surfaceContainer` (ivory→card→containerHigh) **+ hairline `line` + inner-highlight**; la drop
  shadow es secundaria y usa **negro cálido**, nunca negro puro:
  - `elevCard`: border `1px` `line`; `0 1px 2px rgba(8,6,3,.5)`, `0 10px 26px rgba(8,6,3,.35)`; `inset 0 1px 0 rgba(255,255,255,.04)`
  - `elevRaised`: border `1px` `line`; `0 2px 4px rgba(8,6,3,.55)`, `0 18px 44px rgba(8,6,3,.4)`; `inset 0 1px 0 rgba(255,255,255,.06)`

---

## 3. Virtudes: color + estados de progreso

Cuatro acentos apagados, uno por virtud (enum fijo `Virtue { templanza, coraje, sabiduria, justicia }`).
El progreso **no es número ni barra**: es estado del material + una etiqueta cualitativa.

**Inversión de luminancia entre modos (semántica idéntica):** en **claro** el estado bajo
(`sin desbastar`) es mármol **pálido** y sube en color hacia `pulida`. En **oscuro** eso se leería
al revés (una losa brillante = "pleno"), así que el estado bajo es piedra **apagada y oscura**, y
`pulida` es cuando la piedra **toma luz** (sube croma + un punto de luminancia + highlight interior
más marcado). Mismo orden cualitativo, dirección de luminancia invertida. La etiqueta UI
(`sin desbastar` / `tomando color` / `pulida` / `en reposo`) es la misma en ambos modos.

### 3.1 Gradiente "activo/pleno" (`pulida`, 158°)

| Virtud | Claro | Oscuro | Texto sobre losa (ambos) |
|---|---|---|---|
| Templanza (pizarra) | `#7F8B96` → `#5F6D79` | `#78848F` → `#586572` | `#F2EFE8` |
| Coraje (arcilla) | `#B07A5F` → `#8A5540` | `#A67256` → `#854F3B` | `#F2EFE8` |
| Sabiduría (oliva) | `#A0A27C` → `#83855C` | `#9A9C77` → `#7E8058` | `#F4F1E6` |
| Justicia (ocre/bronce) | `#B89A5E` → `#9A824F` | `#B4965A` → `#96804C` | `#F2EFE8` |

### 3.2 Estados de progreso (metáfora de material)

Escala ascendente de consistencia, más un estado especial de recaída. `tomando color` (medio) es
siempre el gradiente de la virtud a **media saturación** (interpolación entre `sin desbastar` y
`pulida`), en ambos modos — no lleva hex propio.

**`sin desbastar` (bajo / recién empieza):**

| Virtud | Claro (mármol pálido, texto oscuro-sobre-claro) | Oscuro (piedra apagada, texto tinte-de-virtud) |
|---|---|---|
| Templanza | — tinte claro de la virtud | `#33383D` → `#2A2E33`, texto `#8A97A2` |
| Coraje | — tinte claro de la virtud | `#3A322D` → `#2F2823`, texto `#A9765F` |
| Sabiduría | — tinte claro de la virtud | `#34362C` → `#2B2C24`, texto `#9D9E7B` |
| Justicia | `#EDE4D2` → `#E2D5BE`, texto `#9A824F` | `#38311F` → `#2E281A`, texto `#B89A5E` |

> (En claro, cada virtud usa su propio tinte pálido análogo al ejemplo de Justicia; en oscuro, su
> propia piedra apagada tinteada. El principio es el mismo: la virtud está *presente pero sin
> trabajar*.)

**`pulida` (alto / constante):** gradiente pleno de §3.1 (texto claro-sobre-oscuro), highlight y
sombra más marcados. En oscuro es el estado de **mayor luminancia** de la losa.

**`en reposo` (recaída) — virtud-independiente, en ambos modos:**

| | Render |
|---|---|
| Claro | mármol claro cálido `#ECDCCD` → `#DDC7B6`, texto `#8A6A56` |
| Oscuro | piedra cálida en reposo `#332B24` → `#28211B`, texto `#C0A488` |

**Nunca vacío. Nunca rojo. Nunca negro plano.** Comunica reposo / re-inicio; es re-construible.
En oscuro es una piedra cálida apagada, no un hueco.

El mapeo consistencia → estado lo calcula `VirtueProgressCalculator` (Sprint 7) y es
**brightness-agnóstico**: devuelve solo el estado cualitativo. La selección de gradiente
claro/oscuro la hace el render leyendo `Theme.of(context).brightness` (o los tokens del tema
activo). La losa mide 104px de alto, radio 10px, padding 15px, en ambos modos.

---

## 4. Escalas (compartidas entre modos)

Radios y espaciado **no cambian** con el tema.

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

Todos los componentes leen color/elevación de `Theme.of(context)` (`ColorScheme` + `StoicTokens`),
así que soportan ambos modos sin ramas de `if (isDark)` en el widget. Donde el tratamiento por modo
difiere de forma no obvia, se anota abajo.

- **`AppScaffold`** — fondo radial `appBg` (claro u oscuro según tema), safe areas, hospeda la barra
  inferior y el acceso de crisis persistente.
- **Barra de navegación inferior** — 3 destinos: Hoy / Diario / Hábitos.
  - Claro: activo `#3F4A54`, inactivo `#A99D88`; fondo `linear-gradient(180°, transparent, #EFE8DB)`, borde superior `line`.
  - Oscuro: activo `#A9BBC7`, inactivo `#7C7360`; fondo `linear-gradient(180°, transparent, #201C18)`, borde superior `line`.
- **Acceso a modo de crisis** — losa 44px radio 14, ícono de grounding (círculos concéntricos), etiqueta calma. Persistente, alcanzable en ≤2 taps. **Nunca rojo, nunca alarma, en ningún modo.**
  - Claro: fondo `#EFE8DB`, trazo del ícono `#7F8B96`.
  - Oscuro: fondo `#242A2E` (un "charco de calma" ligeramente más frío/luminoso que su entorno cálido-oscuro), trazo del ícono `#8FA2B0`. Confirmar que se lee como *entrada a un lugar de calma*, no como indicador de estado ni como algo apagado/desactivado.
- **`SelectableChip`** — radio 7, padding ~6–7 × 12. Objetivo táctil real ≥48dp aunque el visual sea menor.
  - Claro: seleccionado = relleno tenue `#EEF1F0` / texto `#4F5F57`; no seleccionado = transparente + borde `line`.
  - Oscuro: seleccionado = relleno tenue `#28322E` / texto `#AEC3B8`; no seleccionado = transparente + borde `line`.
  - Reutilizado en ánimo, energía, chips nocturnos y selección de virtud/hábito.
- **`AppCard`** — fondo `card`, radio 12, borde `line`, sombra `elevCard`. En oscuro la separación
  del fondo la da el escalón `surface → surfaceContainer` + hairline + inner-highlight, no la sombra.
- **`VirtueIndicator`** — la losa de material de §3 (gradiente por estado y por modo + nombre
  Cormorant + etiqueta cualitativa). Es el elemento de progreso no-gamificado.
- **Fila de hábito** — fila-tarjeta radio 10; check 22px.
  - Claro: hecho = círculo relleno `#7B7D52` con check marfil; pendiente = círculo transparente borde `line` reforzado.
  - Oscuro: hecho = círculo relleno `#8D8F5F` con check `#EDE6D8`; pendiente = transparente borde `line` reforzado.
- **`AppButton`** — desde tokens: `slate` como acción primaria o neutro cálido, radio ~14, sin color
  estridente en ningún modo.
- **`EmptyState`** — cálido, para el caso "0 hábitos activos"; cálido-oscuro en modo oscuro (nunca
  frío/vacío).

---

## 6. Reglas duras (invariantes de diseño — aplican en ambos modos)

- Sin gamificación: sin emoji de fuego/racha, sin confetti, sin badges/medallas, sin sonidos de
  logro, sin barras de progreso "de juego".
- **Recaída = `en reposo`** (piedra cálida: mármol en claro, basalto cálido en oscuro), nunca vacío,
  nunca rojo, **nunca negro plano**, nunca "rompiste tu racha".
- **Crisis** = tratamiento más espacioso y calmo que el resto; nunca rojo ni countdown alarmante; en
  oscuro se lee como charco de calma, nunca como algo apagado/deshabilitado.
- El color `error` es solo para errores reales de formulario, apagado en ambos modos, jamás para
  framing de recaída/crisis.
- Copy sin signos de exclamación y sin lenguaje clínico/patologizante.
- Progreso por virtud siempre como estado de material, nunca como puntaje o porcentaje.
- **Modo oscuro = piedra oscura cálida**, nunca negro/gris neutro (`#000`, `#121212`, `Colors.black`).
  El undertone tierra se conserva en superficies, sombras y texto.

---

> **Estado: implementado en Sprint 1.** Este brief es intención de diseño; el sistema (tokens duales,
> temas claro/oscuro, componentes, galería debug-only) ya vive en `app/lib/src/core/design_system/`.
> Dos notas donde la implementación concreta difiere/precisa el brief:
> - **Fuentes = variable fonts.** Google Fonts ya solo publica Cormorant Garamond y Source Sans 3 como
>   *variable fonts* (eje `wght`); se vendorizaron esos VF (no instancias estáticas). Flutter mapea
>   `fontWeight`→`wght` y los tokens fijan además `FontVariation('wght', …)`. El requisito duro —
>   vendorizar OFL, sin `google_fonts` runtime — se cumple igual.
> - **Tonos claros de `sin desbastar`** para Templanza/Coraje/Sabiduría (§3.2 solo daba Justicia
>   explícito) se derivaron como tintes pálidos análogos y viven en `tokens/palette.dart`. Son
>   candidatos a afinar visualmente en device.

## 7. Notas de implementación

- Fuentes: vendorizar los `.ttf` OFL (Cormorant Garamond, Source Sans 3) a `assets/fonts/` y
  declararlos en `pubspec.yaml`. Sin fetch en runtime. Las fuentes son compartidas por ambos temas.
  (Implementación real: los `.ttf` son *variable fonts* con eje `wght` — ver nota de estado arriba.)
- `Virtue` es enum Dart fijo; sus etiquetas de display y las etiquetas de estado (`pulida`,
  `en reposo`, etc.) van en `app_es.arb`. Las etiquetas de estado son las mismas en claro y oscuro.
- Verificación de Sprint 1 (ampliada por el modo oscuro):
  - grep de `Color(0x` y de tamaños/fuentes literales fuera de `core/design_system/` debe dar vacío;
  - grep de `Colors.black` / `Colors.white` en `features/` y `shared/` debe dar vacío — las
    elecciones dependientes de brightness se resuelven vía tokens / `ColorScheme`, nunca con literales;
  - grep de `Brightness.` / `MediaQuery.platformBrightnessOf` dentro de código de feature debe dar
    vacío — solo el design system y `StoicApp` conocen el brightness; los widgets leen roles resueltos.

---

## 8. Arquitectura de theming (impacto en Sprint 1)

Integrar modo oscuro cambia la tarea de arquitectura de Sprint 1 de *"un solo `ThemeData`"* a
*"dos `ThemeData` desde una sola fuente de tokens"*. El resto del sprint (i18n, componentes,
galería) no cambia de forma sustancial.

### 8.1 `MaterialApp.router`

```dart
MaterialApp.router(
  theme: stoicLightTheme,      // ThemeData.light() base + ColorScheme claro + StoicTokens.light()
  darkTheme: stoicDarkTheme,   // ThemeData.dark()  base + ColorScheme oscuro + StoicTokens.dark()
  themeMode: themeMode,        // ver §8.4
  ...
)
```

Ambos `ThemeData` se construyen **una sola vez** desde la misma tabla de tokens; sin overrides de
tema por pantalla en sprints posteriores sin justificación (invariante que se mantiene).

### 8.2 `StoicTokens` mode-aware

`StoicTokens extends ThemeExtension<StoicTokens>` gana dos factories: `StoicTokens.light()` y
`StoicTokens.dark()`. Recomendación de estructura para no duplicar lo que no cambia:

- **Compartido (una sola definición, referenciada por ambos factories):** escala de espaciado,
  escala de radios, familias tipográficas y la escala de tamaños/pesos/tracking de §1.
- **Por modo (difiere entre `.light()` y `.dark()`):** el sub-objeto de color (superficies, texto,
  interactivo, `error`), el mapa de gradientes de virtud por estado, y los tokens de
  elevación/sombra.

`lerp` debe interpolar los campos por-modo para que un cambio de tema (o un `AnimatedTheme`) haga
cross-fade suave en vez de un salto duro. Los campos compartidos se devuelven tal cual (no
interpolan).

### 8.3 `ColorScheme` por modo

Construir cada esquema desde el seed `#D7CEBB` con su `brightness`, y **corregir a mano** los roles
listados en §2 (`surface`, `surfaceContainer`, `outline`, `primary`, `error`). `fromSeed` sobre-satura
en ambos modos; estos neutrals son intencionalmente apagados. Los widgets de feature leen
`colorScheme.onSurface`, `colorScheme.primary`, etc. — nunca hex — de modo que el mismo widget
funciona en los dos temas sin ramas.

### 8.4 `ThemeMode` — decisión de scope para Sprint 1

Dos caminos; el brief recomienda el primero para Sprint 1 y deja el segundo como follow-up aditivo:

- **Recomendado — `ThemeMode.system` (Sprint 1):** respeta el ajuste del OS, **cero persistencia
  nueva**, no toca el schema de Drift, no agrega pantalla de settings. Encaja con el MVP mínimo del
  plan. El sistema entero ya queda mode-aware; solo falta el switch manual.
- **Follow-up — toggle manual (aditivo, no bloquea):** persistir un enum `themeMode`
  (`system` / `light` / `dark`) en `AppMeta` (columna nueva, migración barata), exponerlo con un
  provider (`themeModeProvider`) y pasarlo a `MaterialApp.router(themeMode: ...)`. Un solo
  `SelectableChip`-group en una futura pantalla de ajustes lo controla. No requiere red, cuenta ni
  push — respeta todas las invariantes del plan.

Mientras no exista el toggle, `ThemeMode.system` garantiza que un usuario con el teléfono en oscuro
ya vea "basalto pulido" desde el primer arranque.

### 8.5 Galería de componentes (criterio de aceptación ampliado)

La pantalla-galería debug-only debe renderizar todos los componentes base y los 4 colores de virtud
**en ambos modos**, con un toggle de brightness local a la galería (no cambia el tema global de la
app). Es la verificación visual de que ningún componente asume un modo. El resto de criterios de
Sprint 1 (analyze sin warnings, cero literales fuera del design system, todo string vía
`AppLocalizations`, cero red vía test-guardia) se mantienen y se extienden con los greps de §7.
