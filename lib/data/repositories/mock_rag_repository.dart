import 'rag_repository.dart';
import '../models/rag_response.dart';
import '../models/evidence_source.dart';
import '../models/chat_session_model.dart';
import '../models/chat_message_model.dart';
import '../models/knowledge_source_model.dart';
import '../models/clarification_question.dart';
import '../models/rag_query.dart';
import '../models/low_bandwidth_message.dart';
import '../models/region.dart';
import '../models/field_sensor_data.dart';

class MockRagRepository implements RagRepository {
  final List<ChatSessionModel> _mockSessions = [
    ChatSessionModel(id: 1, title: 'Rice Blast Disease Advisory', createdAt: DateTime.now().subtract(const Duration(hours: 2))),
  ];

  final Map<int, List<ChatMessageModel>> _mockMessages = {
    1: [
      ChatMessageModel(
        id: 101,
        role: 'user',
        content: 'Should I apply fungicide for Leaf Blast in Budalur block?',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ChatMessageModel(
        id: 102,
        role: 'assistant',
        content: 'Apply Tricyclazole 75% WP @ 0.6 g/L. Efficacy is 92.4% against Leaf Blast in Delta clay soils under high humidity (>85%). Avoid excess late Nitrogen topdressing.',
        reasoning: 'Retrieved 4 passages from TNAU advisories. Evaluated humidity levels and soil clay composition.',
        sources: [
          {
            'id': 'doc-1',
            'title': 'TNAU Crop Production Guide: Paddy 2025.pdf',
            'snippet': 'Tricyclazole 75 WP @ 0.6g/l shows 92.4% efficacy against Leaf Blast in Delta clay soils under high humidity.',
            'page': 42,
            'kind': 'doc',
          }
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 1)),
      ),
    ],
  };

  bool _guardrailsEnabled = true;

