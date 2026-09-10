import 'package:flutter_test/flutter_test.dart';
import 'package:rag_uzhavan/data/services/api_service.dart';
import 'package:rag_uzhavan/data/repositories/auth_repository.dart';
import 'package:rag_uzhavan/data/models/numeric_recommendation.dart';
import 'package:rag_uzhavan/data/models/field_sensor_data.dart';
import 'package:rag_uzhavan/data/models/farmer.dart';

void main() {
  group('ApiService & Contract Integration Tests', () {
    test('ApiService empty base URL returns null for all requests without network errors', () async {
      final apiService = ApiService(baseUrl: '');
      expect(apiService.hasBaseUrl, isFalse);

      final loginRes = await apiService.login(username: '9876543210', password: 'pwd', role: 'farmer');
      expect(loginRes, isNull);

      final regionsRes = await apiService.getRegions();
      expect(regionsRes, isNull);

      final ragRes = await apiService.queryRag({'query': 'blast'});
      expect(ragRes, isNull);

      final farmersRes = await apiService.getFarmers();
      expect(farmersRes, isNull);
    });

    test('AuthRepository defaults to MockAuthRepository when API_BASE_URL is empty', () async {
      final apiService = ApiService(baseUrl: '');
      final authRepo = ApiAuthRepository(apiService: apiService);

      final user = await authRepo.login(
        phoneOrUsername: '9876543210',
        password: 'password',
        role: AuthRole.farmer,
      );

      expect(user, isNotNull);
      expect(user!.isFarmer, isTrue);
      expect(user.farmer!.district, equals('Thanjavur'));
      expect(user.farmer!.block, equals('Budalur'));
      expect(user.farmer!.accountStatus, equals('Active'));
    });

    test('NumericRecommendation serialization maintains provenance contract', () {
      const rec = NumericRecommendation(
        parameter: 'Fungicide Dosage',
        value: 0.6,
        unit: 'g/L',
        ruleId: 'RULE-TNAU-BLAST-01',
        sourceTitle: 'TNAU Crop Production Guide 2025',
        publicationDate: '2025-05-10',
        retrievedDate: '2026-09-08',
        region: 'Thanjavur Delta',
        cropApplicability: 'Paddy / Rice',
      );

      final json = rec.toJson();
      expect(json['parameter'], equals('Fungicide Dosage'));
      expect(json['value'], equals(0.6));
      expect(json['unit'], equals('g/L'));
      expect(json['ruleId'], equals('RULE-TNAU-BLAST-01'));
      expect(json['retrievedDate'], equals('2026-09-08'));

      final parsed = NumericRecommendation.fromJson(json);
      expect(parsed.parameter, equals(rec.parameter));
      expect(parsed.value, equals(rec.value));
      expect(parsed.retrievedDate, equals(rec.retrievedDate));
    });

    test('FieldSensorData includes water level, ambient light, and isDemoData badge flag', () {
      final sensor = FieldSensorData(
        sensorId: 'SENS-THANJ-04',
        district: 'Thanjavur',
        soilMoisturePct: 44.5,
        temperatureCelsius: 30.6,
        humidityPct: 82.0,
        nitrogenPpm: 156.0,
        phLevel: 6.8,
        waterLevel: 5.4,
        ambientLight: 34000.0,
        lastUpdated: DateTime.now(),
        isDemoData: true,
      );

      expect(sensor.isDemoData, isTrue);
      expect(sensor.waterLevel, equals(5.4));
      expect(sensor.ambientLight, equals(34000.0));

      final json = sensor.toJson();
      expect(json['isDemoData'], isTrue);
      expect(json['waterLevel'], equals(5.4));
    });

    test('Farmer model contains block, season, accountStatus and lastActivity', () {
      final farmer = Farmer(
        id: 'FARM-101',
        name: 'Muthusamy K.',
        phone: '+91 98765 43210',
        district: 'Thanjavur',
        block: 'Budalur',
        state: 'Tamil Nadu',
        preferredLanguage: 'ta',
        crops: ['Paddy / Rice'],
        landSizeAcres: 3.5,
        agroZone: 'Cauvery Delta Zone',
        season: 'Kuruvai',
        accountStatus: 'Active',
        lastActivity: DateTime.now(),
      );

      expect(farmer.block, equals('Budalur'));
      expect(farmer.season, equals('Kuruvai'));
      expect(farmer.accountStatus, equals('Active'));
    });
  });
}
