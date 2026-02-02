class AppConfig {
  // Default fallback (local dev)
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    /*defaultValue:
        'http://ec2-52-66-246-238.ap-south-1.compute.amazonaws.com:3000/api',*/
    defaultValue: 'http://localhost:3000/api',
  );
}
