class AppConfig {
  // Default fallback (local dev)
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://34.47.229.228:3000/api',
    //defaultValue: 'http://localhost:3000/api',
  );
}
