// This is a basic Flutter widget test for LangBuddyApp.
import 'package:flutter_test/flutter_test.dart';
import 'package:langbuddy_language_learning_application/main.dart';

void main() {
  testWidgets('LangBuddy home screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LangBuddyApp());

    // Verify that the greeting is rendered.
    expect(find.textContaining('Hello, Learner!'), findsOneWidget);

    // Verify that the main Explore features list exists.
    expect(find.textContaining('Explore Features'), findsOneWidget);
  });
}
