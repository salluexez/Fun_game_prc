import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gaming_app/main.dart';

void main() {
  testWidgets('Daman homepage smoke test and Wingo navigation', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify header buttons are present
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);

    // Verify that the platform recommendation header is present
    expect(find.text('Platform recommendation'), findsOneWidget);

    // Tap the 'Lottery' category card to navigate to WingoView
    await tester.tap(find.text('Lottery'));
    // Pump transition frames
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    // Verify WingoView is rendered and active
    expect(find.text('How to play'), findsOneWidget);
    expect(find.text('Time remaining'), findsOneWidget);
    expect(find.text('Green'), findsOneWidget);
    expect(find.text('Violet'), findsOneWidget);
    expect(find.text('Red'), findsOneWidget);
  });
}
