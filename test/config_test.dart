import 'package:flutter_test/flutter_test.dart';
import 'package:rag_uzhavan/core/config/app_config.dart';

void main() {
  group('AppConfig Tests', () {
    test('AppConfig defaults to mock mode when API_BASE_URL is empty', () {
      const config = AppConfig(apiBaseUrl: '');
      expect(config.isMockMode, isTrue);
      expect(AppConfig.appName, equals('RagUzhavan'));
    });

    test('AppConfig disables mock mode when API_BASE_URL is provided', () {
      const config = AppConfig(apiBaseUrl: 'https://raguzhavan-backend.up.railway.app');
      expect(config.isMockMode, isFalse);
      expect(config.apiBaseUrl, equals('https://raguzhavan-backend.up.railway.app'));
    });
  });
}
