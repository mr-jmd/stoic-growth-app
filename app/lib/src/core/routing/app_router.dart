import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../design_system/design_system.dart';
import '../design_system/gallery/design_gallery_screen.dart';
import '../l10n/app_localizations.dart';

part 'app_router.g.dart';

// Single top-level GoRouter exposed via this provider, consumed once in
// StoicApp. Route-level redirects (onboarding gate) are added in Sprint 3.
@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        // Until the real home/dashboard lands (Sprint 7), `/` shows the
        // debug-only design-system gallery in debug builds and a plain
        // placeholder in release builds.
        builder: (context, state) =>
            kDebugMode ? const DesignGalleryScreen() : const _PlaceholderScreen(),
      ),
    ],
  );
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(child: Text(AppLocalizations.of(context).appTitle)),
    );
  }
}
