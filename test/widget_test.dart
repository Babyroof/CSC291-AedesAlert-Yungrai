import 'package:flutter_test/flutter_test.dart';
import 'package:aedes_alert_yungrai/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('LoginScreen renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
