import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gaming_app/main.dart';

void main() {
  testWidgets('Daman homepage smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify header buttons are present
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);

    // Verify that the platform recommendation header is present
    expect(find.text('Platform recommendation'), findsOneWidget);

    // Verify 'All 6' recommendation button text is present
    expect(find.text('All 6'), findsOneWidget);
  });
}

