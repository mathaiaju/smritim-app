import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../utils/file_download.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central API client for SMRITI-M
class ApiClient {
  /// Base API URL (do NOT hardcode – comes from AppConfig)
  static final String baseUrl = AppConfig.apiBaseUrl;

  static String? _token;
  static Map<String, dynamic>? currentUser;

  /* =====================================================
     AUTH / SESSION
  ===================================================== */

  static Future<void> setSession({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    _token = token;
    currentUser = user;
    
    // Persist to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('user', jsonEncode(user));
    
    // Load biometric preference for this user
    final userId = user['id']?.toString() ?? user['username']?.toString() ?? '';
    await prefs.setString('last_user_id', userId);
    biometricEnabled = prefs.getBool('biometric_$userId') ?? false;
  }

  static bool get isLoggedIn => _token != null;

  static bool biometricEnabled = false;

  /// Load session and biometric preference at app startup
  static Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    final userJson = prefs.getString('user');
    if (userJson != null) {
      currentUser = jsonDecode(userJson);
      // Load biometric preference for this specific user
      final userId = currentUser!['id']?.toString() ?? currentUser!['username']?.toString() ?? '';
      biometricEnabled = prefs.getBool('biometric_$userId') ?? false;
    } else {
      // No session, but check if last user had biometric enabled
      final lastUserId = prefs.getString('last_user_id');
      if (lastUserId != null) {
        biometricEnabled = prefs.getBool('biometric_$lastUserId') ?? false;
      }
    }
  }

  /// Enable / disable biometric and persist choice per-user
  static Future<void> enableBiometric(bool enabled) async {
    biometricEnabled = enabled;
    if (currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      final userId = currentUser!['id']?.toString() ?? currentUser!['username']?.toString() ?? '';
      await prefs.setBool('biometric_$userId', enabled);
    }
  }

  static Future<void> logout() async {
    _token = null;
    currentUser = null;
    // Keep biometricEnabled flag - don't reset it
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    // Note: We keep per-user biometric preferences in storage
  }

  static Map<String, String> _headers({bool json = false}) {
    final headers = <String, String>{};

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    if (json) {
      headers['Content-Type'] = 'application/json';
    }

    return headers;
  }

  /* =====================================================
     HTTP HELPERS
  ===================================================== */

  static Future<http.Response> get(String path) {
    final uri = Uri.parse('$baseUrl$path');
    return http.get(uri, headers: _headers());
  }

  static Future<http.Response> post(String path) {
    final uri = Uri.parse('$baseUrl$path');
    return http.post(uri, headers: _headers());
  }

  static Future<http.Response> postJson(
    String path,
    Map<String, dynamic> body,
  ) {
    final uri = Uri.parse('$baseUrl$path');
    return http.post(
      uri,
      headers: _headers(json: true),
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> putJson(
    String path,
    Map<String, dynamic> body,
  ) {
    final uri = Uri.parse('$baseUrl$path');
    return http.put(
      uri,
      headers: _headers(json: true),
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> delete(String path) {
    final uri = Uri.parse('$baseUrl$path');
    return http.delete(uri, headers: _headers());
  }

  /* =====================================================
     FILE DOWNLOAD (WEB SAFE, MOBILE SAFE)
  ===================================================== */

  static Future<void> download(
    String path, {
    required String fileName,
  }) async {
    final uri = Uri.parse('$baseUrl$path');

    final res = await http.get(
      uri,
      headers: _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception('Download failed (${res.statusCode})');
    }

    await downloadFile(res.bodyBytes, fileName);
  }

  /* =====================================================
     RAW BYTES (OPTIONAL – MOBILE USE)
  ===================================================== */

  static Future<Uint8List> downloadBytes(String path) async {
    final uri = Uri.parse('$baseUrl$path');

    final res = await http.get(
      uri,
      headers: _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception('Download failed (${res.statusCode})');
    }

    return res.bodyBytes;
  }
}
