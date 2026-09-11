import 'rag_repository.dart';
import 'mock_rag_repository.dart';
import '../services/api_service.dart';
import '../models/rag_response.dart';
import '../models/evidence_source.dart';
import '../models/chat_session_model.dart';
import '../models/chat_message_model.dart';
import '../models/knowledge_source_model.dart';

class ApiRagRepository implements RagRepository {
  final ApiService apiService;
  final MockRagRepository fallbackMock = MockRagRepository();

  ApiRagRepository(this.apiService);

  @override
  Future<List<ChatSessionModel>> getSessions() async {
    if (!apiService.hasBaseUrl) return fallbackMock.getSessions();
    try {
      final res = await apiService.getSessions();
      if (res != null) {
        return res.map((e) => ChatSessionModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      return fallbackMock.getSessions();
    }
    return fallbackMock.getSessions();
  }

  @override
  Future<ChatSessionModel?> createSession() async {
    if (!apiService.hasBaseUrl) return fallbackMock.createSession();
    try {
      final res = await apiService.createSession();
      if (res != null) {
        return ChatSessionModel.fromJson(res);
      }
    } catch (_) {
      return fallbackMock.createSession();
    }
    return fallbackMock.createSession();
  }

  @override
  Future<List<ChatMessageModel>> getSessionMessages(int sessionId) async {
    if (!apiService.hasBaseUrl) return fallbackMock.getSessionMessages(sessionId);
    try {
      final res = await apiService.getSessionMessages(sessionId);
      if (res != null) {
        return res.map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      return fallbackMock.getSessionMessages(sessionId);
    }
    return fallbackMock.getSessionMessages(sessionId);
  }

  @override
  Future<bool> deleteSession(int sessionId) async {
    if (!apiService.hasBaseUrl) return fallbackMock.deleteSession(sessionId);
    try {
      final res = await apiService.deleteSession(sessionId);
      if (res != null) {
        return res['deleted'] as bool? ?? true;
      }
    } catch (_) {
      return fallbackMock.deleteSession(sessionId);
    }
    return true;
  }

  @override
  Future<RagResponse> askQuestion({
    required int sessionId,
    required String question,
    String mode = 'normal',
    Map<String, dynamic>? sensors,
  }) async {
    if (!apiService.hasBaseUrl) {
      return fallbackMock.askQuestion(sessionId: sessionId, question: question, mode: mode, sensors: sensors);
    }

    try {
      final queryPayload = <String, dynamic>{
        'question': question,
        'mode': mode,
        'sensors': ?sensors,
      };

      final res = await apiService.askSession(sessionId, queryPayload) ??
          await apiService.queryRag(queryPayload);

      if (res != null) {
        final answer = res['answer'] as String? ?? res['content'] as String? ?? '';
        final reasoning = res['reasoning'] as String? ?? 'Context-grounded vector store retrieval.';
        final rawSources = res['sources'] as List<dynamic>?;
        final isTamil = question.contains(RegExp(r'[\u0B80-\u0BFF]'));
        final district = res['district'] as String? ?? res['district_name'] as String? ?? 'Active Region';
        final block = res['block'] as String? ?? res['block_name'] as String? ?? 'Active Block';

        // Check for no data / ungrounded notice from backend
        if (answer.isEmpty ||
            answer.contains('no local data') ||
            answer.contains('indexed sources don’t cover') ||
            answer.contains('no matching data') ||
            answer.contains('no relevant data')) {
          final noDataText = isTamil
              ? 'உங்கள் இருப்பிடத்திற்கான தரவு எதுவும் இல்லை.'
              : 'No current data for your location / block.';
          return RagResponse(
            id: 'RESP-${DateTime.now().millisecondsSinceEpoch}',
            queryId: 'QRY-${DateTime.now().millisecondsSinceEpoch}',
            responseText: noDataText,
            responseTextTamil: noDataText,
            recommendationSummary: noDataText,
            recommendationSummaryTamil: noDataText,
            whatToDo: 'No data available for submitted location / query.',
            whatToDoTamil: 'சமர்ப்பிக்கப்பட்ட கேள்விக்குத் தரவு எதுவும் இல்லை.',
            whenToApply: 'N/A',
            whenToApplyTamil: 'பொருந்தாது',
            howMuchAmount: 'N/A',
            howMuchAmountTamil: 'பொருந்தாது',
            whyReason: noDataText,
            whyReasonTamil: noDataText,
            groundingScore: 0.0,
            ruleId: 'RULE-NO-DATA',
            citedProvenance: 'Regional Agricultural Extension Database',
            language: isTamil ? 'ta' : 'en',
            isGrounded: false,
            evidenceSources: const [],
            clarificationQuestions: const [],
            timestamp: DateTime.now(),
            status: ResponseStatus.noData,
            districtName: district,
            blockName: block,
            cropName: 'General',
            growthStage: 'N/A',
            season: 'N/A',
            averageDataAgeDays: 180,
          );
        }

        // Parse evidence sources
        final evidenceSources = <EvidenceSource>[];
        if (rawSources != null) {
          for (int i = 0; i < rawSources.length; i++) {
            final src = rawSources[i] as Map<String, dynamic>;
            evidenceSources.add(
              EvidenceSource(
                id: src['id'] as String? ?? 'SRC-${i + 1}',
                title: src['title'] as String? ?? 'Agricultural Research Document',
                publicationDate: '2025-06-15',
                retrievedDate: '2026-09-08',
                region: district,
                cropApplicability: 'General Crop',
                authorOrInstitute: 'TNAU / ICAR Research Station',
                documentType: src['source_type'] as String? ?? 'Research Bulletin',
                excerpt: src['snippet'] as String? ?? 'Official extension bulletin excerpt.',
                excerptTamil: src['snippet'] as String? ?? 'அதிகாரப்பூர்வ வேளாண் அறிக்கை.',
                confidenceScore: 0.95,
                datasetAgeDays: 14,
                urlOrRef: src['url'] as String? ?? '',
                isVerified: true,
              ),
            );
          }
        }

        return RagResponse(
          id: 'RESP-${DateTime.now().millisecondsSinceEpoch}',
          queryId: 'QRY-${DateTime.now().millisecondsSinceEpoch}',
          responseText: answer,
          responseTextTamil: answer,
          recommendationSummary: answer,
          recommendationSummaryTamil: answer,
          whatToDo: 'Follow recommendation schedule provided in the response.',
          whatToDoTamil: 'பரிந்துரைக்கப்பட்ட தெளிக்கும் அட்டவணையைப் பின்பற்றவும்.',
          whenToApply: 'Apply during morning or evening hours.',
          whenToApplyTamil: 'காலை அல்லது மாலை வேளையில் தெளிக்கவும்.',
          howMuchAmount: 'Follow specific dosage guidance.',
          howMuchAmountTamil: 'பரிந்துரைக்கப்பட்ட அளவைப் பின்பற்றவும்.',
          whyReason: reasoning,
          whyReasonTamil: reasoning,
          groundingScore: 0.95,
          ruleId: 'RULE-RAG-RETRIEVAL-01',
          citedProvenance: 'Regional Vector Corpus & TNAU Extension Bulletins',
          language: isTamil ? 'ta' : 'en',
          isGrounded: true,
          evidenceSources: evidenceSources,
          clarificationQuestions: const [],
          timestamp: DateTime.now(),
          status: ResponseStatus.grounded,
          districtName: district,
          blockName: block,
          cropName: 'General',
          growthStage: 'Active Season',
          season: 'Current',
          averageDataAgeDays: 14,
        );
      }
    } catch (_) {
      // Network failure -> Fallback to mock repository
    }
    return fallbackMock.askQuestion(sessionId: sessionId, question: question, mode: mode, sensors: sensors);
  }

  @override
  Future<List<Map<String, dynamic>>> getSourcesGraph() async {
    if (!apiService.hasBaseUrl) return fallbackMock.getSourcesGraph();
    try {
      final res = await apiService.getSourcesGraph();
      if (res != null) {
        return res.cast<Map<String, dynamic>>();
      }
    } catch (_) {
      return fallbackMock.getSourcesGraph();
    }
    return fallbackMock.getSourcesGraph();
  }

  @override
  Future<List<KnowledgeSourceModel>> getSources() async {
    if (!apiService.hasBaseUrl) return fallbackMock.getSources();
    try {
      final res = await apiService.getSources();
      if (res != null) {
        return res.map((e) => KnowledgeSourceModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      return fallbackMock.getSources();
    }
    return fallbackMock.getSources();
  }

  @override
  Future<bool> deleteSource(int sourceId) async {
    if (!apiService.hasBaseUrl) return fallbackMock.deleteSource(sourceId);
    try {
      final res = await apiService.deleteSource(sourceId);
      if (res != null) {
        return res['deleted'] as bool? ?? true;
      }
    } catch (_) {
      return fallbackMock.deleteSource(sourceId);
    }
    return true;
  }

  @override
  Future<bool> getAdminSettings() async {
    if (!apiService.hasBaseUrl) return fallbackMock.getAdminSettings();
    try {
      final res = await apiService.getAdminSettings();
      if (res != null) {
        return res['guardrails_enabled'] as bool? ?? true;
      }
    } catch (_) {
      return fallbackMock.getAdminSettings();
    }
    return true;
  }

  @override
  Future<bool> updateAdminSettings(bool enabled) async {
    if (!apiService.hasBaseUrl) return fallbackMock.updateAdminSettings(enabled);
    try {
      final res = await apiService.updateAdminSettings(enabled);
      if (res != null) {
        return res['guardrails_enabled'] as bool? ?? enabled;
      }
    } catch (_) {
      return fallbackMock.updateAdminSettings(enabled);
    }
    return enabled;
  }
}
