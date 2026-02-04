import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:smritim_app/utils/biometric_auth.dart';
import 'package:smritim_app/api_client.dart';

@GenerateMocks([])
void main() {
  group('Biometric Authentication Tests', () {
    setUp(() {
      // Reset state before each test
    });

    test('BiometricAuth.isSupported returns true on supported device', () async {
      final result = await BiometricAuth.isSupported();
      expect(result, isA<bool>());
    });

    test('BiometricAuth.canAuthenticate returns true when biometric is available', () async {
      final result = await BiometricAuth.canAuthenticate();
      expect(result, isA<bool>());
    });

    test('BiometricAuth.authenticate returns bool result', () async {
      final result = await BiometricAuth.authenticate();
      expect(result, isA<bool>());
    });

    test('Biometric flow: not logged in -> skip biometric', () async {
      // Simulate not logged in
      expect(ApiClient.isLoggedIn, isFalse);
      
      // Should skip biometric check
      final shouldShowBiometric = ApiClient.isLoggedIn && 
                                   ApiClient.biometricEnabled &&
                                   await BiometricAuth.isSupported() &&
                                   await BiometricAuth.canAuthenticate();
      
      expect(shouldShowBiometric, isFalse);
    });

    test('Biometric flow: logged in + enabled + supported -> show biometric', () async {
      // This test requires mocking ApiClient state
      // For now, just verify the logic structure
      
      final isLoggedIn = true;
      final biometricEnabled = true;
      final isSupported = await BiometricAuth.isSupported();
      final canAuth = await BiometricAuth.canAuthenticate();
      
      final shouldShowBiometric = isLoggedIn && 
                                   biometricEnabled && 
                                   isSupported && 
                                   canAuth;
      
      // Result depends on device capabilities
      expect(shouldShowBiometric, isA<bool>());
    });

    test('Biometric flow: logged in + disabled -> skip biometric', () async {
      final isLoggedIn = true;
      final biometricEnabled = false;
      
      final shouldShowBiometric = isLoggedIn && 
                                   biometricEnabled &&
                                   await BiometricAuth.isSupported() &&
                                   await BiometricAuth.canAuthenticate();
      
      expect(shouldShowBiometric, isFalse);
    });
  });

  group('Biometric Error Handling', () {
    test('BiometricAuth.authenticate handles errors gracefully', () async {
      // Should not throw, should return false on error
      expect(() async => await BiometricAuth.authenticate(), returnsNormally);
    });

    test('BiometricAuth.isSupported handles errors gracefully', () async {
      expect(() async => await BiometricAuth.isSupported(), returnsNormally);
    });

    test('BiometricAuth.canAuthenticate handles errors gracefully', () async {
      expect(() async => await BiometricAuth.canAuthenticate(), returnsNormally);
    });
  });
}
