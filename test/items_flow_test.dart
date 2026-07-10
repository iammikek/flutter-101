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

    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    expect(find.text('Name is required'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Name'), 'Test Item');
    await tester.enterText(find.widgetWithText(TextFormField, 'Price'), '12.34');

    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('Test Item'), findsOneWidget);
  });

  testWidgets('Delete item shows confirmation; cancel keeps detail', (WidgetTester tester) async {
    await tester.pumpWidget(const FastApiFlutterApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Widget'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('Delete item?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Widget'), findsWidgets);
  });

  testWidgets('Delete item confirm pops back to list', (WidgetTester tester) async {
    await tester.pumpWidget(const FastApiFlutterApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Widget'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm_delete')));
    await tester.pumpAndSettle();

    expect(find.text('Widget'), findsNothing);
    expect(find.text('Gadget'), findsOneWidget);
  });
}
