# Modo de crisis — respiración primero, pregunta después

## Qué hace

Un flujo de crisis 100% estático, sin IA y sin red, donde el **alivio inmediato siempre precede a cualquier pregunta**. Alcanzable en un toque desde cualquier parte; con una salida "Estoy bien ahora" siempre visible.

## Flujo

1. **Alivio** — una afirmación calma (una declaración, no una pregunta) + un temporizador de respiración (patrón box-breathing: el círculo crece / sostiene / se encoge).
2. **Reflexión (solo después del alivio)** — al terminar la respiración, aparece una invitación socrática dismissible con una pregunta de reflexión. Nunca avanza sola; la persona elige verla o ignorarla y salir.
3. **Salir** — "Estoy bien ahora" está presente en todos los estados.

## Reglas (relevantes a seguridad)

- **El orden es estructural, no visual.** El widget de la pregunta socrática vive dentro de `if (state.reliefIsComplete)` — está **ausente del árbol de widgets** durante el alivio. Solo el `onComplete` del temporizador puede abrirlo; nunca se muestra una pregunta primero.
- **Sin IA, sin red, sin dependencia externa.** Es contenido estático empaquetado; funciona en modo avión.
- **Acceso nunca bloqueado:** la ruta `/crisis` está exenta del gate de onboarding — nadie en crisis queda atrapado por el setup.
- **Degradación segura:** si el contenido empaquetado no cargara, se muestra una frase de respaldo calma y la salida — nunca una pantalla en blanco.

## Datos y archivos

- **Módulo:** `lib/src/features/crisis/` (`crisis_screen.dart`, `breathing_timer.dart`, `crisis_flow.dart`, `crisis_content.dart`).
- **Estado:** `CrisisFlowState { relief, reliefComplete, socraticOffered, dismissed }` en un notifier `@riverpod` **autoDispose** local a la pantalla.
- **Contenido:** `assets/content/crisis_content.json` (afirmación, guion de respiración, prompts socráticos), parseado a modelos inmutables vía `crisisContentProvider` (fuera de Drift, nunca fetch).
- **Temporizador:** `AnimationController` único, sin paquete de animación externo, sin countdown numérico.
- **Tests:** `test/features/crisis_flow_test.dart` — el más importante: el prompt está **ausente** al render inicial y **presente** solo tras forzar `completeRelief()`; salida siempre visible; JSON empaquetado válido; alcanzable en un toque desde el home.
