// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:iwaymaps/LOGIN%20SIGNUP/SignIn.dart';
import 'package:iwaymaps/LOGIN%20SIGNUP/SignUp.dart';


void main() {
  testWidgets('Counter increments smoke test', (widgetTester) async {

    await widgetTester.pumpWidget(const SignUp());
    final buttonFinder = find.text('Sign Up');
    expect(buttonFinder,findsOneWidget);
    await widgetTester.tap(buttonFinder);
    await widgetTester.pump();


  });
}
