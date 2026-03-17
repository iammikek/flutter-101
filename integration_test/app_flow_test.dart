import 'package:fastapi_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('integration: settings + create item flow (mock)', (tester) async {
    await tester.pumpWidget(const FastApiFlutterApp());
    await tester.pumpAndSettle();

    // Ensure we're on the list page.
    expect(find.text('Items'), findsOneWidget);

    // Open settings and ensure mock is ON (default).
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);

    // Close settings.
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // Create an item.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('Create item'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Integration Item');
    await tester.enterText(find.widgetWithText(TextFormField, 'Price'), '5.50');

    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    // Back on list.
    expect(find.text('Items'), findsOneWidget);
  });

  testWidgets('integration: delete confirmation dialog cancel', (tester) async {
    await tester.pumpWidget(const FastApiFlutterApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Widget'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Delete (requires API key)'));
    await tester.pumpAndSettle();
    expect(find.text('Delete item?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Delete item?'), findsNothing);
    expect(find.text('Widget'), findsWidgets);
  });
}

