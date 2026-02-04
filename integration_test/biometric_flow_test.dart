import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smritim_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Biometric Flow Integration Tests', () {
    testWidgets('First launch: No biometric prompt', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 6));

      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('Check debug logs in console', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 6));

      // Verify console shows:
      // 🔐 Biometric check:
      //   - isLoggedIn: false/true
      //   - biometricEnabled: false/true
      //   - isSupported: false/true
      //   - canAuthenticate: false/true
    });
  });
}
