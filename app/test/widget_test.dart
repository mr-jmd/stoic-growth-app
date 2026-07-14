import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/src/app.dart';

void main() {
  testWidgets('boots to placeholder screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: StoicApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Stoic Growth App'), findsOneWidget);
  });
}
