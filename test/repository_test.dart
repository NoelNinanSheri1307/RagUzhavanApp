import 'package:flutter_test/flutter_test.dart';
import 'package:rag_uzhavan/data/repositories/mock_rag_repository.dart';
import 'package:rag_uzhavan/data/models/rag_query.dart';
import 'package:rag_uzhavan/data/models/crop_context.dart';
import 'package:rag_uzhavan/data/models/rag_response.dart';

void main() {
  group('MockRagRepository Scenario Tests', () {
    late MockRagRepository repository;

    setUp(() {
      repository = MockRagRepository();
    });

    test('Scenario 1: Grounded paddy advisory returns deterministic rule outputs & citations', () async {
      final response = await repository.fetchPresetScenarioResponse('grounded', language: 'en');

      expect(response.status, equals(ResponseStatus.grounded));
      expect(response.isGrounded, isTrue);
      expect(response.recommendationSummary, contains('Tricyclazole'));
      expect(response.ruleId, equals('RULE-TNAU-BLAST-01'));
      expect(response.groundingScore, greaterThan(0.9));
      expect(response.evidenceSources, isNotEmpty);
      expect(response.blockName, equals('Budalur'));
    });

    test('Scenario 2: Missing location query triggers clarification question', () async {
      final query = RagQuery(
        id: 'Q-UNSPECIFIED',
        questionText: 'Should I irrigate my field this week?', // No location specified
        language: 'en',
        regionId: '',
        cropContext: const CropContext(
          cropName: 'Paddy',
          growthStage: 'Tillering',
          irrigationType: 'Canal',
          soilPH: '6.8',
          moistureLevel: 'High',
          season: 'Kuruvai',
        ),
        timestamp: DateTime.now(),
      );

      final response = await repository.askQuestion(query);

      expect(response.status, equals(ResponseStatus.clarificationNeeded));
      expect(response.isGrounded, isFalse);
      expect(response.clarificationQuestions, isNotEmpty);
      expect(response.clarificationQuestions.first.fieldName, equals('districtName'));
    });

    test('Scenario 3: No Data state for block flags staleness and refuses fallback substitution', () async {
      final response = await repository.fetchPresetScenarioResponse('no_data', language: 'en');

      expect(response.status, equals(ResponseStatus.noData));
      expect(response.isGrounded, isFalse);
      expect(response.blockName, equals('Kadaladi'));
      expect(response.evidenceSources, isEmpty);
      expect(response.averageDataAgeDays, greaterThan(180));
    });

    test('Scenario 4: Tamil grounded advisory provides Tamil rule outputs & citations', () async {
      final response = await repository.fetchPresetScenarioResponse('tamil_grounded', language: 'ta');

      expect(response.status, equals(ResponseStatus.grounded));
      expect(response.language, equals('ta'));
      expect(response.recommendationSummaryTamil, contains('ட்ரைசைக்ளசோல்'));
      expect(response.blockNameTamil, contains('பூதலூர்'));
    });

    test('Low-bandwidth SMS message enforces 50 KB max constraint and 1.8 KB payload', () async {
      final query = RagQuery(
        id: 'Q-SMS',
        questionText: 'Rice blast Budalur block',
        language: 'en',
        regionId: 'thanjavur_budalur',
        cropContext: const CropContext(
          cropName: 'Paddy',
          growthStage: 'Tillering',
          irrigationType: 'Canal',
          soilPH: '6.8',
          moistureLevel: 'High',
          season: 'Kuruvai',
        ),
        timestamp: DateTime.now(),
        isLowBandwidth: true,
      );

      final msg = await repository.sendLowBandwidthQuery(query);

      expect(msg.payloadSizeBytes, equals(1840));
      expect(msg.payloadSizeKb, closeTo(1.8, 0.1));
      expect(msg.maxConstraintKb, equals(50.0));
      expect(msg.recommendation, isNotEmpty);
    });
  });
}
