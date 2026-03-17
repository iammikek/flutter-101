import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fastapi_flutter/main.dart';

void main() {
  testWidgets('Settings toggle updates Mock/Live label', (WidgetTester tester) async {
    await tester.pumpWidget(const FastApiFlutterApp());
    await tester.pumpAndSettle();

    expect(find.text('Mock mode'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    // Switch "Use mock data" OFF
    await tester.tap(find.text('Use mock data'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Live API'), findsOneWidget);
  });

  testWidgets('Create item form validates and returns to list', (WidgetTester tester) async {
    await tester.pumpWidget(const FastApiFlutterApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Create item'), findsOneWidget);

    // Try submit empty -> shows validation errors.
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    expect(find.text('Name is required'), findsOneWidget);
    expect(find.text('Price is required'), findsOneWidget);

    // Fill in valid values and submit.
    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Test Item');
    await tester.enterText(find.widgetWithText(TextFormField, 'Price'), '12.34');

    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    // Navigated back to list page.
    expect(find.text('Items'), findsOneWidget);
  });
}

