import 'package:app/src/core/design_system/gallery/design_gallery_screen.dart';
import 'package:app/src/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/no_network_http_overrides.dart';
import 'support/test_app.dart';

void main() {
  final es = lookupAppLocalizations(const Locale('es'));

  // The gallery is the design-system reference screen (debug-only). Pumped
  // directly here so the check stays independent of routing/onboarding.
  testWidgets('gallery renders all virtues in both local modes with no network',
      (tester) async {
    await withNoNetwork(() async {
      await tester.pumpWidget(wrapScreen(const DesignGalleryScreen()));
      await tester.pumpAndSettle();

      expect(find.text(es.galleryTitle), findsOneWidget);
      expect(find.text(es.virtueTemplanza), findsWidgets);

      // Toggle the gallery-local brightness; still renders, no mode assumption.
      await tester.tap(find.text(es.galleryToggleDark).first);
      await tester.pumpAndSettle();

      expect(find.text(es.virtueTemplanza), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
