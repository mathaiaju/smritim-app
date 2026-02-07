import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'api_client.dart';

/// 🌗 GLOBAL THEME NOTIFIER (used by all scaffolds)
final ValueNotifier<ThemeMode> themeNotifier =
    ValueNotifier<ThemeMode>(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.loadSession();
  await _loadThemePreference();
  runApp(const SmritiSaarathiAdminApp());
}

Future<void> _loadThemePreference() async {
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('dark_mode') ?? false;
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
}

Future<void> saveThemePreference(bool isDark) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('dark_mode', isDark);
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

          home: const SplashScreen(),
        );
      },
    );
  }
}