  @override
  Future<List<ChatSessionModel>> getSessions() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_mockSessions);
  }

  @override
  Future<ChatSessionModel?> createSession() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final newSession = ChatSessionModel(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: 'New Chat',
      createdAt: DateTime.now(),
    );
    _mockSessions.insert(0, newSession);
    _mockMessages[newSession.id] = [];
    return newSession;
  }

  @override
  Future<List<ChatMessageModel>> getSessionMessages(int sessionId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _mockMessages[sessionId] ?? [];
  }

  @override
  Future<bool> deleteSession(int sessionId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _mockSessions.removeWhere((s) => s.id == sessionId);
    _mockMessages.remove(sessionId);
    return true;
  }

  @override
  Future<RagResponse> askQuestion({
    required int sessionId,
    required String question,
    String mode = 'normal',
    Map<String, dynamic>? sensors,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final isTamil = question.contains(RegExp(r'[\u0B80-\u0BFF]'));
    final msgId = DateTime.now().millisecondsSinceEpoch % 1000000;
    final messages = _mockMessages.putIfAbsent(sessionId, () => []);

    // Check metrics mode slot clarification
    if (mode == 'metrics' && (!question.toLowerCase().contains('thanjavur') && !question.toLowerCase().contains('district'))) {
      final clarifyText = isTamil
          ? 'மாவட்ட விவரம் தேவை: தயவுசெய்து உங்கள் மாவட்டம் மற்றும் பயிர் விவரத்தைக் குறிப்பிடவும்.'
          : 'Clarification Needed: Please specify your District name (e.g. Thanjavur) and Crop type (e.g. Paddy) to apply region slot filtering.';

      messages.add(ChatMessageModel(
        id: msgId,
        role: 'user',
        content: question,
        createdAt: DateTime.now(),
      ));
      messages.add(ChatMessageModel(
        id: msgId + 1,
        role: 'assistant',
        content: clarifyText,
        reasoning: 'Metrics mode active: Missing district slot parameter.',
        createdAt: DateTime.now(),
      ));

      return RagResponse(
        id: 'RESP-$msgId',
        queryId: 'QRY-$msgId',
        responseText: clarifyText,
        responseTextTamil: clarifyText,
        recommendationSummary: clarifyText,
        recommendationSummaryTamil: clarifyText,
        whatToDo: 'Specify missing District or Crop metrics.',
        whatToDoTamil: 'விவரங்களை படிவத்தில் குறிப்பிடவும்.',
        whenToApply: 'N/A',
        whenToApplyTamil: 'பொருந்தாது',
        howMuchAmount: 'N/A',
        howMuchAmountTamil: 'பொருந்தாது',
        whyReason: 'Metrics mode requires explicit district or crop parameters.',
        whyReasonTamil: 'மாவட்ட அல்லது பயிர் விவரம் தேவை.',
        groundingScore: 0.80,
        ruleId: 'RULE-SLOT-CLARIFICATION',
        citedProvenance: 'Metrics Slot Clarification Engine',
        language: isTamil ? 'ta' : 'en',
        isGrounded: false,
        evidenceSources: const [],
        clarificationQuestions: const [
          ClarificationQuestion(
            id: 'Q-DIST',
            questionText: 'Which District is your farm located in?',
            questionTextTamil: 'உங்கள் பண்ணை எந்த மாவட்டத்தில் உள்ளது?',
            fieldName: 'district',
            options: ['Thanjavur', 'Tiruvarur', 'Nagapattinam'],
            optionsTamil: ['தஞ்சாவூர்', 'திருவாரூர்', 'நாகப்பட்டினம்'],
          ),
          ClarificationQuestion(
            id: 'Q-CROP',
            questionText: 'What is your primary crop?',
            questionTextTamil: 'உங்கள் முதன்மை பயிர் எது?',
            fieldName: 'crop',
            options: ['Paddy', 'Groundnut', 'Sugarcane'],
            optionsTamil: ['நெல்', 'நிலக்கடலை', 'கரும்பு'],
          ),
        ],
        timestamp: DateTime.now(),
        status: ResponseStatus.clarificationNeeded,
        districtName: 'Unspecified',
        blockName: 'Unspecified',
        cropName: 'Unspecified',
        growthStage: 'Unspecified',
        season: 'Unspecified',
        averageDataAgeDays: 0,
      );
    }

    // Check sensor mode telemetry clarification
    if (mode == 'sensor') {
      final wl = sensors?['water_level']?.toString().trim() ?? '';
      final temp = sensors?['temperature']?.toString().trim() ?? '';
      final hum = sensors?['humidity']?.toString().trim() ?? '';

      if (wl.isEmpty || temp.isEmpty || hum.isEmpty) {
        final clarifyText = isTamil
            ? 'சென்சார் அளவீடு தேவை: நீர் மட்டம், வெப்பநிலை மற்றும் ஈரப்பதம் ஆகிய மூன்றையும் குறிப்பிடவும்.'
            : 'Clarification Needed: Sensor Mode requires Water Level, Temperature, and Humidity readings. Please fill in all 3 telemetry fields.';

        messages.add(ChatMessageModel(
          id: msgId,
          role: 'user',
          content: question,
          createdAt: DateTime.now(),
        ));
        messages.add(ChatMessageModel(
          id: msgId + 1,
          role: 'assistant',
          content: clarifyText,
          reasoning: 'Sensor mode active: Telemetry parameters incomplete.',
          createdAt: DateTime.now(),
        ));

        return RagResponse(
          id: 'RESP-$msgId',
          queryId: 'QRY-$msgId',
          responseText: clarifyText,
          responseTextTamil: clarifyText,
          recommendationSummary: clarifyText,
          recommendationSummaryTamil: clarifyText,
          whatToDo: 'Provide missing sensor telemetry fields (Water Level, Temperature, Humidity).',
          whatToDoTamil: 'சென்சார் அளவீடுகளை உள்ளிடவும்.',
          whenToApply: 'N/A',
          whenToApplyTamil: 'பொருந்தாது',
          howMuchAmount: 'N/A',
          howMuchAmountTamil: 'பொருந்தாது',
          whyReason: 'Sensor mode requires complete telemetry parameters.',
          whyReasonTamil: 'சென்சார் அளவீடுகள் தேவை.',
          groundingScore: 0.80,
          ruleId: 'RULE-SENSOR-CLARIFICATION',
          citedProvenance: 'Sensor Telemetry Clarification Engine',
          language: isTamil ? 'ta' : 'en',
          isGrounded: false,
          evidenceSources: const [],
          clarificationQuestions: const [
            ClarificationQuestion(
              id: 'Q-WL',
              questionText: 'What is the current water level in cm?',
              questionTextTamil: 'தற்போதைய நீர் மட்டம் என்ன (செ.மீ)?',
              fieldName: 'water_level',
              options: ['2.0 cm', '5.0 cm', '8.0 cm'],
              optionsTamil: ['2.0 செ.மீ', '5.0 செ.மீ', '8.0 செ.மீ'],
            ),
            ClarificationQuestion(
              id: 'Q-TEMP',
              questionText: 'What is the field temperature?',
              questionTextTamil: 'நிலத்தின் வெப்பநிலை என்ன?',
              fieldName: 'temperature',
              options: ['28°C', '32°C', '35°C'],
              optionsTamil: ['28°C', '32°C', '35°C'],
            ),
          ],
          timestamp: DateTime.now(),
          status: ResponseStatus.clarificationNeeded,
          districtName: 'Unspecified',
          blockName: 'Unspecified',
          cropName: 'Unspecified',
          growthStage: 'Unspecified',
          season: 'Unspecified',
          averageDataAgeDays: 0,
        );
      }
    }

    final reasoningText = 'Retrieved 4 vector passages from TNAU extension bulletins. Applied region filter for Thanjavur district.';
    final answerText = isTamil
        ? 'ட்ரைசைக்ளசோல் 75% WP @ 0.6 கிராம்/லிட்டர் தெளிக்கவும். தஞ்சாவூர் காவிரி டெல்டா களிமண் நிலங்களில் 92.4% திறன் கொண்டது.'
        : 'Apply Tricyclazole 75% WP @ 0.6 g/L. Efficacy is 92.4% against Leaf Blast in Delta clay soils under high humidity (>85%).';

    messages.add(ChatMessageModel(
      id: msgId,
      role: 'user',
      content: question,
      createdAt: DateTime.now(),
    ));

    messages.add(ChatMessageModel(
      id: msgId + 1,
      role: 'assistant',
      content: answerText,
      reasoning: reasoningText,
      sources: [
        {
          'id': 'doc-1',
          'title': 'TNAU Crop Production Guide 2025.pdf',
          'snippet': 'Tricyclazole 75 WP @ 0.6g/l shows 92.4% efficacy in Delta clay soils.',
          'kind': 'doc',
        },
      ],
      createdAt: DateTime.now(),
    ));

    return RagResponse(
      id: 'RESP-$msgId',
      queryId: 'QRY-$msgId',
      responseText: answerText,
      responseTextTamil: answerText,
      recommendationSummary: answerText,
      recommendationSummaryTamil: answerText,
      whatToDo: 'Apply Tricyclazole 75% WP @ 0.6 g/L during cool morning hours.',
      whatToDoTamil: 'காலை வேளையில் 0.6 கிராம்/லிட்டர் தெளிக்கவும்.',
      whenToApply: 'Apply during early disease onset.',
      whenToApplyTamil: 'நோய் அறிகுறி தென்பட்டவுடன் தெளிக்கவும்.',
      howMuchAmount: '0.6 g/L',
      howMuchAmountTamil: '0.6 கிராம்/லிட்டர்',
      whyReason: reasoningText,
      whyReasonTamil: reasoningText,
      groundingScore: 0.95,
      ruleId: 'RULE-TNAU-BLAST-01',
      citedProvenance: 'TNAU Crop Production Guide 2025',
      language: isTamil ? 'ta' : 'en',
      isGrounded: true,
      evidenceSources: const [
        EvidenceSource(
          id: 'SRC-01',
          title: 'TNAU Crop Production Guide: Paddy Disease Protocols 2025',
          publicationDate: '2025-05-10',
          authorOrInstitute: 'Tamil Nadu Agricultural University (TNAU)',
          documentType: 'Research Bulletin',
          excerpt: 'Tricyclazole 75 WP @ 0.6g/l shows 92.4% efficacy against Leaf Blast in Delta clay soils.',
          excerptTamil: 'ட்ரைசைக்ளசோல் 75 WP @ 0.6g/l தெளிப்பது 92.4% பலன் அளிக்கும்.',
          confidenceScore: 0.95,
          datasetAgeDays: 14,
          urlOrRef: 'TNAU_Paddy_2025.pdf',
          isVerified: true,
        ),
      ],
      clarificationQuestions: const [],
      timestamp: DateTime.now(),
      status: ResponseStatus.grounded,
      districtName: 'Thanjavur',
      blockName: 'Budalur',
      cropName: 'Paddy / Rice',
      growthStage: 'Tillering',
      season: 'Kuruvai',
      averageDataAgeDays: 14,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getSourcesGraph() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return const [
      {'id': 1, 'title': 'TNAU Crop Production Guide: Paddy 2025', 'source_type': 'pdf', 'origin': 'file', 'chunk_count': 18},
      {'id': 2, 'title': 'ICAR-NRRI Kuruvai Season Blast Outbreak Advisory', 'source_type': 'pdf', 'origin': 'file', 'chunk_count': 14},
      {'id': 3, 'title': 'IMD Agromet Weather & Rainfall Forecast (Thanjavur)', 'source_type': 'url', 'origin': 'url', 'chunk_count': 8},
      {'id': 4, 'title': 'Agmarknet Mandi Paddy & Groundnut Price Feeds', 'source_type': 'json', 'origin': 'api', 'chunk_count': 24},
    ];
  }

  @override
  Future<List<KnowledgeSourceModel>> getSources() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return [
      KnowledgeSourceModel(id: 1, sourceType: 'pdf', title: 'TNAU Crop Production Guide 2025.pdf', origin: 'file', ref: 'TNAU_2025.pdf', chunkCount: 18, createdAt: DateTime.now()),
      KnowledgeSourceModel(id: 2, sourceType: 'pdf', title: 'ICAR Kuruvai Blast Advisory.pdf', origin: 'file', ref: 'ICAR_Blast.pdf', chunkCount: 14, createdAt: DateTime.now()),
    ];
  }

  @override
  Future<bool> deleteSource(int sourceId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return true;
  }

  @override
  Future<bool> getAdminSettings() async {
    return _guardrailsEnabled;
  }

  @override
  Future<bool> updateAdminSettings(bool enabled) async {
    _guardrailsEnabled = enabled;
    return _guardrailsEnabled;
  }

  Future<LowBandwidthMessage> sendLowBandwidthQuery(RagQuery query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return LowBandwidthMessage(
      id: 'SMS-PAYLOAD-001',
      queryText: query.questionText,
      payloadSizeBytes: 1840,
      maxConstraintBytes: 51200,
      recommendation: 'Tricyclazole 75% WP @ 0.6 g/L spray.',
      recommendationTamil: 'ட்ரைசைக்ளசோல் 75% WP @ 0.6 கிராம்/லிட்டர் தெளிக்கவும்.',
      essentialReason: 'Efficacy 92.4% in Delta clay soil under high humidity (>85%).',
      essentialReasonTamil: 'காவிரி டெல்டா களிமண்ணில் 92.4% நோய் கட்டுப்பாடு பலன்.',
      citedSource: 'TNAU-CPG-2025/BLAST',
      publicationDate: '2025-05-10',
      dataAgeDays: 14,
      queueStatus: 'delivered',
      timestamp: DateTime.now(),
    );
  }

  Future<List<Region>> fetchSupportedRegions() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return const [
      Region(
        id: 'thanjavur_budalur',
        stateName: 'Tamil Nadu',
        districtName: 'Thanjavur',
        districtNameTamil: 'தஞ்சாவூர்',
        blockName: 'Budalur',
        blockNameTamil: 'பூதலூர்',
        agroClimaticZone: 'Cauvery Delta Zone',
        dominantSoilType: 'Clay / Deltaic Alluvium',
        primarySeason: 'Kuruvai (Jun-Sep)',
        latitude: 10.786,
        longitude: 79.137,
        hasActiveStationData: true,
      ),
      Region(
        id: 'coimbatore_thondamuthur',
        stateName: 'Tamil Nadu',
        districtName: 'Coimbatore',
        districtNameTamil: 'கோயம்புத்தூர்',
        blockName: 'Thondamuthur',
        blockNameTamil: 'தொண்டாமுத்தூர்',
        agroClimaticZone: 'Western Zone',
        dominantSoilType: 'Red Loam / Gravelly',
        primarySeason: 'Kharif / Rabi',
        latitude: 11.005,
        longitude: 76.961,
        hasActiveStationData: true,
      ),
    ];
  }

  Future<FieldSensorData> fetchFieldSensorData(String regionId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return FieldSensorData(
      sensorId: 'STATION-$regionId',
      district: 'Thanjavur',
      soilMoisturePct: 44.5,
      temperatureCelsius: 30.6,
      humidityPct: 82.0,
      nitrogenPpm: 156.0,
      phLevel: 6.8,
      waterLevel: 5.2,
      ambientLight: 32000.0,
      lastUpdated: DateTime.now(),
    );
  }
}
