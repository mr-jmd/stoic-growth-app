# stoic-growth-app

**Aplicación de crecimiento personal, físico y espiritual basada en principios estoicos.**

> **Nombre por definir.** `stoic-growth-app` es un nombre de trabajo/placeholder para el repositorio, no el nombre final de marca. Las dos opciones en evaluación, verificadas sin colisión de marca ni cultural, son **Andamio** y **Virtude**. Ver [sección 12](#12-naming) para el historial completo de nombres evaluados y descartados.

Documento técnico de propuesta — julio de 2026

---

## Tabla de contenido

1. [Resumen ejecutivo](#1-resumen-ejecutivo)
2. [Visión del producto](#2-visión-del-producto)
3. [Problema y oportunidad de mercado](#3-problema-y-oportunidad-de-mercado)
4. [Propuesta funcional](#4-propuesta-funcional)
5. [Diferenciación frente al mercado](#5-diferenciación-frente-al-mercado)
6. [Arquitectura técnica recomendada](#6-arquitectura-técnica-recomendada)
7. [Modelo de datos inicial](#7-modelo-de-datos-inicial)
8. [Roadmap recomendado](#8-roadmap-recomendado)
9. [Modelo de monetización](#9-modelo-de-monetización)
10. [UX de journaling y flujo del Interlocutor](#10-ux-de-journaling-y-flujo-del-interlocutor)
11. [Moat competitivo y estrategia go-to-market](#11-moat-competitivo-y-estrategia-go-to-market)
12. [Naming](#12-naming)
13. [Riesgos y mitigación](#13-riesgos-y-mitigación)
14. [Próximos pasos concretos](#14-próximos-pasos-concretos)
15. [Conclusión](#15-conclusión)
16. [Historial de actualizaciones](#historial-de-actualizaciones)

---

## 1. Resumen ejecutivo

Se propone el desarrollo de una aplicación móvil de crecimiento personal integral basada en la filosofía estoica clásica (Epicteto, Séneca, Marco Aurelio), referida en este documento por su nombre de trabajo, `stoic-growth-app`. A diferencia de las apps de bienestar tradicionales que tratan la meditación, los hábitos, el ejercicio y la disciplina como categorías separadas, la app las organiza bajo un único marco filosófico coherente: las tres disciplinas estoicas del deseo, la acción y el juicio.

El objetivo no es competir función por función contra apps ya consolidadas de mindfulness, hábitos o sobriedad, sino ofrecer algo que ninguna de ellas tiene: una narrativa de vida completa, con principios de más de dos mil años de antigüedad, aplicados a los problemas modernos de dispersión, dependencia, baja disciplina y falta de propósito.

Este documento consolida la propuesta original con tres resoluciones críticas de viabilidad: el modelo de monetización frente al costo de IA, el rediseño de fricción en UX, y la definición de un moat competitivo defendible.

---

## 2. Visión del producto

La app parte de una idea central del estoicismo: no controlamos lo que nos pasa, pero sí controlamos cómo actuamos y cómo interpretamos lo que pasa. Toda la arquitectura de la aplicación se organiza alrededor de esa distinción.

> "No son las cosas las que perturban a los hombres, sino los juicios que se hacen sobre ellas." — Epicteto (parafraseado)

La app no vende calma instantánea ni gamificación superficial. Vende un sistema de entrenamiento diario del carácter, con métricas basadas en virtudes clásicas en vez de solo rachas y puntos.

### 2.1 Las tres disciplinas como arquitectura

Epicteto describió tres disciplinas que un practicante estoico entrena a diario. La app traduce cada una a un pilar funcional concreto:

| Disciplina estoica | Qué entrena | Módulo en la app |
|---|---|---|
| Disciplina del deseo | Qué persigo y qué evito; dejar de desear lo que no depende de mí | Hábitos, adicciones y templanza |
| Disciplina de la acción | Actuar con virtud en el mundo, no solo tener buenas intenciones | Rutinas, disciplina física y trabajo con propósito |
| Disciplina del juicio | Cómo interpreto lo que me pasa; control de la narrativa interna | Journaling, mindfulness y reflexión guiada |

### 2.2 Las cuatro virtudes como sistema de progreso

En vez de un contador de días o una racha genérica, el progreso del usuario se mide en relación a las cuatro virtudes cardinales estoicas:

- **Templanza** — moderación frente a impulsos: sustancias, redes, consumo compulsivo, pantallas.
- **Coraje** — incomodidad voluntaria: ejercicio, frío, disciplina física, enfrentar tareas difíciles.
- **Sabiduría** — reflexión, journaling, aprendizaje, dicotomía de control.
- **Justicia** — relaciones, comunidad, cómo trato a otros, integridad en el trabajo.

---

## 3. Problema y oportunidad de mercado

El mercado actual de bienestar está fragmentado: Calm y Headspace dominan meditación premium; I Am Sober y Sobriety cubren solo seguimiento de abstinencia; Habitify y similares cubren hábitos genéricos sin profundidad filosófica. Ninguna ofrece un marco de sentido que conecte la disciplina diaria con un propósito de vida mayor.

El estoicismo práctico vive hoy un momento de adopción cultural fuerte, pero casi toda esa demanda se satisface con contenido pasivo (libros, videos, citas en redes) y no con una herramienta de práctica diaria estructurada. Esa es la brecha que ocupa esta propuesta.

### 3.1 Público objetivo

- **Primario:** adultos jóvenes (22-40 años) que buscan disciplina, dejar hábitos que los estancan (consumo, procrastinación, dispersión) y construir un sistema de vida más firme.
- **Secundario:** personas ya interesadas en estoicismo, filosofía práctica, desarrollo personal y comunidades de disciplina física/mental.
- **Terciario:** personas en procesos de recuperación de hábitos o sustancias que buscan un marco de sentido, no solo un contador clínico.

---

## 4. Propuesta funcional

### 4.1 Diario del estoico (disciplina del juicio)

- Reflexión matutina: "¿qué depende de mí hoy?"
- Reflexión nocturna al estilo de Marco Aurelio: qué hice bien, qué hice mal, qué corrijo mañana.
- Premeditatio malorum guiada: visualización breve de adversidad para entrenar resiliencia.
- Registro de estado de ánimo y energía, sin lenguaje clínico.

> Ver [sección 10](#10-ux-de-journaling-y-flujo-del-interlocutor) para el rediseño de baja fricción de este módulo.

### 4.2 Templanza (control de hábitos y consumo)

- Configuración de hábitos o sustancias a moderar o dejar, sin lenguaje patologizante.
- Contadores de racha por categoría, editables y sin culpa en caso de recaída.
- Modo de crisis: ejercicio de respiración, dicotomía de control aplicada al impulso, y "pausa estoica" de 10 minutos antes de actuar.
- Registro de recaídas como aprendizaje, no como fracaso — coherente con la idea estoica de progreso, no perfección (*prokopé*).

### 4.3 Coraje (cuerpo y disciplina)

- Rutinas de activación física básicas, con seguimiento de consistencia, no de rendimiento competitivo.
- Retos de incomodidad voluntaria opcionales: duchas frías, ayuno breve, madrugar.
- Bloques de trabajo profundo con temporizador, ligados a la idea de disciplina como forma de libertad.

### 4.4 Sabiduría (aprendizaje y propósito)

- Cita o principio estoico diario con una pregunta de aplicación práctica al día del usuario.
- Metas de vida por área: salud, trabajo, relaciones, finanzas, carácter.
- Biblioteca breve de textos clásicos adaptados a lenguaje moderno (dominio público: Epicteto, Séneca, Marco Aurelio).

### 4.5 El Interlocutor (agente de IA)

A diferencia de un chatbot de soporte emocional genérico, el agente de esta app está diseñado como un interlocutor socrático: hace preguntas, no da diagnósticos ni consejos afectivos.

- Preguntas guía: "¿esto depende de ti?", "¿qué haría alguien con carácter firme aquí?"
- Nunca diagnostica, nunca receta, nunca finge ser humano ni busca vínculo afectivo.
- Ante señales de riesgo alto (autolesión, crisis grave) deriva de inmediato a líneas de ayuda humana, sin intentar resolver la conversación.
- Tono: firme, sobrio, cercano — como un mentor, no como un amigo virtual.

> Ver [sección 10](#10-ux-de-journaling-y-flujo-del-interlocutor) para el rediseño del orden de respuesta en momentos de crisis.

---

## 5. Diferenciación frente al mercado

| Competidor | Qué valida | Lo que esta propuesta hace distinto |
|---|---|---|
| Calm / Headspace | Demanda masiva de contenido guiado | Marco filosófico propio en vez de contenido genérico de relajación |
| I Am Sober / Sobriety | Seguimiento de abstinencia | Integra la recuperación como una virtud (templanza), no como producto único |
| Habitify / Streaks | Estructura de hábitos | Conecta el hábito con un propósito de vida y un marco de sentido |
| Apps de "estoicismo diario" | Interés cultural creciente por el estoicismo | Pasan de citas pasivas a práctica diaria estructurada y medible |

> El marco filosófico por sí solo es replicable por un competidor con presupuesto. Ver [sección 11](#11-moat-competitivo-y-estrategia-go-to-market) para el moat real.

---

## 6. Arquitectura técnica recomendada

El criterio de selección es exclusivamente técnico: mejor rendimiento, mejor consistencia visual entre Android e iOS, y mejor capacidad de escalar a futuro.

### 6.1 Frontend móvil

- **Recomendado: Flutter (Dart).** Motor de renderizado propio (Impeller/Skia), lo que garantiza que la interfaz se vea y se sienta exactamente igual en Android e iOS sin depender de componentes nativos de cada plataforma. Rendimiento cercano al nativo, animaciones fluidas de fábrica —clave para ejercicios de respiración, transiciones y journaling— y una sola base de código real. Precedente directo: **Medito**, la app de bienestar gratuita y open source usada como referencia de mercado, está construida en Flutter, con arquitectura y tamaño de equipo comparables a los de este proyecto.
- **Alternativa considerada: React Native (New Architecture).** Ecosistema JavaScript muy grande y mucha disponibilidad de talento, pero sigue dependiendo de un puente hacia componentes nativos, lo que introduce más variabilidad visual entre plataformas y más fricción al escalar animaciones o UI muy custom.
- **Alternativa considerada: Kotlin Multiplatform (Compose Multiplatform).** Permite compartir lógica de negocio con un futuro backend en Kotlin y ofrece rendimiento nativo real, pero su ecosistema de UI compartida es todavía menos maduro y su comunidad es más pequeña — mayor riesgo para un proyecto que necesita moverse rápido.
- **Estado y navegación:** Riverpod para manejo de estado y GoRouter para navegación — el combo recomendado por el propio equipo de Flutter para apps de tamaño mediano-grande.
- **UI/diseño:** sistema de diseño propio, sobrio, en tonos tierra/mármol (evocando la estética estoica clásica), sin gamificación infantil ni estridencia visual.

### 6.2 Backend y persistencia

- **Local-first:** SQLite vía Drift (ORM reactivo nativo de Flutter) como fuente de verdad en el dispositivo. La app debe funcionar completamente offline.
- **Backend (sync y backup):** API en .NET (ASP.NET Core Minimal API) con PostgreSQL, desplegada como servicios independientes (auth, sync, IA) para escalar cada uno por separado según demanda.
- **Alternativa más rápida de lanzar:** Supabase (Postgres + Auth + Realtime), aunque implica menor control de escalabilidad a largo plazo que una API propia.
- **Autenticación:** opcional y nunca obligatoria en el MVP — fricción mínima.

### 6.3 Capa de inteligencia artificial

- **Modelo:** API de un proveedor externo (Anthropic o similar) en vez de entrenar modelo propio.
- **Orquestación:** capa de prompts con clasificación de riesgo antes de cualquier respuesta generativa; plantillas fijas (no generativas) para escenarios de alto riesgo, respuestas generativas solo para el rol socrático de bajo riesgo.
- **Registro:** logging estructurado y auditable de interacciones críticas, con consentimiento explícito y retención mínima.

> Ver [sección 9](#9-modelo-de-monetización) para el desglose de costo por token y los límites de uso exactos.

### 6.4 Infraestructura y distribución

- CI/CD con GitHub Actions y Codemagic o Fastlane para automatizar builds y publicación en App Store y Google Play desde un solo pipeline.
- Repositorio público (open source) con licencia permisiva, siguiendo el modelo de Medito.
- Internacionalización desde el primer sprint si se proyecta expansión más allá de LATAM.

---

## 7. Modelo de datos inicial

| Entidad | Propósito |
|---|---|
| Usuario local | Perfil básico, sin registro obligatorio |
| Hábito / virtud objetivo | Categoría configurable ligada a una de las cuatro virtudes |
| Entrada de diario | Reflexión matutina o nocturna, con fecha y tipo |
| Registro de racha | Historial de consistencia por hábito |
| Evento de recaída | Contexto, detonante, aprendizaje asociado (sin lenguaje clínico) |
| Sesión de disciplina física | Registro de actividad y consistencia semanal |
| Conversación con el Interlocutor | Historial acotado, auditable, con clasificación de riesgo |
| Meta de vida | Objetivo por área: salud, trabajo, relaciones, carácter |
| Cohorte | Grupo de 5-8 usuarios en un reto compartido (ver sección 11) |

---

## 8. Roadmap recomendado

> **Implementación en curso.** La ejecución técnica de la Fase 1 (MVP) descrita abajo se está llevando en `docs/SPRINT_PLAN.md`: un plan sprint por sprint (Sprint 0 en adelante) con tareas técnicas, de arquitectura y de diseño/UX, criterios de aceptación y dependencias para cada sprint, además de las líneas rojas de la sección 9.6 como invariantes de proyecto. Ese documento es la referencia operativa de qué se está construyendo ahora mismo; este README sigue siendo la propuesta y visión de producto.

### Fase 1 — MVP (núcleo estoico)

MVP deliberadamente austero: solo lo esencial para validar retención antes de invertir en IA generativa o backend complejo.

- Diario matutino y nocturno de baja fricción (chips + voz, ver sección 10).
- Configuración de 1-3 hábitos o virtudes a trabajar.
- Contador de consistencia y racha, con registro de recaída sin culpa.
- Cita estoica diaria con pregunta de reflexión.
- Modo de crisis con ejercicio de respiración y dicotomía de control (contenido estático, sin IA).
- 100% offline, sin cuenta obligatoria.

### Fase 2 — Personalización, IA y monetización

- Interlocutor socrático con IA generativa, guardrails de riesgo y límite mensual gratuito.
- Tier de pago "Sostenedor" (sync, IA ilimitada, biblioteca extendida).
- Rutinas de disciplina física configurables.
- Métricas de progreso por virtud (dashboard de las cuatro virtudes).

### Fase 3 — Ecosistema y moat

- Cohortes de disciplina compartida (5-8 personas, reto de 30 días).
- Licenciamiento institucional (recuperación, coaching, bienestar corporativo).
- Biblioteca ampliada de textos estoicos clásicos y contenido comunitario.
- Exploración de modelos on-device para el rol socrático de bajo riesgo (eliminación estructural de costo de IA).
- Integraciones con Apple Health / Health Connect.

---

## 9. Modelo de monetización

**Problema a resolver:** el núcleo gratuito es una promesa central del producto, pero el Interlocutor de IA tiene costo variable por token. La solución es separar *seguridad* (gratis siempre) de *exploración conversacional* (limitada, luego de pago).

### 9.1 Arquitectura de costo en dos capas

| Tipo de interacción | Tecnología | Costo marginal | Disponibilidad |
|---|---|---|---|
| Modo de crisis / grounding | Plantillas fijas, sin generación de IA | $0 | Ilimitado, siempre gratis |
| Interlocutor socrático (reflexión) | IA generativa, modelo ligero | Bajo (~$0.002–0.01/mensaje) | Límite mensual gratuito, luego de pago |

Esto es también una decisión de seguridad: un usuario en crisis no debe depender de la disponibilidad o latencia de una API externa.

### 9.2 Límites exactos

- **15 interacciones socráticas gratis al mes** por usuario.
- Al llegar al límite, degradación elegante a preguntas reflexivas pre-escritas de una biblioteca curada (mismo espíritu, cero costo) — nunca un bloqueo agresivo.
- Modelo económico (clase Haiku) para el rol socrático de bajo riesgo; modelos más capaces reservados al tier de pago.

### 9.3 Tier de pago — "Sostenedor" (~$3–4 USD/mes o aporte anual)

- Interlocutor socrático ilimitado.
- Sincronización en la nube (costo real de servidor, cobro honesto).
- Biblioteca extendida de textos y cursos guiados.

### 9.4 Fuentes de ingreso adicionales

- **Donaciones directas**, modelo tipo fundación (Medito Foundation como referente), con transparencia de uso de fondos.
- **Licenciamiento institucional (B2B):** versión white-label o licencia para centros de recuperación, programas de bienestar corporativo, coaches certificados, universidades. Es la fuente de ingreso con mayor techo y la que mejor absorbe el crecimiento del costo variable de IA.

### 9.5 Control de costo a escala

- Alertas de costo agregado a nivel de infraestructura, con corte automático de degradación si el gasto mensual total supera un umbral definido.
- Roadmap de Fase 3: modelos pequeños on-device (tipo Gemma/Phi) para el rol socrático, eliminando el costo de API en ese flujo a largo plazo.

### 9.6 Líneas rojas (nunca implementar)

- Racha en riesgo condicionada a pago.
- Anuncios de cualquier tipo.
- Notificaciones push agresivas para "recuperar" usuarios inactivos.

---

## 10. UX de journaling y flujo del Interlocutor

### 10.1 Journaling: de "escribir" a "seleccionar, con opción de escribir"

El diseño original (texto largo dos veces al día) genera fricción alta y mata retención. Rediseño:

- **Reflexión matutina (10-15 segundos):** un chip único — *"Hoy depende de mí: [selección corta o 3-4 palabras]"*. Sin párrafo, sin obligación.
- **Reflexión nocturna:** tres chips pre-escritos y tocables ("hoy actué con calma" / "hoy reaccioné mal a algo" / "hoy avancé en lo que importa"), seleccionables múltiples, más un campo de texto **opcional** que solo aparece si el usuario decide expandir.
- **Dictado por voz** como alternativa nativa al texto.
- Principio de diseño: la versión mínima siempre es un toque; la versión larga es un extra que el usuario elige, nunca lo contrario.

### 10.2 Flujo del Interlocutor: acción primero, pregunta después

Abrir con una pregunta socrática en un momento agudo genera frustración. Orden invertido:

1. **Alivio inmediato:** ejercicio de respiración con temporizador o frase de reencuadre entregada como afirmación, no como pregunta ("Esto que sientes ahora va a pasar. Lo que decidas en los próximos 2 minutos sí depende de ti.").
2. **Pregunta socrática opcional:** ofrecida solo al terminar el temporizador, como invitación ("¿Quieres que exploremos qué lo activó?"), nunca como primer contacto en crisis.

El modo socrático "puro" (preguntas primero) queda reservado para momentos de reflexión calmada — diario nocturno, no crisis. Esto mantiene la regla de no diagnosticar ni dar consejo afectivo, sin generar frustración en el momento agudo.

---

## 11. Moat competitivo y estrategia go-to-market

El estoicismo como temática es posicionamiento, no un moat — es replicable por un competidor con presupuesto en semanas. El foso defensivo debe venir de estructura, no de tema.

### 11.1 Candidatos a moat (de más a menos defendible)

**1. Distribución institucional B2B.**
Calm y Headspace están optimizados para escala de consumidor masivo; no tienen incentivo ni estructura para vender licencias a centros de recuperación, terapeutas independientes, programas de bienestar corporativo o universidades en LATAM. Ser open source y gratuito en el núcleo permite ese canal: una institución puede auditar el código y confiar en la herramienta de una forma que no puede con una app cerrada de una corporación grande. No se copia en un mes porque requiere relaciones y confianza institucional, no presupuesto de marketing.

**2. Cohortes con responsabilidad compartida.**
Ni Calm ni Habitify tienen comunidad genuina. Sistema de cohortes pequeñas (5-8 personas) que empiezan juntas un reto de disciplina de 30 días, con check-ins compartidos y reflexiones visibles solo dentro del grupo. Genera efecto de red (cada cohorte trae más gente por invitación) y switching cost social real.

**3. Dato longitudinal como activo de personalización.**
Cuantos más días de diario, hábitos y patrones de recaída acumula un usuario, más precisa se vuelve la personalización (detonantes, virtud más débil, franja horaria de riesgo). No es una feature copiable en un sprint — es valor construido con tiempo de uso real.

### 11.2 Canales de go-to-market

- **Primario:** distribución institucional (recuperación, coaching, bienestar corporativo), en paralelo al consumidor individual desde el inicio, no como algo posterior.
- **Secundario:** cohortes con loop de referido incorporado — invitar a tu grupo de disciplina es más natural que invitar "a usar una app".
- **Terciario:** comunidad open source como motor de contenido y traducciones — cada colaborador externo es, de facto, un evangelista con incentivo genuino.

---

## 12. Naming

**Estado: nombre por definir.** El repositorio y el proyecto usan `stoic-growth-app` como nombre de trabajo/placeholder. Las dos opciones que llegaron limpias tras todas las rondas de evaluación —sin colisión de marca, sin choque cultural o político, y con significado coherente con el producto— son:

- **Andamio** — estructura temporal que sostiene mientras se construye algo permanente. Verificado sin colisión de app ni referencia cultural/política. Metáfora de que la app te sostiene mientras construyes disciplina real, no un fin en sí misma.
- **Virtude** — forma en portugués de "virtud", conecta directo con el sistema de las cuatro virtudes cardinales (sección 2.2). Verificado sin colisión de app exacta; existe un campo semántico vecino ocupado (apps "Virtues", "Deugden"), pero ninguna es competidor funcional directo.

Ambas se pueden usar para arrancar el desarrollo sin bloquear el proyecto; el nombre de marca definitivo se puede fijar más adelante (renombrar el repo de GitHub es trivial, ver sección 14).

### Historial de nombres evaluados y descartados

Por transparencia y para no repetir evaluaciones, este es el registro completo de opciones descartadas y por qué:

| Nombre | Motivo de descarte |
|---|---|
| **Aurelio** | En LATAM (Colombia, México) evoca a Aurelio Casillas (*El Señor de los Cielos*), asociación de narcotráfico que choca con el mensaje de templanza. Nombre de pila genérico, mala capacidad de búsqueda. |
| **Stoa** | Colisión directa: ya existe una app de meditación estoica activa y establecida llamada exactamente "Stoa" (stoameditation.com), en ambas tiendas. |
| **Stoiko** | Colisión fonética: se pronuncia casi idéntico a "StoyCo", app de fandom/música activa y con presencia relevante en tiendas. |
| **Prokopé** | Significado exacto (progreso moral gradual, concepto de Epicteto), pero difícil de pronunciar/recordar para el público general en español. Mejor candidato para nombre de módulo interno que de marca. |
| **Askesis** | Colisión directa: ya existen al menos dos apps activas con ese nombre (una de entrenamiento de fuerza, otra de seguimiento de retos/hábitos). |
| **Kyrios** | Colisión directa: ya existen apps activas con ese nombre (CRM de negocio, app de iglesia). |
| **Firme** | Doble colisión cultural fuerte: Grupo Firme (banda de música regional mexicana, ganadora de Grammy Latino, masiva en LATAM) y Firmes por la Patria (movimiento político activo en Colombia). Riesgo alto, tanto de entretenimiento como político. |
| **Zócalo** | Nombre saturado: ya lo usan una app de noticias establecida (Coahuila, México), una cadena de restaurantes y una app de salud en EE.UU. Sin colisión temática directa, pero mala descubribilidad. |
| **Temple** | Colisión masiva: es el nombre de la franquicia *Temple Run* (50M+ jugadores). Veto directo, no solo riesgo. |
| **Fulcro / Fulcra** | Riesgo medio: "Fulcro" ya usado por varias apps no relacionadas (seguros, fintech, juego). "Fulcra" colisiona más de cerca con Fulcra Dynamics, startup de salud/datos personales con IA — adyacente en tema. Conceptualmente fuerte pero pesado como nombre de marca de consumo. |
| **Tenax, Fortia, Agoge, Noesis** | No se llegaron a verificar en tienda; descartados por priorizar otras rutas antes. |
| **Toppa** | Significado preciso ("abrirse paso, penetrar"), pero es parte del título de *Tengen Toppa Gurren Lagann*, anime de culto con comunidad activa y de público solapado con el objetivo secundario de la app. Riesgo de asociación no controlada. |
| **Virtus, Ethos, Telos, Praxis, Kairos, Virtu** | Exploradas en la ronda de "marca global"; no se llegaron a verificar en tienda antes de decidir frenar el proceso de naming y avanzar con el desarrollo. |

### Otras direcciones exploradas sin desarrollar

- **Marco, Séneca, Epicteto** — vía nombre propio histórico, sin la carga cultural de "Aurelio".
- **Hegemonikón, Erumpo, Rumpo, Vikrama** — vía conceptual griega/latina/sánscrita, distintivas pero no verificadas en tienda.

**Pendiente:** validar Andamio y/o Virtude por disponibilidad de dominio y redes sociales antes de fijar el nombre definitivo de marca.

---

## 13. Riesgos y mitigación

| Riesgo | Mitigación |
|---|---|
| Alcance excesivo desde el MVP | MVP deliberadamente reducido a diario + hábitos + cita diaria, sin IA |
| Costo de IA no cubierto al escalar | Modelo de dos capas (plantillas fijas + límite mensual de IA generativa), ver sección 9 |
| Riesgo ético si la IA responde mal en crisis | Plantillas fijas para alto riesgo; IA generativa solo en rol socrático de bajo riesgo, y solo después de la respuesta de alivio inmediato |
| Fricción de journaling mata retención | Rediseño a chips + voz, texto largo opcional, ver sección 10 |
| Diferenciación fácilmente replicable | Moat vía distribución institucional, cohortes y dato longitudinal, ver sección 11 |
| Confusión de posicionamiento (¿app clínica o filosófica?) | Comunicación explícita: la app es una herramienta de disciplina y sentido, no un tratamiento clínico |
| Sostenibilidad financiera del modelo gratuito | Licenciamiento institucional como motor de ingreso principal; donaciones como base inicial |
| Revisión regulatoria en tiendas por temas de salud mental | Avisos de responsabilidad visibles y lenguaje no clínico desde el diseño |

---

## 14. Próximos pasos concretos

- [ ] Validar la propuesta con 10-15 conversaciones reales de usuarios potenciales antes de escribir código.
- [ ] Confirmar disponibilidad de nombre (dominio, redes, tienda de apps) para el nombre final de marca (ver sección 12).
- [ ] Definir el sistema de diseño (tono visual, tipografía, paleta) coherente con la identidad estoica.
- [ ] Construir el MVP de Fase 1 en Flutter, 100% local, en un ciclo corto (4-6 semanas).
- [ ] Probar el MVP con un grupo cerrado antes de invertir en la capa de IA.
- [ ] Identificar 1-2 aliados institucionales o comunidades de estoicismo/disciplina para distribución inicial.
- [ ] Diseñar la clasificación de riesgo del Interlocutor y las plantillas fijas de crisis antes de integrar IA generativa.

---

## 15. Conclusión

Esta propuesta no compite función por función contra apps de bienestar ya consolidadas: compite ofreciendo un marco de sentido que ninguna de ellas tiene, sostenido por un moat estructural (distribución institucional, cohortes, dato longitudinal) que no depende únicamente de la temática. Un MVP austero, local-first y sin IA desde el día uno reduce el riesgo técnico, ético y financiero, y un modelo de monetización de dos capas permite escalar el costo de IA sin comprometer la gratuidad del núcleo. La validación real ocurre cuando la gente vuelve a abrir la app al día siguiente — todo lo demás está diseñado para proteger esa condición.

---

## Historial de actualizaciones

| Versión | Fecha | Cambios |
|---|---|---|
| 1.1 | 2026-07-14 | Se agrega referencia a `docs/SPRINT_PLAN.md` en la sección 8 (Roadmap): plan de implementación sprint por sprint de la Fase 1, ya en ejecución (Sprint 0 completo — scaffold Flutter con Riverpod, GoRouter y Drift). El README no cambia como propuesta; solo se enlaza al documento operativo. |
| 1.0 | 2026-07-11 | Versión inicial. Documento técnico consolidado: visión y arquitectura filosófica (tres disciplinas, cuatro virtudes), propuesta funcional, stack técnico (Flutter + .NET/PostgreSQL), modelo de datos, roadmap, modelo de monetización de dos capas, rediseño de UX de journaling y flujo del Interlocutor, moat competitivo y estrategia go-to-market, e historial de naming con `stoic-growth-app` como nombre de trabajo. |

> Cada actualización futura debe agregar una fila nueva arriba de esta tabla (orden descendente, más reciente primero), con un resumen breve de qué cambió y por qué. No se sobrescriben versiones anteriores — el historial completo queda como registro de decisiones.
