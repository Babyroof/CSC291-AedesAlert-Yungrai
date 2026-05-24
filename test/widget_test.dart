import 'package:flutter_test/flutter_test.dart';
import 'package:aedes_alert_yungrai/features/auth/presentation/screens/login_screen.dart';
import 'package:aedes_alert_yungrai/features/auth/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  testWidgets('LoginScreen renders without error', (WidgetTester tester) async {
    final mockAuthService = MockAuthService();
    await tester.pumpWidget(
      MaterialApp(home: LoginScreen(authService: mockAuthService)),
    );
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
