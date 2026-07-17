// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Andamio';

  @override
  String get virtueTemplanza => 'Templanza';

  @override
  String get virtueCoraje => 'Coraje';

  @override
  String get virtueSabiduria => 'Sabiduría';

  @override
  String get virtueJusticia => 'Justicia';

  @override
  String get virtueStateSinDesbastar => 'Sin desbastar';

  @override
  String get virtueStateTomandoColor => 'Tomando color';

  @override
  String get virtueStatePulida => 'Pulida';

  @override
  String get virtueStateEnReposo => 'En reposo';

  @override
  String get navToday => 'Hoy';

  @override
  String get navJournal => 'Diario';

  @override
  String get navHabits => 'Hábitos';

  @override
  String get crisisAccessLabel => 'Un momento de calma';

  @override
  String get emptyHabitsTitle => 'Aún no hay nada que cuidar aquí';

  @override
  String get emptyHabitsBody =>
      'Cuando elijas qué trabajar, aparecerá en este espacio.';

  @override
  String get emptyHabitsAction => 'Elegir un hábito';

  @override
  String get galleryTitle => 'Galería del sistema de diseño';

  @override
  String get gallerySectionTypography => 'Tipografía';

  @override
  String get gallerySectionColor => 'Paleta y superficies';

  @override
  String get gallerySectionVirtues => 'Virtudes y estados de progreso';

  @override
  String get gallerySectionButtons => 'Botones';

  @override
  String get gallerySectionChips => 'Chips seleccionables';

  @override
  String get gallerySectionCards => 'Tarjetas';

  @override
  String get gallerySectionEmptyState => 'Empty state';

  @override
  String get gallerySectionNav => 'Navegación y crisis';

  @override
  String get galleryToggleLight => 'Claro';

  @override
  String get galleryToggleDark => 'Oscuro';

  @override
  String get galleryQuoteDemo =>
      'No es lo que te sucede, sino cómo reaccionas a ello lo que importa.';

  @override
  String get galleryQuoteAttribution => 'Epicteto';

  @override
  String get galleryEyebrowQuote => 'CITA DE HOY';

  @override
  String get galleryReflectionDemo => '¿Qué está bajo tu control en esto?';

  @override
  String get galleryPromptDemo => 'Hoy depende de mí:';

  @override
  String get buttonPrimaryDemo => 'Continuar';

  @override
  String get buttonSecondaryDemo => 'Ahora no';

  @override
  String get chipMoodLow => 'Bajo';

  @override
  String get chipMoodMedium => 'Medio';

  @override
  String get chipMoodHigh => 'Alto';

  @override
  String get chipEveningRest => 'Descansé bien';

  @override
  String get chipEveningPresent => 'Estuve presente';

  @override
  String get chipEveningKind => 'Fui amable conmigo';

  @override
  String get onboardingIntroTitle => 'Construye tu carácter, día a día';

  @override
  String get onboardingIntroBody =>
      'Sin cuentas y sin presión. Solo tú y lo que decides trabajar, a tu ritmo.';

  @override
  String get onboardingIntroStart => 'Empezar';

  @override
  String get onboardingSelectTitle => '¿Qué quieres trabajar?';

  @override
  String get onboardingSelectSubtitle =>
      'Elige de uno a tres. Podrás cambiarlos cuando quieras.';

  @override
  String onboardingSelectionCounter(int count, int max) {
    return '$count de $max elegidos';
  }

  @override
  String get onboardingContinue => 'Continuar';

  @override
  String get onboardingBack => 'Atrás';

  @override
  String get onboardingConfirmTitle => 'Esto es lo que vas a trabajar';

  @override
  String get onboardingConfirmSubtitle =>
      'Puedes agregar o archivar hábitos más adelante.';

  @override
  String get onboardingStart => 'Comenzar';

  @override
  String get suggestionScreenTime => 'Moderar el tiempo en pantallas';

  @override
  String get suggestionConsumption => 'Cuidar lo que consumo';

  @override
  String get suggestionMove => 'Mover el cuerpo cada día';

  @override
  String get suggestionDiscomfort => 'Hacer algo incómodo a propósito';

  @override
  String get suggestionRead => 'Leer unos minutos';

  @override
  String get suggestionReflect => 'Reflexionar al final del día';

  @override
  String get suggestionKindness => 'Un gesto amable al día';

  @override
  String get suggestionKeepWord => 'Cumplir mi palabra';

  @override
  String get homeTitle => 'Hoy';

  @override
  String get homeHabitsSectionTitle => 'Lo que estás trabajando';

  @override
  String get homeOpenHabits => 'Ver hábitos';

  @override
  String get homeOpenGallery => 'Galería de diseño (debug)';

  @override
  String get habitsTitle => 'Tus hábitos';

  @override
  String get habitsAdd => 'Agregar hábito';

  @override
  String get habitsArchive => 'Archivar';

  @override
  String get habitsArchived => 'Hábito archivado';

  @override
  String get habitFormTitle => 'Nuevo hábito';

  @override
  String get habitFormLabelHint => '¿Qué quieres trabajar?';

  @override
  String get habitFormVirtueLabel => '¿A qué virtud pertenece?';

  @override
  String get habitFormSave => 'Guardar';

  @override
  String get habitFormEmptyLabel => 'Escribe un nombre para el hábito.';

  @override
  String get habitsLimitReached =>
      'Ya tienes tres hábitos activos. Archiva uno para agregar otro.';

  @override
  String get habitDetailStreakLabel => 'días de constancia';

  @override
  String get habitDetailStreakZero =>
      'Hoy es un buen día para empezar de nuevo.';

  @override
  String get habitDetailRegisterToday => 'Registrar hoy';

  @override
  String get habitDetailRegistered => 'Registrado. Un día más.';

  @override
  String get habitDetailEditStreak => 'Ajustar';

  @override
  String get habitDetailEditStreakTitle => 'Ajustar los días de constancia';

  @override
  String get habitDetailDecrement => 'Quitar un día';

  @override
  String get habitDetailIncrement => 'Sumar un día';

  @override
  String get habitDetailRegisterRelapse => 'Registrar una recaída';

  @override
  String get habitDetailHistoryTitle => 'Tu historial';

  @override
  String get habitDetailHistoryEmpty =>
      'Cuando marques un día, quedará registrado aquí.';

  @override
  String get habitDetailHistorySuccess => 'Día constante';

  @override
  String get habitDetailHistoryRelapse => 'En reposo';

  @override
  String get relapseFormTitle => '¿Qué pasó, y qué aprendes de esto?';

  @override
  String get relapseFormSubtitle =>
      'Sin culpa. Esto es información para conocerte mejor. Todos los campos son opcionales.';

  @override
  String get relapseFormContextLabel => '¿Qué estaba pasando?';

  @override
  String get relapseFormTriggerLabel => '¿Qué lo detonó?';

  @override
  String get relapseFormLearningLabel => '¿Qué aprendes de esto?';

  @override
  String get relapseFormSave => 'Guardar';

  @override
  String get relapseFormSaved =>
      'Registrado. Mañana es un buen día para retomar.';

  @override
  String get dialogCancel => 'Cancelar';

  @override
  String get dialogSave => 'Guardar';

  @override
  String get homeJournalSectionTitle => 'Diario';

  @override
  String get homeOpenMorning => 'Reflexión de la mañana';

  @override
  String get homeOpenEvening => 'Reflexión de la noche';

  @override
  String get journalMorningEyebrow => 'REFLEXIÓN DE LA MAÑANA';

  @override
  String get journalMorningPrompt => 'Hoy depende de mí:';

  @override
  String get morningPresetAttitude => 'Mi actitud';

  @override
  String get morningPresetEffort => 'Mi esfuerzo';

  @override
  String get morningPresetResponse => 'Cómo respondo';

  @override
  String get morningPresetFocus => 'Mi enfoque';

  @override
  String get morningCustomHint => 'O escríbelo con tus palabras';

  @override
  String get journalEveningEyebrow => 'REFLEXIÓN DE LA NOCHE';

  @override
  String get journalEveningTitle => '¿Cómo estuvo tu día?';

  @override
  String get eveningTagCalm => 'Hoy actué con calma';

  @override
  String get eveningTagReacted => 'Hoy reaccioné mal a algo';

  @override
  String get eveningTagAdvanced => 'Hoy avancé en lo que importa';

  @override
  String get eveningAddNote => 'Agregar una nota';

  @override
  String get eveningNoteHint => 'Si quieres, escribe algo más';

  @override
  String get journalMoodQuestion => '¿Cómo está tu ánimo?';

  @override
  String get journalEnergyQuestion => '¿Y tu energía?';

  @override
  String get journalOptionalHint => 'Opcional';

  @override
  String get moodLevelLow => 'Bajo';

  @override
  String get moodLevelMedium => 'Medio';

  @override
  String get moodLevelHigh => 'Alto';

  @override
  String get journalSave => 'Guardar';

  @override
  String get journalSaved => 'Guardado.';

  @override
  String get crisisExit => 'Estoy bien ahora';

  @override
  String get crisisSocraticIntro => 'Si quieres, considera:';

  @override
  String get crisisAnotherQuestion => 'Otra pregunta';

  @override
  String get crisisFallbackLine => 'Respira. Esto también va a pasar.';
}
