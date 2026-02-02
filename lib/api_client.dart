import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../utils/file_download.dart';

/// Central API client for SMRITI-M
class ApiClient {
  /// Base API URL (do NOT hardcode – comes from AppConfig)
  static final String baseUrl = AppConfig.apiBaseUrl;

  static String? _token;
  static Map<String, dynamic>? currentUser;

  /* =====================================================
     AUTH / SESSION
  ===================================================== */

  static void setSession({
    required String token,
    required Map<String, dynamic> user,
  }) {
    _token = token;
    currentUser = user;
  }

  static bool get isLoggedIn => _token != null;

  static bool biometricEnabled = false;

  static void enableBiometric(bool enabled) {
    biometricEnabled = enabled;
  }

  static void logout() {
    _token = null;
    currentUser = null;
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
    String fileName = 'document.pdf',
  }) async {
    final uri = Uri.parse('$baseUrl$path');

    final res = await http.get(
      uri,
      headers: _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception('Download failed (${res.statusCode})');
    }

    // ✅ Delegates to platform-specific implementation
    downloadFile(res.bodyBytes, fileName);
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
