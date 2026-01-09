import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

/// 🌗 GLOBAL THEME NOTIFIER (used by all scaffolds)
final ValueNotifier<ThemeMode> themeNotifier =
    ValueNotifier<ThemeMode>(ThemeMode.light);

void main() {
  runApp(const SmritiSaarathiAdminApp());
}

class SmritiSaarathiAdminApp extends StatelessWidget {
  const SmritiSaarathiAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          title: 'SMRITI-SAARATHI-M',
          debugShowCheckedModeBanner: false,
          themeMode: mode,

          /// ☀️ LIGHT THEME
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.indigo,
            scaffoldBackgroundColor: const Color(0xFFF4F7FB),
            useMaterial3: true,
          ),

          /// 🌙 DARK THEME
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
            ),
          ),

          home: const LoginScreen(),
        );
      },
    );
  }
}
