import '../models/rag_response.dart';
import '../models/chat_session_model.dart';
import '../models/chat_message_model.dart';
import '../models/knowledge_source_model.dart';

abstract class RagRepository {
  Future<List<ChatSessionModel>> getSessions();
  Future<ChatSessionModel?> createSession();
  Future<List<ChatMessageModel>> getSessionMessages(int sessionId);
  Future<bool> deleteSession(int sessionId);

  Future<RagResponse> askQuestion({
    required int sessionId,
    required String question,
    String mode = 'normal',
    Map<String, dynamic>? sensors,
  });

  Future<List<Map<String, dynamic>>> getSourcesGraph();
  Future<List<KnowledgeSourceModel>> getSources();
  Future<bool> deleteSource(int sourceId);

  Future<bool> getAdminSettings();
  Future<bool> updateAdminSettings(bool enabled);
}
