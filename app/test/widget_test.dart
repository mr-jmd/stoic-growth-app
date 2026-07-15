import 'package:app/src/app.dart';
import 'package:app/src/core/l10n/app_localizations.dart';
import 'package:app/src/core/design_system/gallery/design_gallery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/no_network_http_overrides.dart';

void main() {
  final es = lookupAppLocalizations(const Locale('es'));

  testWidgets('boots to the design-system gallery (debug home) offline',
      (tester) async {
    await withNoNetwork(() async {
      await tester.pumpWidget(const ProviderScope(child: StoicApp()));
      await tester.pumpAndSettle();

      // Debug home is the gallery; asserting its title also proves the
      // localization delegate resolved a Spanish string with no network.
      expect(find.text(es.galleryTitle), findsOneWidget);
      expect(find.byType(DesignGalleryScreen), findsOneWidget);
    });
  });

  testWidgets('gallery renders in both local brightness modes with no network',
      (tester) async {
    await withNoNetwork(() async {
      await tester.pumpWidget(const ProviderScope(child: StoicApp()));
      await tester.pumpAndSettle();

      // The gallery starts in its local light preview; the four virtue names
      // are present. Toggle to dark and confirm they still render (no widget
      // assumes a mode).
      expect(find.text(es.virtueTemplanza), findsWidgets);

      await tester.tap(find.text(es.galleryToggleDark).first);
      await tester.pumpAndSettle();

      // Still renders after re-theming to dark, with no layout/paint exception —
      // the proof that no component hard-codes a mode. (Justicia's row is built
      // lazily below the fold, so we assert on the visible first row.)
      expect(find.text(es.virtueTemplanza), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
