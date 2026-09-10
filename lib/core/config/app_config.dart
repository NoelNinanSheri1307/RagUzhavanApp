class AppConfig {
  static const String appName = 'RagUzhavan';
  static const String appVersion = '1.0.0';

  final String apiBaseUrl;

  const AppConfig({
    this.apiBaseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://backend-production-e510.up.railway.app'),
  });

  bool get isMockMode => apiBaseUrl.trim().isEmpty;

  @override
  String toString() => 'AppConfig(apiBaseUrl: "$apiBaseUrl", isMockMode: $isMockMode)';
}
