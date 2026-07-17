import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('es')];

  /// Nombre visible de la app (working name).
  ///
  /// In es, this message translates to:
  /// **'Andamio'**
  String get appTitle;

  /// Nombre de la virtud cardinal: temperance.
  ///
  /// In es, this message translates to:
  /// **'Templanza'**
  String get virtueTemplanza;

  /// Nombre de la virtud cardinal: courage.
  ///
  /// In es, this message translates to:
  /// **'Coraje'**
  String get virtueCoraje;

  /// Nombre de la virtud cardinal: wisdom.
  ///
  /// In es, this message translates to:
  /// **'Sabiduría'**
  String get virtueSabiduria;

  /// Nombre de la virtud cardinal: justice.
  ///
  /// In es, this message translates to:
  /// **'Justicia'**
  String get virtueJusticia;

  /// Estado de progreso de virtud (bajo / recién empieza). Metáfora de material, sin puntaje.
  ///
  /// In es, this message translates to:
  /// **'Sin desbastar'**
  String get virtueStateSinDesbastar;

  /// Estado de progreso de virtud (medio).
  ///
  /// In es, this message translates to:
  /// **'Tomando color'**
  String get virtueStateTomandoColor;

  /// Estado de progreso de virtud (alto / constante).
  ///
  /// In es, this message translates to:
  /// **'Pulida'**
  String get virtueStatePulida;

  /// Estado de virtud tras una recaída. Nunca 'roto', nunca vacío — es re-construible.
  ///
  /// In es, this message translates to:
  /// **'En reposo'**
  String get virtueStateEnReposo;

  /// Etiqueta de navegación: pantalla de inicio / dashboard.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get navToday;

  /// Etiqueta de navegación: diario.
  ///
  /// In es, this message translates to:
  /// **'Diario'**
  String get navJournal;

  /// Etiqueta de navegación: hábitos.
  ///
  /// In es, this message translates to:
  /// **'Hábitos'**
  String get navHabits;

  /// Etiqueta del acceso persistente a modo de crisis. Tono calmo, nunca de alarma.
  ///
  /// In es, this message translates to:
  /// **'Un momento de calma'**
  String get crisisAccessLabel;

  /// Título del empty-state para 0 hábitos activos (no es el primer uso).
  ///
  /// In es, this message translates to:
  /// **'Aún no hay nada que cuidar aquí'**
  String get emptyHabitsTitle;

  /// Cuerpo del empty-state para 0 hábitos activos.
  ///
  /// In es, this message translates to:
  /// **'Cuando elijas qué trabajar, aparecerá en este espacio.'**
  String get emptyHabitsBody;

  /// Acción del empty-state para agregar un hábito.
  ///
  /// In es, this message translates to:
  /// **'Elegir un hábito'**
  String get emptyHabitsAction;

  /// Título de la pantalla-galería debug-only del Sprint 1.
  ///
  /// In es, this message translates to:
  /// **'Galería del sistema de diseño'**
  String get galleryTitle;

  /// No description provided for @gallerySectionTypography.
  ///
  /// In es, this message translates to:
  /// **'Tipografía'**
  String get gallerySectionTypography;

  /// No description provided for @gallerySectionColor.
  ///
  /// In es, this message translates to:
  /// **'Paleta y superficies'**
  String get gallerySectionColor;

  /// No description provided for @gallerySectionVirtues.
  ///
  /// In es, this message translates to:
  /// **'Virtudes y estados de progreso'**
  String get gallerySectionVirtues;

  /// No description provided for @gallerySectionButtons.
  ///
  /// In es, this message translates to:
  /// **'Botones'**
  String get gallerySectionButtons;

  /// No description provided for @gallerySectionChips.
  ///
  /// In es, this message translates to:
  /// **'Chips seleccionables'**
  String get gallerySectionChips;

  /// No description provided for @gallerySectionCards.
  ///
  /// In es, this message translates to:
  /// **'Tarjetas'**
  String get gallerySectionCards;

  /// No description provided for @gallerySectionEmptyState.
  ///
  /// In es, this message translates to:
  /// **'Empty state'**
  String get gallerySectionEmptyState;

  /// No description provided for @gallerySectionNav.
  ///
  /// In es, this message translates to:
  /// **'Navegación y crisis'**
  String get gallerySectionNav;

  /// Opción del toggle local de brightness en la galería: modo claro.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get galleryToggleLight;

  /// Opción del toggle local de brightness en la galería: modo oscuro.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get galleryToggleDark;

  /// Cita de demostración (Epicteto, dominio público) para mostrar el rol tipográfico 'quote' en la galería.
  ///
  /// In es, this message translates to:
  /// **'No es lo que te sucede, sino cómo reaccionas a ello lo que importa.'**
  String get galleryQuoteDemo;

  /// No description provided for @galleryQuoteAttribution.
  ///
  /// In es, this message translates to:
  /// **'Epicteto'**
  String get galleryQuoteAttribution;

  /// Eyebrow de sección de demostración.
  ///
  /// In es, this message translates to:
  /// **'CITA DE HOY'**
  String get galleryEyebrowQuote;

  /// Pregunta de reflexión de demostración (rol tipográfico 'reflection', itálica).
  ///
  /// In es, this message translates to:
  /// **'¿Qué está bajo tu control en esto?'**
  String get galleryReflectionDemo;

  /// Prompt de demostración (rol 'promptDisplay').
  ///
  /// In es, this message translates to:
  /// **'Hoy depende de mí:'**
  String get galleryPromptDemo;

  /// No description provided for @buttonPrimaryDemo.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get buttonPrimaryDemo;

  /// No description provided for @buttonSecondaryDemo.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get buttonSecondaryDemo;

  /// Chip cualitativo de ánimo/energía: nivel bajo. Sin lenguaje clínico.
  ///
  /// In es, this message translates to:
  /// **'Bajo'**
  String get chipMoodLow;

  /// No description provided for @chipMoodMedium.
  ///
  /// In es, this message translates to:
  /// **'Medio'**
  String get chipMoodMedium;

  /// No description provided for @chipMoodHigh.
  ///
  /// In es, this message translates to:
  /// **'Alto'**
  String get chipMoodHigh;

  /// Chip nocturno de demostración (copy provisional; el copy exacto de README 10.1 se fija en Sprint 5).
  ///
  /// In es, this message translates to:
  /// **'Descansé bien'**
  String get chipEveningRest;

  /// No description provided for @chipEveningPresent.
  ///
  /// In es, this message translates to:
  /// **'Estuve presente'**
  String get chipEveningPresent;

  /// No description provided for @chipEveningKind.
  ///
  /// In es, this message translates to:
  /// **'Fui amable conmigo'**
  String get chipEveningKind;

  /// Título de la pantalla de intro de onboarding. Framing breve, sin login.
  ///
  /// In es, this message translates to:
  /// **'Construye tu carácter, día a día'**
  String get onboardingIntroTitle;

  /// No description provided for @onboardingIntroBody.
  ///
  /// In es, this message translates to:
  /// **'Sin cuentas y sin presión. Solo tú y lo que decides trabajar, a tu ritmo.'**
  String get onboardingIntroBody;

  /// No description provided for @onboardingIntroStart.
  ///
  /// In es, this message translates to:
  /// **'Empezar'**
  String get onboardingIntroStart;

  /// Título del selector de hábitos. Framing neutro, sin lenguaje clínico.
  ///
  /// In es, this message translates to:
  /// **'¿Qué quieres trabajar?'**
  String get onboardingSelectTitle;

  /// No description provided for @onboardingSelectSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elige de uno a tres. Podrás cambiarlos cuando quieras.'**
  String get onboardingSelectSubtitle;

  /// No description provided for @onboardingSelectionCounter.
  ///
  /// In es, this message translates to:
  /// **'{count} de {max} elegidos'**
  String onboardingSelectionCounter(int count, int max);

  /// No description provided for @onboardingContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get onboardingContinue;

  /// No description provided for @onboardingBack.
  ///
  /// In es, this message translates to:
  /// **'Atrás'**
  String get onboardingBack;

  /// No description provided for @onboardingConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Esto es lo que vas a trabajar'**
  String get onboardingConfirmTitle;

  /// No description provided for @onboardingConfirmSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Puedes agregar o archivar hábitos más adelante.'**
  String get onboardingConfirmSubtitle;

  /// No description provided for @onboardingStart.
  ///
  /// In es, this message translates to:
  /// **'Comenzar'**
  String get onboardingStart;

  /// Hábito sugerido (Templanza). Copy no clínico.
  ///
  /// In es, this message translates to:
  /// **'Moderar el tiempo en pantallas'**
  String get suggestionScreenTime;

  /// No description provided for @suggestionConsumption.
  ///
  /// In es, this message translates to:
  /// **'Cuidar lo que consumo'**
  String get suggestionConsumption;

  /// Hábito sugerido (Coraje).
  ///
  /// In es, this message translates to:
  /// **'Mover el cuerpo cada día'**
  String get suggestionMove;

  /// No description provided for @suggestionDiscomfort.
  ///
  /// In es, this message translates to:
  /// **'Hacer algo incómodo a propósito'**
  String get suggestionDiscomfort;

  /// Hábito sugerido (Sabiduría).
  ///
  /// In es, this message translates to:
  /// **'Leer unos minutos'**
  String get suggestionRead;

  /// No description provided for @suggestionReflect.
  ///
  /// In es, this message translates to:
  /// **'Reflexionar al final del día'**
  String get suggestionReflect;

  /// Hábito sugerido (Justicia).
  ///
  /// In es, this message translates to:
  /// **'Un gesto amable al día'**
  String get suggestionKindness;

  /// No description provided for @suggestionKeepWord.
  ///
  /// In es, this message translates to:
  /// **'Cumplir mi palabra'**
  String get suggestionKeepWord;

  /// No description provided for @homeTitle.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get homeTitle;

  /// No description provided for @homeHabitsSectionTitle.
  ///
  /// In es, this message translates to:
  /// **'Lo que estás trabajando'**
  String get homeHabitsSectionTitle;

  /// No description provided for @homeOpenHabits.
  ///
  /// In es, this message translates to:
  /// **'Ver hábitos'**
  String get homeOpenHabits;

  /// No description provided for @homeOpenGallery.
  ///
  /// In es, this message translates to:
  /// **'Galería de diseño (debug)'**
  String get homeOpenGallery;

  /// No description provided for @habitsTitle.
  ///
  /// In es, this message translates to:
  /// **'Tus hábitos'**
  String get habitsTitle;

  /// No description provided for @habitsAdd.
  ///
  /// In es, this message translates to:
  /// **'Agregar hábito'**
  String get habitsAdd;

  /// No description provided for @habitsArchive.
  ///
  /// In es, this message translates to:
  /// **'Archivar'**
  String get habitsArchive;

  /// Confirmación breve tras archivar.
  ///
  /// In es, this message translates to:
  /// **'Hábito archivado'**
  String get habitsArchived;

  /// No description provided for @habitFormTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo hábito'**
  String get habitFormTitle;

  /// No description provided for @habitFormLabelHint.
  ///
  /// In es, this message translates to:
  /// **'¿Qué quieres trabajar?'**
  String get habitFormLabelHint;

  /// No description provided for @habitFormVirtueLabel.
  ///
  /// In es, this message translates to:
  /// **'¿A qué virtud pertenece?'**
  String get habitFormVirtueLabel;

  /// No description provided for @habitFormSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get habitFormSave;

  /// Validación no punitiva de label vacío.
  ///
  /// In es, this message translates to:
  /// **'Escribe un nombre para el hábito.'**
  String get habitFormEmptyLabel;

  /// Mensaje al intentar un 4º hábito activo. Claro y no punitivo.
  ///
  /// In es, this message translates to:
  /// **'Ya tienes tres hábitos activos. Archiva uno para agregar otro.'**
  String get habitsLimitReached;

  /// Etiqueta bajo el número de días constantes. Minúscula, sin framing de 'racha' gamificada.
  ///
  /// In es, this message translates to:
  /// **'días de constancia'**
  String get habitDetailStreakLabel;

  /// Texto cuando la constancia está en 0. Cálido, re-construible, nunca 'rompiste tu racha'.
  ///
  /// In es, this message translates to:
  /// **'Hoy es un buen día para empezar de nuevo.'**
  String get habitDetailStreakZero;

  /// Acción primaria: marca el día como cumplido (suma un día de constancia).
  ///
  /// In es, this message translates to:
  /// **'Registrar hoy'**
  String get habitDetailRegisterToday;

  /// Confirmación breve tras registrar un día constante. Sin exclamaciones.
  ///
  /// In es, this message translates to:
  /// **'Registrado. Un día más.'**
  String get habitDetailRegistered;

  /// Acción para editar directamente el número de días. Tan visible como registrar.
  ///
  /// In es, this message translates to:
  /// **'Ajustar'**
  String get habitDetailEditStreak;

  /// Título del diálogo de edición directa del contador.
  ///
  /// In es, this message translates to:
  /// **'Ajustar los días de constancia'**
  String get habitDetailEditStreakTitle;

  /// Etiqueta accesible del botón de restar uno.
  ///
  /// In es, this message translates to:
  /// **'Quitar un día'**
  String get habitDetailDecrement;

  /// Etiqueta accesible del botón de sumar uno.
  ///
  /// In es, this message translates to:
  /// **'Sumar un día'**
  String get habitDetailIncrement;

  /// Acceso al formulario de recaída. Neutro, sin culpa, tan de primer nivel como registrar.
  ///
  /// In es, this message translates to:
  /// **'Registrar una recaída'**
  String get habitDetailRegisterRelapse;

  /// Encabezado de la lista de check-ins. Las recaídas pasadas quedan visibles como dato.
  ///
  /// In es, this message translates to:
  /// **'Tu historial'**
  String get habitDetailHistoryTitle;

  /// Empty-state del historial de constancia.
  ///
  /// In es, this message translates to:
  /// **'Cuando marques un día, quedará registrado aquí.'**
  String get habitDetailHistoryEmpty;

  /// Etiqueta de una entrada de éxito en el historial.
  ///
  /// In es, this message translates to:
  /// **'Día constante'**
  String get habitDetailHistorySuccess;

  /// Etiqueta de una entrada de recaída en el historial. Reusa el estado 'en reposo', nunca 'fallo'.
  ///
  /// In es, this message translates to:
  /// **'En reposo'**
  String get habitDetailHistoryRelapse;

  /// Título del formulario de recaída. Framing de aprendizaje, no de confesión.
  ///
  /// In es, this message translates to:
  /// **'¿Qué pasó, y qué aprendes de esto?'**
  String get relapseFormTitle;

  /// Subtítulo del formulario de recaída. Refuerza que no hay juicio.
  ///
  /// In es, this message translates to:
  /// **'Sin culpa. Esto es información para conocerte mejor. Todos los campos son opcionales.'**
  String get relapseFormSubtitle;

  /// Campo opcional: contexto.
  ///
  /// In es, this message translates to:
  /// **'¿Qué estaba pasando?'**
  String get relapseFormContextLabel;

  /// Campo opcional: detonante.
  ///
  /// In es, this message translates to:
  /// **'¿Qué lo detonó?'**
  String get relapseFormTriggerLabel;

  /// Campo opcional: aprendizaje.
  ///
  /// In es, this message translates to:
  /// **'¿Qué aprendes de esto?'**
  String get relapseFormLearningLabel;

  /// No description provided for @relapseFormSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get relapseFormSave;

  /// Confirmación tras guardar una recaída. Cálida, orientada a retomar.
  ///
  /// In es, this message translates to:
  /// **'Registrado. Mañana es un buen día para retomar.'**
  String get relapseFormSaved;

  /// Acción genérica de cancelar en un diálogo.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get dialogCancel;

  /// Acción genérica de guardar en un diálogo.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get dialogSave;

  /// Encabezado de la cuadrícula de las 4 virtudes en el dashboard. El framing primario de la home.
  ///
  /// In es, this message translates to:
  /// **'Tus virtudes'**
  String get homeVirtuesSectionTitle;

  /// Eyebrow de la tarjeta de cita diaria.
  ///
  /// In es, this message translates to:
  /// **'PARA HOY'**
  String get homeQuoteEyebrow;

  /// Subtítulo de la sección de hábitos en el dashboard.
  ///
  /// In es, this message translates to:
  /// **'Lo que estás trabajando'**
  String get homeHabitsSectionSubtitle;

  /// Encabezado de la sección de diario en la home.
  ///
  /// In es, this message translates to:
  /// **'Diario'**
  String get homeJournalSectionTitle;

  /// No description provided for @homeOpenMorning.
  ///
  /// In es, this message translates to:
  /// **'Reflexión de la mañana'**
  String get homeOpenMorning;

  /// No description provided for @homeOpenEvening.
  ///
  /// In es, this message translates to:
  /// **'Reflexión de la noche'**
  String get homeOpenEvening;

  /// Eyebrow de la pantalla matutina.
  ///
  /// In es, this message translates to:
  /// **'REFLEXIÓN DE LA MAÑANA'**
  String get journalMorningEyebrow;

  /// Prompt matutino (README 10.1). El usuario completa con un chip o una frase corta.
  ///
  /// In es, this message translates to:
  /// **'Hoy depende de mí:'**
  String get journalMorningPrompt;

  /// Frase corta pre-escrita para el prompt matutino (un toque).
  ///
  /// In es, this message translates to:
  /// **'Mi actitud'**
  String get morningPresetAttitude;

  /// No description provided for @morningPresetEffort.
  ///
  /// In es, this message translates to:
  /// **'Mi esfuerzo'**
  String get morningPresetEffort;

  /// No description provided for @morningPresetResponse.
  ///
  /// In es, this message translates to:
  /// **'Cómo respondo'**
  String get morningPresetResponse;

  /// No description provided for @morningPresetFocus.
  ///
  /// In es, this message translates to:
  /// **'Mi enfoque'**
  String get morningPresetFocus;

  /// Etiqueta del campo opcional de frase propia (3-4 palabras).
  ///
  /// In es, this message translates to:
  /// **'O escríbelo con tus palabras'**
  String get morningCustomHint;

  /// Eyebrow de la pantalla nocturna.
  ///
  /// In es, this message translates to:
  /// **'REFLEXIÓN DE LA NOCHE'**
  String get journalEveningEyebrow;

  /// Título de la pantalla nocturna. Neutro, sin lenguaje clínico.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo estuvo tu día?'**
  String get journalEveningTitle;

  /// Chip nocturno fijo (README 10.1). Multi-select.
  ///
  /// In es, this message translates to:
  /// **'Hoy actué con calma'**
  String get eveningTagCalm;

  /// Chip nocturno fijo (README 10.1). Sin culpa: es un dato, no un juicio.
  ///
  /// In es, this message translates to:
  /// **'Hoy reaccioné mal a algo'**
  String get eveningTagReacted;

  /// Chip nocturno fijo (README 10.1).
  ///
  /// In es, this message translates to:
  /// **'Hoy avancé en lo que importa'**
  String get eveningTagAdvanced;

  /// Afordance colapsada. Al tocarla aparece el campo de texto opcional — nunca expandido por defecto.
  ///
  /// In es, this message translates to:
  /// **'Agregar una nota'**
  String get eveningAddNote;

  /// Etiqueta del campo de texto libre nocturno, opt-in.
  ///
  /// In es, this message translates to:
  /// **'Si quieres, escribe algo más'**
  String get eveningNoteHint;

  /// Pregunta del selector de ánimo. Opcional, un toque.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo está tu ánimo?'**
  String get journalMoodQuestion;

  /// Pregunta del selector de energía. Opcional, un toque.
  ///
  /// In es, this message translates to:
  /// **'¿Y tu energía?'**
  String get journalEnergyQuestion;

  /// Aclaración de que ánimo/energía no son obligatorios.
  ///
  /// In es, this message translates to:
  /// **'Opcional'**
  String get journalOptionalHint;

  /// Nivel cualitativo de ánimo/energía (no escala numérica clínica).
  ///
  /// In es, this message translates to:
  /// **'Bajo'**
  String get moodLevelLow;

  /// No description provided for @moodLevelMedium.
  ///
  /// In es, this message translates to:
  /// **'Medio'**
  String get moodLevelMedium;

  /// No description provided for @moodLevelHigh.
  ///
  /// In es, this message translates to:
  /// **'Alto'**
  String get moodLevelHigh;

  /// Etiqueta del botón de micrófono en los campos de texto del diario. Opcional; el texto siempre se puede escribir.
  ///
  /// In es, this message translates to:
  /// **'Dictar por voz'**
  String get journalMicTooltip;

  /// No description provided for @journalSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get journalSave;

  /// Confirmación breve tras guardar una entrada de diario. Sin exclamaciones.
  ///
  /// In es, this message translates to:
  /// **'Guardado.'**
  String get journalSaved;

  /// Salida siempre visible del modo crisis. Nunca atrapar al usuario en un flujo sin escape.
  ///
  /// In es, this message translates to:
  /// **'Estoy bien ahora'**
  String get crisisExit;

  /// Encabezado de la invitación socrática, ofrecida solo DESPUÉS del alivio. Invitación, no orden.
  ///
  /// In es, this message translates to:
  /// **'Si quieres, considera:'**
  String get crisisSocraticIntro;

  /// Ofrece otra pregunta de reflexión. Nunca avanza solo; requiere un toque.
  ///
  /// In es, this message translates to:
  /// **'Otra pregunta'**
  String get crisisAnotherQuestion;

  /// Frase de reencuadre de respaldo si el contenido empaquetado no carga — el flujo de seguridad nunca queda en blanco.
  ///
  /// In es, this message translates to:
  /// **'Respira. Esto también va a pasar.'**
  String get crisisFallbackLine;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
