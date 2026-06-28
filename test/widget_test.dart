import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gaming_app/main.dart';

void main() {
  testWidgets('Retro Arcade homepage smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title 'RETRO ARCADE' is present.
    expect(find.text('RETRO ARCADE'), findsOneWidget);

    // Verify that at least one of the games in the menu is visible.
    expect(find.text('Tic-Tac-Toe'), findsOneWidget);
    expect(find.text('Memory Match'), findsOneWidget);

    // Verify the game start button is initially showing the select prompt.
    expect(find.text('SELECT A GAME'), findsOneWidget);
  });
}

