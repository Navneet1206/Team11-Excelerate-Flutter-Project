// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:t/app/app.dart';

void main() {
  testWidgets('Prototype navigation smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SkillTrackApp());

    // Login screen
    expect(find.text('Login Screen (placeholder)'), findsOneWidget);

    // Navigate to Home
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);

    // Navigate to Programs
    await tester.tap(find.text('Browse Programs'));
    await tester.pumpAndSettle();
    expect(find.text('Programs'), findsOneWidget);

    // Open details placeholder
    await tester.tap(find.text('Open Program Details (placeholder)'));
    await tester.pumpAndSettle();
    expect(find.text('Program Details'), findsOneWidget);
    expect(find.text('Enroll'), findsOneWidget);
  });
}
