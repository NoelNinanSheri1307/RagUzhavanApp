import 'package:flutter_test/flutter_test.dart';
import 'package:rag_uzhavan/data/repositories/mock_rag_repository.dart';

void main() {
  group('MockRagRepository API Session Tests', () {
    late MockRagRepository repository;

    setUp(() {
      repository = MockRagRepository();
    });

    test('createSession creates a valid session model', () async {
      final session = await repository.createSession();

      expect(session, isNotNull);
      expect(session!.id, isPositive);
      expect(session.title, isNotEmpty);
    });

    test('getSessions returns session list', () async {
      final sessions = await repository.getSessions();

      expect(sessions, isNotEmpty);
      expect(sessions.first.id, equals(1));
    });

    test('getSessionMessages returns message list for session', () async {
      final messages = await repository.getSessionMessages(1);

      expect(messages, isNotEmpty);
      expect(messages.any((m) => m.role == 'assistant'), isTrue);
    });

    test('askQuestion submits query and returns RagResponse', () async {
      final response = await repository.askQuestion(
        sessionId: 1,
        question: 'How to treat Rice Blast in Paddy?',
        mode: 'normal',
      );

      expect(response.responseText, isNotEmpty);
      expect(response.recommendationSummary, contains('Tricyclazole'));
      expect(response.evidenceSources, isNotEmpty);
    });
  });
}

