import 'package:flutter_test/flutter_test.dart';
import 'package:new_project_test/main.dart';

void main() {
  testWidgets('Sign in requires credentials before contacting Firebase', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    await tester.ensureVisible(find.text('Login'));
    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Enter your email and password'), findsOneWidget);
    expect(find.text('Admin dashboard'), findsNothing);
  });
}
