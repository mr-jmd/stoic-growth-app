import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/design_system/theme/stoic_theme.dart';
import 'core/l10n/app_localizations.dart';
import 'core/routing/app_router.dart';

/// Root of the app. Owns the two `ThemeData`s (light/dark) built from a single
/// token source and the localization delegates. `ThemeMode.system` makes the
/// whole app mode-aware from Sprint 1 with zero new persistence — a manual
/// toggle is a later additive step (DESIGN_BRIEF §8.4).
///
/// `StoicApp` and the design system are the *only* places that know about
/// `Brightness`; every widget below reads resolved roles from `ColorScheme` /
/// `StoicTokens`.
class StoicApp extends ConsumerWidget {
  const StoicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: stoicLightTheme(),
      darkTheme: stoicDarkTheme(),
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
