import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fastapi_flutter/main.dart';

void main() {
  testWidgets('App loads Items page', (WidgetTester tester) async {
    await tester.pumpWidget(const FastApiFlutterApp());
    await tester.pumpAndSettle();

    expect(find.text('Items'), findsWidgets);
    expect(find.byIcon(Icons.settings), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('Widget'), findsOneWidget);
  });
}
