import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gaming_app/main.dart';
import 'package:gaming_app/viewmodels/wingo_viewmodel.dart';
import 'package:gaming_app/viewmodels/k3_viewmodel.dart';

void main() {
  testWidgets('Daman homepage smoke test and Wingo/K3 navigation', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify header buttons are present
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);

    // Verify that the platform recommendation header is present
    expect(find.text('Platform recommendation'), findsOneWidget);

    // Tap the 'Lottery' category card to navigate to WingoView
    await tester.tap(find.text('Lottery'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    // Verify WingoView is rendered and active
    expect(find.text('How to play'), findsOneWidget);
    expect(find.text('Time remaining'), findsOneWidget);
    expect(find.text('Green'), findsOneWidget);
    expect(find.text('Violet'), findsOneWidget);
    expect(find.text('Red'), findsOneWidget);

    // Go back to Home Screen
    await tester.tap(find.byIcon(Icons.arrow_back_ios));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    // Scroll down to bring K3 recommendation card into view
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();

    // Tap the 'K3' recommendation card to navigate to K3View
    await tester.tap(find.text('K3'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    // Verify K3View is rendered and active
    expect(find.text('How to play'), findsOneWidget);
    expect(find.text('Time remaining'), findsOneWidget);
    expect(find.text('Small'), findsWidgets);
    expect(find.text('Big'), findsWidgets);
    expect(find.text('Even'), findsWidgets);
    expect(find.text('Odd'), findsWidgets);

    // Clean up singleton background timers
    WingoViewModel().stopTimer();
    K3ViewModel().stopTimer();
  });
}
