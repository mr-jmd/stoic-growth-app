import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/repositories/onboarding_repository.dart';
import 'core/design_system/components/app_scaffold.dart';
import 'core/design_system/theme/stoic_theme.dart';
import 'core/l10n/app_localizations.dart';
import 'core/routing/app_router.dart';

/// Root of the app. Owns the two `ThemeData`s (light/dark) built from a single
/// token source and the localization delegates. `ThemeMode.system` makes the
/// whole app mode-aware from Sprint 1 with zero new persistence.
///
/// Startup gate: while the persisted onboarding flag is still loading, show a
/// calm splash instead of the router. This guarantees the router's onboarding
/// redirect never reads an unresolved value (which would flash the wrong screen
/// at a returning user). Once the flag resolves, the router takes over and its
/// `refreshListenable` handles later changes.
class StoicApp extends ConsumerWidget {
  const StoicApp({super.key});

  static const _localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingCompletedProvider);

    // Loading → splash. Data or error → hand off to the router (on error the
    // redirect treats the flag as not-completed and routes to onboarding).
    if (onboarding.isLoading && !onboarding.hasValue) {
      return MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        theme: stoicLightTheme(),
        darkTheme: stoicDarkTheme(),
        themeMode: ThemeMode.system,
        localizationsDelegates: _localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AppScaffold(body: SizedBox.expand()),
      );
    }

    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: stoicLightTheme(),
      darkTheme: stoicDarkTheme(),
      themeMode: ThemeMode.system,
      localizationsDelegates: _localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
