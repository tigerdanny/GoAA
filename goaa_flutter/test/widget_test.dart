// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:goaa_flutter/main.dart';

void main() {
  testWidgets('GoAA app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GoAAApp());

    // Wait for initial frame
    await tester.pump();

    // Verify that the splash screen is shown
    expect(find.text('GoAA'), findsOneWidget);
    expect(find.text('分帳神器'), findsOneWidget);
    
    // Clean up any pending animations
    await tester.pumpAndSettle(const Duration(seconds: 2));
  });
}
