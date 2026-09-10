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

    test('Scenario 1: Grounded response returns evidence sources and verified status', () async {
      final response = await repository.fetchPresetScenarioResponse('grounded', language: 'en');

      expect(response.status, equals(ResponseStatus.grounded));
      expect(response.isGrounded, isTrue);
      expect(response.evidenceSources, isNotEmpty);
      expect(response.evidenceSources.first.authorOrInstitute, contains('TNAU'));
      expect(response.averageDataAgeDays, equals(14));
    });

    test('Scenario 2: Clarification response requires missing field details', () async {
      final response = await repository.fetchPresetScenarioResponse('clarification', language: 'en');

      expect(response.status, equals(ResponseStatus.clarificationNeeded));
      expect(response.isGrounded, isFalse);
      expect(response.clarificationQuestions, isNotEmpty);
      expect(response.clarificationQuestions.first.fieldName, equals('soilDrainage'));
    });

    test('Scenario 3: No Data response flags dataset staleness beyond threshold', () async {
      final response = await repository.fetchPresetScenarioResponse('no_data', language: 'en');

      expect(response.status, equals(ResponseStatus.noData));
      expect(response.isGrounded, isFalse);
      expect(response.evidenceSources, isEmpty);
      expect(response.averageDataAgeDays, greaterThan(180));
    });

    test('Scenario 4: Tamil grounded response provides Tamil advisory & Tamil citations', () async {
      final response = await repository.fetchPresetScenarioResponse('tamil_grounded', language: 'ta');

      expect(response.status, equals(ResponseStatus.grounded));
      expect(response.language, equals('ta'));
      expect(response.responseTextTamil, contains('தஞ்சாவூர்'));
      expect(response.evidenceSources.first.excerptTamil, isNotEmpty);
    });

    test('askQuestion routes query to correct scenario based on context keywords', () async {
      final query = RagQuery(
        id: 'Q-01',
        questionText: 'Rice blast in Thanjavur paddy crop',
        language: 'en',
        regionId: 'thanjavur_01',
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

      final res = await repository.askQuestion(query);
      expect(res.status, equals(ResponseStatus.grounded));
    });
  });
}
