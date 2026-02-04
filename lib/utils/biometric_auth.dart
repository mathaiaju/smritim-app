import 'package:local_auth/local_auth.dart';

class BiometricAuth {
  static final _auth = LocalAuthentication();

  static Future<bool> isSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  static Future<bool> canAuthenticate() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> authenticate() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      
      print('🔐 Authenticate check:');
      print('  - Device supported: $isSupported');
      print('  - Can check biometrics: $canCheck');
      
      if (!isSupported || !canCheck) {
        print('  - Biometric not available');
        return false;
      }

      final biometrics = await _auth.getAvailableBiometrics();
      print('  - Available biometrics: $biometrics');
      
      if (biometrics.isEmpty) {
        print('  - No biometrics enrolled');
        return false;
      }

      return await _auth.authenticate(
        localizedReason: 'Authenticate to access SMRITI-M',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (e) {
      print('❌ Biometric error: $e');
      return false;
    }
  }
}
