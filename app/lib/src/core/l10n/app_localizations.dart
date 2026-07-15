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
