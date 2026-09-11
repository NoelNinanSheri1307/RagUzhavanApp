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
        citedProvenance: 'TNAU Regional Extension Advisory 2025',
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
          citedProvenance: 'TNAU Agro-Meteorological Advisory Bulletin 2025',
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

    final qLower = question.toLowerCase();
    String answerText = '';
    String whatToDoText = '';
    String whatToDoTamilText = '';
    String whenText = '';
    String whenTamilText = '';
    String dosageText = '';
    String dosageTamilText = '';
    String reasoningText = '';
    String ruleId = 'RULE-TNAU-GENERAL-01';
    String provenance = 'TNAU District Extension Advisory 2025';

    if (qLower.contains('water') || qLower.contains('irrigat') || qLower.contains('flood') || qLower.contains('drain') || qLower.contains('நீ')) {
      answerText = isTamil
          ? 'தூர்கட்டும் பருவத்தில் வயலில் 2.5 முதல் 5.0 செ.மீ நீர் தேக்கி வைக்கவும். சீரான அறுவடைக்கு 10 நாட்களுக்கு முன் நீரை வடிக்கவும்.'
          : 'Maintain 2.5 cm to 5.0 cm standing water level during active tillering phase. Drain field water 10 days prior to harvest for uniform crop maturity.';
      whatToDoText = 'Regulate field drainage gates to maintain shallow standing water.';
      whatToDoTamilText = 'மட்டமான நீர் தேங்க வடிகால் மதகுகளை ஒழுங்குபடுத்தவும்.';
      whenText = 'Active tillering to panicle initiation stage.';
      whenTamilText = 'தூர்கட்டும் பருவம் முதல் கதிர் உருவாகும் நிலை வரை.';
      dosageText = '2.5 cm - 5.0 cm standing water.';
      dosageTamilText = '2.5 செ.மீ - 5.0 செ.மீ நீர் மட்டம்.';
      reasoningText = 'Evaluated field water saturation telemetry. TNAU Irrigation Bulletin recommends intermittent wetting and drying for Cauvery Delta clay soils.';
      ruleId = 'RULE-TNAU-IRRIGATION-02';
      provenance = 'TNAU Water Management & Irrigation Bulletin 2025';
    } else if (qLower.contains('sow') || qLower.contains('seed') || qLower.contains('variety') || qLower.contains('season') || qLower.contains('month') || qLower.contains('விதை')) {
      answerText = isTamil
          ? 'தஞ்சாவூர் மாவட்ட குறுவை பருவத்திற்கு ஜூன் 15 முதல் ஜூன் 30 வரை விதைப்பு உகந்தது. ADT-37, ADT-43 அல்லது TPS-5 ரகங்கள் ஏக்கருக்கு 25 கிலோ விதை தேவை.'
          : 'Optimal Kuruvai sowing window in Thanjavur district is June 15 to June 30. Recommended short duration paddy varieties: ADT-37, ADT-43, or TPS-5 with 25 kg/acre seed rate.';
      whatToDoText = 'Treat seeds with Pseudomonas fluorescens @ 10g/kg before sowing.';
      whatToDoTamilText = 'விதைப்பதற்கு முன் 10 கிராம்/கிலோ சூடோமோனாஸ் கலந்து விதை நேர்த்தி செய்யவும்.';
      whenText = 'June 15 - June 30 (Kuruvai Season).';
      whenTamilText = 'ஜூன் 15 - ஜூன் 30 (குறுவை பருவம்).';
      dosageText = '25 kg seeds / acre.';
      dosageTamilText = 'ஏக்கருக்கு 25 கிலோ விதைகள்.';
      reasoningText = 'Analyzed meteorological sowing window and monsoon onset data for Thanjavur Budalur block.';
      ruleId = 'RULE-TNAU-SOWING-01';
      provenance = 'TNAU Sowing Calendar & Seed Advisory Bulletin 2025';
    } else if (qLower.contains('mandi') || qLower.contains('price') || qLower.contains('rate') || qLower.contains('market') || qLower.contains('sell') || qLower.contains('விலை')) {
      answerText = isTamil
          ? 'இன்றைய தஞ்சாவூர் சந்தை நெல் விலை: கிரேடு A நெல் ₹2,320 / குவிண்டால். சாதாரண ரக நெல் ₹2,280 / குவிண்டால்.'
          : 'Current Thanjavur Mandi price for Grade A Paddy is ₹2,320 / quintal. Common variety paddy is trading at ₹2,280 / quintal with steady regional market demand.';
      whatToDoText = 'Sell harvested paddy at nearby Regulated Market Committee (RMC) procurement centers.';
      whatToDoTamilText = 'அறுவடை செய்த நெல்லை அருகிலுள்ள ஒழுங்குமுறை விற்பனைக்கூடங்களில் விற்கவும்.';
      whenText = 'Current market trading hours (09:00 AM - 05:00 PM).';
      whenTamilText = 'தற்போதைய சந்தை நேரங்கள் (காலை 09:00 - மாலை 05:00).';
      dosageText = '₹2,320 / quintal (Grade A Paddy).';
      dosageTamilText = '₹2,320 / குவிண்டால் (கிரேடு A நெல்).';
      reasoningText = 'Synthesized real-time Agmarknet mandi price feeds for Thanjavur district agricultural markets.';
      ruleId = 'RULE-AGMARKNET-MANDI-04';
      provenance = 'Agmarknet Mandi Price Feed & Tamil Nadu Agricultural Marketing Board';
    } else if (qLower.contains('fertiliz') || qLower.contains('npk') || qLower.contains('urea') || qLower.contains('nitrogen') || qLower.contains('nutrient') || qLower.contains('உரம்')) {
      answerText = isTamil
          ? 'நெற்பயிருக்கு NPK 120:50:50 கிலோ/ஹெக்டேர் இடவும். நைட்ரஜனை வேப்பங்குழை மூடப்பட்ட யூரியாவாக 4 தவணைகளாகப் பிரித்து இடவும்.'
          : 'Apply NPK 120:50:50 kg/ha for Paddy. Split Nitrogen into 4 equal doses (Basal, Active Tillering, Panicle Initiation, Flowering) using Neem-coated Urea to minimize leaching loss.';
      whatToDoText = 'Broadband split application of Neem-coated Urea with Zinc Sulphate.';
      whatToDoTamilText = 'ஜிங்க் சல்பேட் மற்றும் வேப்பங்குழை யூரியாவை தவணைகளாக இடவும்.';
      whenText = 'Basal, 21 DAT, 42 DAT, and flowering stages.';
      whenTamilText = 'அடி உரம், 21வது நாள், 42வது நாள் மற்றும் பூக்கும் பருவம்.';
      dosageText = '120 kg N, 50 kg P2O5, 50 kg K2O / hectare.';
      dosageTamilText = 'ஹெக்டேருக்கு 120 கி N, 50 கி P2O5, 50 கி K2O.';
      reasoningText = 'Retrieved soil fertility recommendations for Cauvery Delta clay soils from TNAU Agronomy Bulletin.';
      ruleId = 'RULE-TNAU-FERTILIZER-03';
      provenance = 'TNAU Soil Fertility & Fertilizer Recommendation Chart 2025';
    } else if (qLower.contains('blast') || qLower.contains('disease') || qLower.contains('fungicid') || qLower.contains('pest') || qLower.contains('insect') || qLower.contains('spray') || qLower.contains('leaf') || qLower.contains('நோய்')) {
      answerText = isTamil
          ? 'குலை நோய் தாக்குதலுக்கு 0.6 கிராம்/லிட்டர் ட்ரைசைக்ளசோல் 75% WP அல்லது 1.0 மி.லி/லிட்டர் அஸோக்ஸிஸ்ட்ரோபின் தெளிக்கவும்.'
          : 'For Leaf Blast control under high humidity (>85%), spray Tricyclazole 75% WP @ 0.6 g/L (120 g/acre) or Azoxystrobin 25% SC @ 1.0 mL/L during early disease onset.';
      whatToDoText = 'Foliar spray during cool morning or evening hours.';
      whatToDoTamilText = 'காலை அல்லது மாலை வேளையில் இலை தெளிப்பு செய்யவும்.';
      whenText = 'Immediate spray upon noticing initial spindle-shaped leaf blast spots.';
      whenTamilText = 'நோய் அறிகுறி தென்பட்டவுடன் தெளிக்கவும்.';
      dosageText = '0.6 g/L (Tricyclazole 75% WP) in 200 L water / acre.';
      dosageTamilText = '0.6 கிராம்/லிட்டர் (200 லிட்டர் தண்ணீர்/ஏக்கர்).';
      reasoningText = 'Evaluated high night humidity telemetry (>85%) and temperature records against TNAU Paddy Disease Protocols.';
      ruleId = 'RULE-TNAU-BLAST-01';
      provenance = 'TNAU Crop Protection Guide & ICAR Disease Management Bulletin 2025';
    } else {
      answerText = isTamil
          ? '"$question" பற்றிய பரிந்துரை: தஞ்சாவூர் மாவட்ட வேளாண் பல்கலைக்கழக வழிகாட்டலின்படி முறையான பராமரிப்பு மற்றும் வடிகால் வசதியை மேற்கொள்ளவும்.'
          : 'For "$question": Follow recommended TNAU extension protocols for Thanjavur district. Ensure balanced soil nutrition, timely weed management, and regular field scouting.';
      whatToDoText = 'Follow TNAU regional crop management package of practices.';
      whatToDoTamilText = 'வேளாண் பல்கலைக்கழக பயிர் மேலாண்மை நடைமுறைகளைப் பின்பற்றவும்.';
      whenText = 'Active cropping season.';
      whenTamilText = 'பயிர் காலம் முழுவதும்.';
      dosageText = 'As per TNAU recommended package of practices.';
      dosageTamilText = 'வேளாண் வழிகாட்டுதலின்படி.';
      reasoningText = 'Retrieved general regional crop management guidance for selected district and block.';
      ruleId = 'RULE-TNAU-GENERAL-01';
      provenance = 'TNAU District Extension Advisory & Agricultural Record 2025';
    }

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
          'title': provenance,
          'snippet': answerText,
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
      whatToDo: whatToDoText,
      whatToDoTamil: whatToDoTamilText,
      whenToApply: whenText,
      whenToApplyTamil: whenTamilText,
      howMuchAmount: dosageText,
      howMuchAmountTamil: dosageTamilText,
      whyReason: reasoningText,
      whyReasonTamil: reasoningText,
      groundingScore: 0.95,
      ruleId: ruleId,
      citedProvenance: provenance,
      language: isTamil ? 'ta' : 'en',
      isGrounded: true,
      evidenceSources: [
        EvidenceSource(
          id: 'SRC-01',
          title: provenance,
          publicationDate: '2025-05-10',
          authorOrInstitute: 'Tamil Nadu Agricultural University (TNAU)',
          documentType: 'Research Bulletin',
          excerpt: answerText,
          excerptTamil: answerText,
          confidenceScore: 0.95,
          datasetAgeDays: 14,
          urlOrRef: 'TNAU_Agricultural_Advisory_2025.pdf',
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
