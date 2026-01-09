import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

// 👇 REQUIRED for Flutter Web download
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Central API client for SMRITI-M
class ApiClient {
  /// 🔧 CHANGE BASE URL IF NEEDED
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

  static Future<http.Response> get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    return http.get(uri, headers: _headers());
  }

  static Future<http.Response> post(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    return http.post(uri, headers: _headers());
  }

  static Future<http.Response> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
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
  ) async {
    final uri = Uri.parse('$baseUrl$path');
    return http.put(
      uri,
      headers: _headers(json: true),
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    return http.delete(uri, headers: _headers());
  }

  /* =====================================================
   🔽 DOWNLOAD (PDF / FILES) — AUTH SAFE
   Works with Authorization header
===================================================== */

  static Future<void> download(String path,
      {String fileName = 'document.pdf'}) async {
    final uri = Uri.parse('$baseUrl$path');

    final res = await http.get(
      uri,
      headers: _headers(), // ✅ Authorization header included
    );

    if (res.statusCode != 200) {
      throw Exception('Download failed (${res.statusCode})');
    }

    // ignore: avoid_web_libraries_in_flutter
    final blob = html.Blob([res.bodyBytes], 'application/pdf');

    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  /* =====================================================
     OPTIONAL: RAW BINARY (mobile / desktop use)
  ===================================================== */

  static Future<Uint8List> downloadBytes(String path) async {
    final res = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception('Download failed (${res.statusCode})');
    }

    return res.bodyBytes;
  }
}
