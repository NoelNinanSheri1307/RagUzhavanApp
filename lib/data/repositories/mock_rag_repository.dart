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

    if (qLower.contains('kuruvai') || (qLower.contains('sow') && qLower.contains('thanjavur')) || (qLower.contains('seed rate') && (qLower.contains('thanjavur') || qLower.contains('paddy')))) {
      answerText = isTamil
          ? 'தஞ்சாவூர் மாவட்ட குறுவை பருவத்திற்கு ஜூன் 15 முதல் ஜூன் 30 வரை விதைப்பு உகந்தது. ADT-37, ADT-43 அல்லது TPS-5 ரகங்கள் ஏக்கருக்கு 25 கிலோ விதை தேவை. சூடோமோனாஸ் 10 கிராம்/கிலோ விதை நேர்த்தி செய்யவும்.'
          : 'Optimal Kuruvai sowing window in Thanjavur district is June 15 to June 30. Recommended short duration paddy varieties: ADT-37, ADT-43, or TPS-5 with 25 kg/acre seed rate. Treat seeds with Pseudomonas fluorescens @ 10g/kg.';
      whatToDoText = 'Seed treatment with Pseudomonas fluorescens @ 10g/kg before nursery sowing.';
      whatToDoTamilText = 'விதைப்பதற்கு முன் 10 கிராம்/கிலோ சூடோமோனாஸ் கலந்து விதை நேர்த்தி செய்யவும்.';
      whenText = 'June 15 - June 30 (Kuruvai Season).';
      whenTamilText = 'ஜூன் 15 - ஜூன் 30 (குறுவை பருவம்).';
      dosageText = '25 kg seeds / acre.';
      dosageTamilText = 'ஏக்கருக்கு 25 கிலோ விதைகள்.';
      reasoningText = 'Analyzed meteorological sowing window and monsoon onset data for Thanjavur district.';
      ruleId = 'RULE-TN-KURUVAI-SOWING';
      provenance = 'TNAU Sowing Calendar & Seed Advisory Bulletin 2025 (Thanjavur)';
    } else if (qLower.contains('blast') || qLower.contains('fungicid') || (qLower.contains('leaf') && qLower.contains('spot'))) {
      answerText = isTamil
          ? 'குலை நோய் (Leaf Blast) தாக்குதலுக்கு 0.6 கிராம்/லிட்டர் ட்ரைசைக்ளசோல் 75% WP (ஏக்கருக்கு 120 கிராம்) அல்லது 1.0 மி.லி/லிட்டர் அஸோக்ஸிஸ்ட்ரோபின் தெளிக்கவும். காலை ஈரப்பதம் அதிகமுள்ள வேளையில் நைட்ட்ரஜன் உரம் இடுவதைத் தவிர்க்கவும்.'
          : 'For Leaf Blast control in Thanjavur under high humidity (>85%), spray Tricyclazole 75% WP @ 0.6 g/L (120 g/acre) or Azoxystrobin 25% SC @ 1.0 mL/L during early disease onset.';
      whatToDoText = 'Foliar spray during cool morning or evening hours.';
      whatToDoTamilText = 'காலை அல்லது மாலை வேளையில் இலை தெளிப்பு செய்யவும்.';
      whenText = 'Immediate spray upon noticing initial spindle-shaped leaf blast spots.';
      whenTamilText = 'நோய் அறிகுறி தென்பட்டவுடன் தெளிக்கவும்.';
      dosageText = '0.6 g/L (Tricyclazole 75% WP) in 200 L water / acre.';
      dosageTamilText = '0.6 கிராம்/லிட்டர் (200 லிட்டர் தண்ணீர்/ஏக்கர்).';
      reasoningText = 'Evaluated high night humidity telemetry (>85%) and temperature records against TNAU Paddy Disease Protocols for Thanjavur Delta.';
      ruleId = 'RULE-TN-LEAF-BLAST';
      provenance = 'TNAU Crop Protection Guide & ICAR Disease Management Bulletin 2025';
    } else if (qLower.contains('fertiliz') || qLower.contains('npk') || qLower.contains('urea') || qLower.contains('nitrogen') || qLower.contains('உரம்')) {
      answerText = isTamil
          ? 'தஞ்சாவூர் களிமண் நிலத்திற்கு NPK 120:50:50 கிலோ/ஹெக்டேர் இடவும். நைட்ரஜனை வேப்பங்குழை மூடப்பட்ட யூரியாவாக 4 தவணைகளாகவும், அடி உரத்துடன் 25 கிலோ ஜிங்க் சல்பேட் இடவும்.'
          : 'Apply NPK 120:50:50 kg/ha for Thanjavur paddy clay soil. Split Nitrogen into 4 equal doses (Basal, Active Tillering, Panicle Initiation, Flowering) using Neem-coated Urea along with 25 kg/ha Zinc Sulphate.';
      whatToDoText = 'Broadband split application of Neem-coated Urea with Zinc Sulphate.';
      whatToDoTamilText = 'ஜிங்க் சல்பேட் மற்றும் வேப்பங்குழை யூரியாவை தவணைகளாக இடவும்.';
      whenText = 'Basal, 21 DAT, 42 DAT, and flowering stages.';
      whenTamilText = 'அடி உரம், 21வது நாள், 42வது நாள் மற்றும் பூக்கும் பருவம்.';
      dosageText = '120 kg N, 50 kg P2O5, 50 kg K2O / hectare.';
      dosageTamilText = 'ஹெக்டேருக்கு 120 கி N, 50 கி P2O5, 50 கி K2O.';
      reasoningText = 'Retrieved soil fertility recommendations for Cauvery Delta clay soils from TNAU Agronomy Bulletin.';
      ruleId = 'RULE-TN-NPK-FERTILIZER';
      provenance = 'TNAU Soil Fertility & Fertilizer Recommendation Chart 2025';
    } else if (qLower.contains('water') || qLower.contains('irrigat') || qLower.contains('drain') || qLower.contains('awd') || qLower.contains('நீ')) {
      answerText = isTamil
          ? 'தூர்கட்டும் பருவத்தில் 2.5 முதல் 5.0 செ.மீ நீர் தேக்கி வைக்கவும். Alternate Wetting & Drying (AWD) முறையைப் பின்பற்றி, அறுவடைக்கு 10 நாட்களுக்கு முன் நீரை முழுமையாக வடிக்கவும்.'
          : 'Maintain 2.5 cm to 5.0 cm shallow standing water during active tillering phase. Practice Alternate Wetting and Drying (AWD) in Thanjavur clay soil, and drain field water completely 10 days prior to harvest.';
      whatToDoText = 'Regulate field drainage gates to maintain shallow standing water.';
      whatToDoTamilText = 'மட்டமான நீர் தேங்க வடிகால் மதகுகளை ஒழுங்குபடுத்தவும்.';
      whenText = 'Active tillering to panicle initiation stage.';
      whenTamilText = 'தூர்கட்டும் பருவம் முதல் கதிர் உருவாகும் நிலை வரை.';
      dosageText = '2.5 cm - 5.0 cm standing water.';
      dosageTamilText = '2.5 செ.மீ - 5.0 செ.மீ நீர் மட்டம்.';
      reasoningText = 'Evaluated field water saturation telemetry. TNAU Water Management Bulletin recommends intermittent wetting and drying for Cauvery Delta soils.';
      ruleId = 'RULE-TN-WATER-AWD';
      provenance = 'TNAU Water Management & Irrigation Bulletin 2025';
    } else if (qLower.contains('mandi') || qLower.contains('price') || qLower.contains('rate') || qLower.contains('market') || qLower.contains('sell') || qLower.contains('விலை')) {
      answerText = isTamil
          ? 'இன்றைய தஞ்சாவூர் சந்தை நெல் கொள்முதல் விலை: கிரேடு A நெல் ₹2,320 / குவிண்டால். சாதாரண ரக நெல் ₹2,280 / குவிண்டால்.'
          : 'Current Thanjavur Regulated Market Committee (RMC) price for Grade A Paddy is ₹2,320 / quintal. Common variety paddy is trading at ₹2,280 / quintal.';
      whatToDoText = 'Sell harvested paddy at nearby Regulated Market Committee (RMC) procurement centers.';
      whatToDoTamilText = 'அறுவடை செய்த நெல்லை அருகிலுள்ள ஒழுங்குமுறை விற்பனைக்கூடங்களில் விற்கவும்.';
      whenText = 'Current market trading hours (09:00 AM - 05:00 PM).';
      whenTamilText = 'தற்போதைய சந்தை நேரங்கள் (காலை 09:00 - மாலை 05:00).';
      dosageText = '₹2,320 / quintal (Grade A Paddy).';
      dosageTamilText = '₹2,320 / குவிண்டால் (கிரேடு A நெல்).';
      reasoningText = 'Synthesized real-time Agmarknet mandi price feeds for Thanjavur district agricultural markets.';
      ruleId = 'RULE-TN-MANDI-PRICES';
      provenance = 'Agmarknet Mandi Price Feed & Tamil Nadu Agricultural Marketing Board';
    } else if (qLower.contains('stem borer') || qLower.contains('dead heart') || qLower.contains('குருத்து')) {
      answerText = isTamil
          ? 'தஞ்சாவூரில் குருத்துப் பூச்சி தாக்குதலுக்கு ஏக்கருக்கு 5 இனக்கவர்ச்சி பொறிகளை அமைக்கவும். நட்ட 15-20 நாட்களில் குளோரான்ட்ரானிலிப்ரோல் 0.4% GR @ 4 கிலோ/ஏக்கர் அல்லது கார்டாப் ஹைட்ரோகுளோரைடு 4G @ 10 கிலோ/ஏக்கர் இடவும்.'
          : 'Install 5 pheromone traps per acre. Apply Chlorantraniliprole 0.4% GR @ 4 kg/acre or Cartap Hydrochloride 4G @ 10 kg/acre at 15–20 days after transplanting when dead hearts exceed 10%.';
      whatToDoText = 'Apply granular insecticide into standing shallow water.';
      whatToDoTamilText = 'மட்டமான நீரில் குருணை மருந்தை இடவும்.';
      whenText = '15-20 Days After Transplanting (DAT).';
      whenTamilText = 'நட்ட 15-20 நாட்களில்.';
      dosageText = '4 kg/acre Chlorantraniliprole 0.4% GR.';
      dosageTamilText = 'ஏக்கருக்கு 4 கிலோ குளோரான்ட்ரானிலிப்ரோல்.';
      reasoningText = 'TNAU Pest Surveillance Report for Thanjavur Delta Zone.';
      ruleId = 'RULE-TN-STEM-BORER';
      provenance = 'TNAU Crop Protection Guide 2025';
    } else if (qLower.contains('blight') || qLower.contains('blb') || qLower.contains('bacterial') || qLower.contains('பாக்டீரியா')) {
      answerText = isTamil
          ? 'பாக்டீரியல் இலைக்கருகல் நோய்க்கு ஸ்ட்ரெப்டோமைசின் + டெட்ராசைக்ளின் 6 கிராம் + காப்பர் ஆக்சிகுளோரைடு 300 கிராம் ஏக்கருக்கு 200 லிட்டர் தண்ணீரில் கலந்து தெளிக்கவும். நைட்ட்ரஜன் உரம் இடுவதை நிறுத்தவும்.'
          : 'For Bacterial Leaf Blight (BLB) in Thanjavur, spray Streptocycline @ 6g + Copper Oxychloride 50% WP @ 300g per acre in 200 L water. Suspend top-dressing Nitrogen immediately.';
      whatToDoText = 'Foliar spray and field water drainage.';
      whatToDoTamilText = 'இலை தெளிப்பு செய்து வயல் நீரை வடிக்கவும்.';
      whenText = 'Early onset of yellow-orange bacterial leaf scorch symptoms.';
      whenTamilText = 'இலை கருகல் அறிகுறிகள் தென்படும் போது.';
      dosageText = '6g Streptocycline + 300g Copper Oxychloride / acre.';
      dosageTamilText = '6 கிராம் ஸ்ட்ரெப்டோமைசின் + 300 கிராம் காப்பர் ஆக்சிகுளோரைடு.';
      reasoningText = 'Pathological assessment for bacterial leaf scorch in flooded clay basins.';
      ruleId = 'RULE-TN-BACTERIAL-BLIGHT';
      provenance = 'TNAU Plant Pathology Advisory 2025';
    } else if (qLower.contains('samba') || (qLower.contains('variety') && qLower.contains('thanjavur'))) {
      answerText = isTamil
          ? 'தஞ்சாவூர் சம்பா பருவத்திற்கு (ஆகஸ்ட்-ஜனவரி) பரிந்துரைக்கப்படும் நெல் ரகங்கள்: CR 1009 Sub-1 (வெள்ளம் தாங்கும்), ADT 49, BPT 5204 மற்றும் TNAU நெல் CO 52. ஏக்கருக்கு 15-20 கிலோ விதை தேவை.'
          : 'Recommended Samba season (Aug-Jan) paddy varieties for Thanjavur are CR 1009 Sub-1 (submergence tolerant), ADT 49, BPT 5204, and TNAU Rice CO 52 with 15-20 kg/acre seed rate.';
      whatToDoText = 'Direct seeding or SRI nursery preparation for Samba crop.';
      whatToDoTamilText = 'சம்பா நெல் சாகுபடிக்கு நாற்றங்கால் தயார் செய்யவும்.';
      whenText = 'August 1 - September 15 (Samba Sowing Window).';
      whenTamilText = 'ஆகஸ்ட் 1 - செப்டம்பர் 15 (சம்பா விதைப்பு பருவம்).';
      dosageText = '15-20 kg seeds / acre.';
      dosageTamilText = 'ஏக்கருக்கு 15-20 கிலோ விதைகள்.';
      reasoningText = 'TNAU Varietal Release Advisory for Cauvery Delta Zone.';
      ruleId = 'RULE-TN-SAMBA-VARIETIES';
      provenance = 'TNAU Rice Varietal Recommendation 2025';
    } else if (qLower.contains('bph') || qLower.contains('planthopper') || qLower.contains('hopper burn') || qLower.contains('புகாண்')) {
      answerText = isTamil
          ? 'புகையான் (BPH) தாக்குதலைத் தவிர்க்க அடர் நடுவதைத் தவிர்க்கவும். 3 மீட்டருக்கு ஒரு இடைவெளி (அடிப் பாதை) அமைக்கவும். ட்ரைஃப்ளூமிஸோபைரிம் 10% SC @ 94 மி.லி/ஏக்கர் பயிரின் அடி பாகத்தில் படுமாறு தெளிக்கவும்.'
          : 'To prevent Brown Planthopper (BPH) in humid Thanjavur conditions, form 30cm alleyways every 3m for aeration. Spray Triflumezopyrim 10% SC @ 94 mL/acre directly onto plant bases.';
      whatToDoText = 'Base directed chemical spray after establishing alleyways.';
      whatToDoTamilText = 'பயிரின் அடிப்பகுதியில் தெளிப்பு செய்யவும்.';
      whenText = 'When hopper count exceeds 10 per hill at water level.';
      whenTamilText = 'தூருக்கு 10 பூச்சிகளுக்கு மேல் இருந்தால் தெளிக்கவும்.';
      dosageText = '94 mL / acre Triflumezopyrim 10% SC.';
      dosageTamilText = 'ஏக்கருக்கு 94 மி.லி ட்ரைஃப்ளூமிஸோபைரிம்.';
      reasoningText = 'Entomological microclimate evaluation for high humidity Delta fields.';
      ruleId = 'RULE-TN-BPH-CONTROL';
      provenance = 'ICAR-NRRI & TNAU Entomology Guide 2025';
    } else if (qLower.contains('zinc') || qLower.contains('khaira') || qLower.contains('deficiency') || qLower.contains('துத்தநாக')) {
      answerText = isTamil
          ? 'தஞ்சாவூர் களிமண்ணில் துத்தநாகக் குறைபாட்டைச் சரிசெய்ய அடியில் 25 கிலோ ஜிங்க் சல்பேட் இடவும். அறிகுறிகள் தென்பட்டால் 0.5% ஜிங்க் சல்பேட் + 1% யூரியாக் கரைசலை இலைகளில் தெளிக்கவும்.'
          : 'To correct Zinc deficiency (Khaira disease) in Thanjavur, apply 25 kg/ha Zinc Sulphate as basal. If symptoms appear post-transplanting, foliar spray 0.5% Zinc Sulphate + 1% Urea solution twice.';
      whatToDoText = 'Basal soil application or foliar spray of Zinc Sulphate solution.';
      whatToDoTamilText = 'அடி உரமாக ஜிங்க் சல்பேட் இடவும் அல்லது இலை தெளிப்பு செய்யவும்.';
      whenText = 'Basal stage or 15-20 days after transplanting.';
      whenTamilText = 'அடி உரமாக அல்லது நட்ட 15-20 நாட்களில்.';
      dosageText = '25 kg/ha Zinc Sulphate basal or 0.5% foliar spray.';
      dosageTamilText = 'ஹெக்டேருக்கு 25 கிலோ ஜிங்க் சல்பேட்.';
      reasoningText = 'Micronutrient status survey in Cauvery Delta clay soils.';
      ruleId = 'RULE-TN-ZINC-DEFICIENCY';
      provenance = 'TNAU Soil Fertility Department 2025';
    } else if (qLower.contains('weed') || qLower.contains('herbucid') || qLower.contains('herbicide') || qLower.contains('களை')) {
      answerText = isTamil
          ? 'நேரடி நெல் விதைப்பில் களை நிர்வாகத்திற்கு விதைத்த 3-5 நாட்களில் பைரசோசல்பியூரான் எத்தில் 10% WP @ 80 கிராம்/ஏக்கர் அல்லது பிரெட்டிலாக்ளோர் + சேஃப்னர் @ 500 மி.லி/ஏக்கர் தெளிக்கவும்.'
          : 'For weed management in Thanjavur wet direct seeded rice, apply Pyrazosulfuron Ethyl 10% WP @ 80 g/acre at 3-5 days after sowing (DAS) maintaining thin field moisture.';
      whatToDoText = 'Pre-emergence herbicide spray on standing moist soil.';
      whatToDoTamilText = 'ஈரமான நிலத்தில் முளைக்கும் முன் களைக்கொல்லி தெளிக்கவும்.';
      whenText = '3 to 5 Days After Sowing (DAS).';
      whenTamilText = 'விதைத்த 3 முதல் 5 நாட்களில்.';
      dosageText = '80 g / acre Pyrazosulfuron Ethyl 10% WP.';
      dosageTamilText = 'ஏக்கருக்கு 80 கிராம் பைரசோசல்பியூரான் எத்தில்.';
      reasoningText = 'TNAU Agronomy Weed Science Unit Advisory.';
      ruleId = 'RULE-TN-WEED-CONTROL';
      provenance = 'TNAU Weed Management Guidelines 2025';
    } else if (qLower.contains('bio-fertiliz') || qLower.contains('azolla') || qLower.contains('pseudomonas') || qLower.contains('உயிர் உரம்')) {
      answerText = isTamil
          ? 'தஞ்சாவூர் நிலங்களுக்கு அசோஸ்பைரில்லம் 2 கிலோ மற்றும் பாஸ்போபேக்டீரியா 2 கிலோவை 50 கிலோ தொழு உரத்துடன் கலந்து அடி உரமாக இடவும். மேலும் அஸோல்லா 200 கிலோ/ஏக்கர் இட்டு வளர்க்கலாம்.'
          : 'Apply Azospirillum @ 2 kg/acre and Phosphobacteria (PSB) @ 2 kg/acre mixed with 50 kg well-decomposed FYM as basal in Thanjavur paddy fields. Inoculate Azolla @ 200 kg/acre as green manure.';
      whatToDoText = 'Soil application of bio-fertilizer carrier mixture.';
      whatToDoTamilText = 'தொழு உரத்துடன் கலந்து மண்ணில் இடவும்.';
      whenText = 'Basal field preparation stage.';
      whenTamilText = 'நிலம் ஆயத்தமாக்கும் போது.';
      dosageText = '2 kg Azospirillum + 2 kg PSB / acre.';
      dosageTamilText = 'ஏக்கருக்கு 2 கிலோ அசோஸ்பைரில்லம் + 2 கிலோ பிஎஸ்பி.';
      reasoningText = 'Soil Biological Fertility Enhancement Project (TNAU).';
      ruleId = 'RULE-TN-BIOFERTILIZERS';
      provenance = 'TNAU Bio-fertilizer Production Unit 2025';
    } else if (qLower.contains('salin') || qLower.contains('sodic') || qLower.contains('gypsum') || qLower.contains('உவர்')) {
      answerText = isTamil
          ? 'தஞ்சாவூர் உவர் நிலங்களைச் சீரமைக்க ஏக்கருக்கு 500 கிலோ ஜிப்சம் இட்டு நன்னீரால் வடிக்கவும். உவர் தாங்கும் TRY-1, TRY-3 அல்லது CO 43 Sub-1 நெல் ரகங்களைச் சாகுபடி செய்யவும்.'
          : 'In low-lying sodic/saline areas of Thanjavur, incorporate Gypsum @ 500 kg/acre followed by fresh water leaching. Cultivate salt-tolerant rice varieties TRY-1, TRY-3, or CO 43 Sub-1.';
      whatToDoText = 'Incorporate gypsum during summer plowing and leach field with canal water.';
      whatToDoTamilText = 'ஜிப்சம் இட்டு உழவு செய்து நன்னீரால் வடிக்கவும்.';
      whenText = 'Summer land preparation before Kuruvai / Samba.';
      whenTamilText = 'கோடை உழவின் போது.';
      dosageText = '500 kg / acre Agricultural Gypsum.';
      dosageTamilText = 'ஏக்கருக்கு 500 கிலோ ஜிப்சம்.';
      reasoningText = 'Soil Salinity Reclamation Protocol for Cauvery Delta.';
      ruleId = 'RULE-TN-SOIL-SALINITY';
      provenance = 'Anbil Dharmalingam Agricultural College & Research Institute 2025';
    } else if (qLower.contains('discolor') || qLower.contains('grain') || qLower.contains('தானிய')) {
      answerText = isTamil
          ? 'தானிய நிறமாற்ற நோயதைத் தடுக்க 50% பூக்கும் தருணத்தில் கிரெசாக்சிம் மெத்தில் 44.3% SC @ 1.0 மி.லி/லிட்டர் அல்லது கார்பண்டாசிம்+மேன்கோசெப் @ 2 கிராம்/லிட்டர் தெளிக்கவும்.'
          : 'To prevent paddy grain discoloration during monsoon harvest in Thanjavur, spray Kresoxim-methyl 44.3% SC @ 1.0 mL/L or Carbendazim + Mancozeb @ 2g/L at 50% flowering.';
      whatToDoText = 'Prophylactic foliar fungicidal spray at flowering stage.';
      whatToDoTamilText = 'பூக்கும் பருவத்தில் பூஞ்சானக்கொல்லி தெளிக்கவும்.';
      whenText = '50% flowering to grain filling stage.';
      whenTamilText = '50% பூக்கும் தருணத்தில்.';
      dosageText = '1.0 mL / L Kresoxim-methyl 44.3% SC.';
      dosageTamilText = '1.0 மி.லி/லிட்டர் கிரெசாக்சிம் மெத்தில்.';
      reasoningText = 'Monsoon Post-Harvest Quality Control Bulletin.';
      ruleId = 'RULE-TN-GRAIN-DISCOLORATION';
      provenance = 'TNAU Post Harvest Technology Centre 2025';
    } else if (qLower.contains('thaladi') || qLower.contains('second crop') || qLower.contains('தாளடி')) {
      answerText = isTamil
          ? 'தஞ்சாவூர் தாளடி பருவத்திற்கு (அக்டோபர்-பிப்ரவரி) உகந்த இடைக்கால நெல் ரகங்கள்: ADT 39, ADT 53 மற்றும் CO 51. அக்டோபர் 25க்கு முன் 18-20 நாள் நாற்றுகளை நடவு செய்யவும்.'
          : 'Optimal medium duration paddy varieties for Thaladi (Oct-Feb) in Thanjavur are ADT 39, ADT 53, and CO 51. Transplant 18–20 day old seedlings before October 25 to avoid late monsoon cold stress.';
      whatToDoText = 'Seedling transplantation of 18-20 day old nursery.';
      whatToDoTamilText = '18-20 நாள் நாற்றுகளை நடவு செய்யவும்.';
      whenText = 'October 1 - October 25 (Thaladi Transplanting Window).';
      whenTamilText = 'அக்டோபர் 1 - அக்டோபர் 25 (தாளடி நடவு பருவம்).';
      dosageText = 'Medium duration variety seedlings (25-30 hills/m2).';
      dosageTamilText = 'சதுர மீட்டருக்கு 25-30 தூர்கள்.';
      reasoningText = 'Thaladi Cropping Pattern Advisory for Cauvery Delta Zone.';
      ruleId = 'RULE-TN-THALADI-CROP';
      provenance = 'TNAU Agricultural Advisory Bulletin 2025';
    } else if (qLower.contains('organic') || qLower.contains('neem') || qLower.contains('panchagavya') || qLower.contains('இயற்கை')) {
      answerText = isTamil
          ? 'இயற்கைப் பூச்சிக் கட்டுப்பாட்டிற்கு 5% வேப்பங்கொட்டை சாறு (NSKE) @ 10 கிலோ/ஏக்கர் அல்லது 3% பஞ்சகவ்யா கரைசல் தெளிக்கவும். குருத்துப் பூச்சிக்கு டிரைகோகிரம்மா ஒட்டுண்ணி அட்டை 2 மி.லி/ஏக்கர் கட்டவும்.'
          : 'For organic pest control in Thanjavur paddy, spray 5% Neem Seed Kernel Extract (NSKE) @ 10 kg/acre or 3% Panchagavya solution (30 mL/L). Release Trichogramma japonicum parasitoids @ 2 mL/acre.';
      whatToDoText = 'Foliar spray of botanical extractions and parasitoid egg card release.';
      whatToDoTamilText = 'வேப்பங்கொட்டை சாறு தெளிக்கவும் மற்றும் ஒட்டுண்ணி அட்டை கட்டவும்.';
      whenText = 'Every 14 days interval during crop growth.';
      whenTamilText = 'வளர்ச்சி பருவத்தில் 14 நாட்களுக்கு ஒருமுறை.';
      dosageText = '10 kg NSKE / acre in 200 L water.';
      dosageTamilText = 'ஏக்கருக்கு 10 கிலோ வேப்பங்கொட்டை சாறு.';
      reasoningText = 'Organic Rice Production Protocol for Cauvery Delta.';
      ruleId = 'RULE-TN-ORGANIC-PEST';
      provenance = 'TNAU Department of Organic Farming 2025';
    } else {
      final noDataText = isTamil
          ? 'உங்கள் இருப்பிடத்திற்கான தரவு எதுவும் இல்லை.'
          : 'No current data for your location / block.';
      answerText = noDataText;
      whatToDoText = 'No data available for submitted location / query.';
      whatToDoTamilText = 'சமர்ப்பிக்கப்பட்ட கேள்விக்குத் தரவு எதுவும் இல்லை.';
      whenText = 'N/A';
      whenTamilText = 'பொருந்தாது';
      dosageText = 'N/A';
      dosageTamilText = 'பொருந்தாது';
      reasoningText = 'No matching vector document or advisory rule found for the query.';
      ruleId = 'RULE-NO-DATA';
      provenance = 'Regional Agricultural Extension Database';
    }

    final isNoData = ruleId == 'RULE-NO-DATA';

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
      sources: isNoData
          ? const []
          : [
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
      groundingScore: isNoData ? 0.0 : 0.95,
      ruleId: ruleId,
      citedProvenance: provenance,
      language: isTamil ? 'ta' : 'en',
      isGrounded: !isNoData,
      evidenceSources: isNoData
          ? const []
          : [
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
      status: isNoData ? ResponseStatus.noData : ResponseStatus.grounded,
      districtName: 'Active Region',
      blockName: 'Active Block',
      cropName: 'General',
      growthStage: isNoData ? 'N/A' : 'Active Season',
      season: isNoData ? 'N/A' : 'Current',
      averageDataAgeDays: isNoData ? 180 : 14,
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
