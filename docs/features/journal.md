# Diario de baja fricción (mañana / noche + ánimo/energía + voz)

## Qué hace

Un diario de dos momentos —mañana y noche— diseñado para completarse en segundos: primero un toque, con texto opcional al final. Incluye un registro rápido y opcional de ánimo y energía, y dictado por voz opcional en los campos de texto.

## Flujo

- **Reflexión de la mañana** (`/journal/morning`): el prompt "Hoy depende de mí: ___", completable con **un toque** en una frase pre-escrita (o escrita/dictada por la persona, máx. corto). Más ánimo/energía opcional.
- **Reflexión de la noche** (`/journal/evening`): tres chips fijos pre-escritos (multi-select), ánimo/energía opcional, y una **nota de texto libre colapsada** que solo aparece al tocar "Agregar una nota" — nunca expandida por defecto.
- **Ánimo y energía:** selector rápido de un toque, cualitativo (bajo / medio / alto), opcional, presente en ambos momentos. El usuario nunca ve una escala numérica clínica.
- **Voz (opcional):** un micrófono en los campos de texto. Ver [Dictado por voz](#dictado-por-voz).

## Reglas

- **Un toque siempre alcanza.** El texto largo es un extra que la persona elige, nunca al revés. La nota nocturna de texto libre está **ausente del árbol de widgets** hasta que se toca "Agregar una nota".
- **Un registro por (día, tipo).** Un índice único `(date, type)` + upsert: reabrir el mismo día **edita** en vez de duplicar. La fecha se normaliza a medianoche local.
- **Ánimo/energía siempre opcional:** guardar sin seleccionarlos funciona sin error. Se guardan como `moodScore`/`energyScore` (1–3).
- Guardar entrada + tags va en una sola transacción; re-guardar reemplaza los tags, no los apila.

## Dictado por voz

- **Opcional y best-effort.** Un micrófono cálido en el campo de texto (mañana y noche). El permiso de micrófono se pide **solo al tocarlo**, nunca al abrir la app.
- Usa el **reconocedor de voz del sistema** del teléfono (reconoce on-device cuando el SO puede, o en la nube si hace falta) para que funcione en casi cualquier dispositivo. Solo el audio de esta función opcional puede salir del teléfono; el resto de la app sigue 100% offline.
- Si el reconocedor no está disponible (permiso negado o sin motor), el micrófono **se oculta en silencio** y la persona sigue escribiendo — la voz nunca bloquea completar una entrada.
- Las entradas dictadas registran `inputMethod = voice`.
- **Config nativa:** `RECORD_AUDIO` + query de `RecognitionService` (Android); `NSMicrophoneUsageDescription` + `NSSpeechRecognitionUsageDescription` (iOS). *Pendiente para release iOS:* el macro `PERMISSION_MICROPHONE=1` en el Podfile de `permission_handler`.

## Datos y archivos

- **Módulo:** `lib/src/features/journal/` (`morning_screen.dart`, `evening_screen.dart`, `mood_energy_picker.dart`, `speech/dictation.dart`, `speech/mic_button.dart`).
- **Tablas:** `JournalEntries` (índice único `(date, type)`, `moodScore`/`energyScore` nullable, `inputMethod`), `JournalEntryTags` (join).
- **Enums:** `JournalType`, `JournalInputMethod`, `EveningTag`, `QualitativeLevel`.
- **Repositorio:** `JournalRepository` (`saveMorningEntry`, `saveEveningEntry`, `getEntryForDay`).
- **Seam de voz:** `Dictation` (interfaz) + `SpeechDictation` (real) + `dictationProvider` (sobreescrito con fake en tests).
- **Tests:** `test/features/journal_flow_test.dart` (campo nocturno ausente hasta opt-in; mañana en un toque), `test/features/dictation_test.dart` (permiso solo al tocar; texto reconocido al campo; oculta el micrófono si no hay voz), `test/core/database/data_layer_test.dart` (upsert por día, tags, opcionalidad de ánimo/energía).
