import 'package:flutter/material.dart';
import '../../api_client.dart';
import '../../utils/biometric_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool supported = false;

  @override
  void initState() {
    super.initState();
    _checkSupport();
  }

  Future<void> _checkSupport() async {
    supported = await BiometricAuth.isSupported();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Enable Biometric Login"),
            subtitle: const Text("Use fingerprint / face authentication"),
            value: ApiClient.biometricEnabled,
            onChanged: supported
                ? (v) {
                    setState(() {
                      ApiClient.enableBiometric(v);
                    });
                  }
                : null,
          ),
          if (!supported)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Biometric authentication not supported on this device",
                style: TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}
