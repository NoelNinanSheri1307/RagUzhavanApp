import 'dart:async';
import 'rag_repository.dart';
import '../models/rag_query.dart';
import '../models/rag_response.dart';
import '../models/evidence_source.dart';
import '../models/clarification_question.dart';
import '../models/region.dart';
import '../models/field_sensor_data.dart';
import '../models/low_bandwidth_message.dart';
import '../models/farmer.dart';

class MockRagRepository implements RagRepository {
  @override
  Future<RagResponse> askQuestion(RagQuery query) async {
    // Simulate brief network delay for editorial realism
    await Future.delayed(const Duration(milliseconds: 700));

    final text = query.questionText.toLowerCase();

    if (text.contains('no data') || text.contains('groundnut') || text.contains('dryland')) {
      return fetchPresetScenarioResponse('no_data', language: query.language);
    }
    if (text.contains('cotton') || text.contains('clarify') || text.contains('drainage')) {
      return fetchPresetScenarioResponse('clarification', language: query.language);
    }
    if (query.language == 'ta' || text.contains('தமிழ்') || text.contains('நெல்')) {
      return fetchPresetScenarioResponse('tamil_grounded', language: 'ta');
    }

    return fetchPresetScenarioResponse('grounded', language: query.language);
  }

  @override
  Future<RagResponse> fetchPresetScenarioResponse(String scenarioKey, {String language = 'en'}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    switch (scenarioKey) {
      case 'clarification':
        return RagResponse(
          id: 'RESP-MOCK-CLARIFY-02',
          queryId: 'QUERY-102',
          responseText:
              'To recommend precise bollworm management for your Cotton crop in Coimbatore, additional specific field conditions are needed before grounding advice in CICR protocols.',
          responseTextTamil:
              'கோயம்புத்தூர் பருத்திப் பயிரில் காய் புழு மேலாண்மைக்கு துல்லியமான பரிந்துரை வழங்க, தங்களின் நில வடிகால் மற்றும் பாசன விவரங்கள் தேவை.',
          language: language,
          isGrounded: false,
          status: ResponseStatus.clarificationNeeded,
          districtName: 'Coimbatore',
          cropName: 'Cotton (MCU-5)',
          averageDataAgeDays: 8,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          evidenceSources: const [],
          clarificationQuestions: const [
            ClarificationQuestion(
              id: 'CLARIFY-SOIL-01',
              questionText: 'What is the drainage condition of your black cotton soil field?',
              questionTextTamil: 'தங்களின் கரிசல் மண் நிலத்தின் வடிகால் அமைப்பு எவ்வாறு உள்ளது?',
              fieldName: 'soilDrainage',
              options: ['Well-drained raised beds', 'Moderate drainage', 'Waterlogged / Poor drainage'],
              optionsTamil: ['உயர்த்தப்பட்ட பாத்தி வடிகால்', 'மிதமான வடிகால்', 'தேங்கிய தண்ணீர் / குறைவான வடிகால்'],
            ),
            ClarificationQuestion(
              id: 'CLARIFY-IRR-02',
              questionText: 'Which irrigation method is currently deployed?',
              questionTextTamil: 'தற்போது பயன்படுத்தப்படும் பாசன முறை எது?',
              fieldName: 'irrigationMethod',
              options: ['Drip Fertigation', 'Ditch / Furrow Irrigation', 'Rainfed / Drip Supplement'],
              optionsTamil: ['சொட்டுநீர் பாசனம்', 'வாய்க்கால் பாசனம்', 'மானாவாரி பாசனம்'],
            ),
          ],
        );

      case 'no_data':
        return RagResponse(
          id: 'RESP-MOCK-NODATA-03',
          queryId: 'QUERY-103',
          responseText:
              'No grounded evidence was retrieved for Groundnut aphid pest dynamics in Ramanathapuram dryland zone for the current late-winter season. Existing station bulletins are older than 180 days.',
          responseTextTamil:
              'ராமநாதபுரம் மானாவாரி மண்டலத்தில் நடப்பு குளிர்காலத்திற்கான நிலக்கடலை அசுவினி பூச்சி பரவல் குறித்த சமீபத்திய ஆதாரப் பதிவுகள் கிடைக்கவில்லை. இருக்கும் தரவுகள் 180 நாட்களுக்கு முந்தையவை.',
          language: language,
          isGrounded: false,
          status: ResponseStatus.noData,
          districtName: 'Ramanathapuram',
          cropName: 'Groundnut (TMV-7)',
          averageDataAgeDays: 194,
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          evidenceSources: const [],
          clarificationQuestions: const [],
        );

      case 'tamil_grounded':
        return RagResponse(
          id: 'RESP-MOCK-TA-04',
          queryId: 'QUERY-104',
          responseText:
              'தஞ்சாவூர் குறுவை பருவத்தில் நெல் குலை நோயை (Pyricularia oryzae) கட்டுப்படுத்த, தமிழ்நாடு வேளாண்மைப் பல்கலைக்கழக (TNAU) வழிகாட்டுதலின்படி ட்ரைசைக்ளசோல் 75% WP (0.6 கிராம்/லிட்டர்) தெளிக்கவும். அதிக நைட்ரஜன் உரமிடுவதைத் தவிர்க்கவும்.',
          responseTextTamil:
              'தஞ்சாவூர் குறுவை பருவத்தில் நெல் குலை நோயை (Pyricularia oryzae) கட்டுப்படுத்த, தமிழ்நாடு வேளாண்மைப் பல்கலைக்கழக (TNAU) வழிகாட்டுதலின்படி ட்ரைசைக்ளசோல் 75% WP (0.6 கிராம்/லிட்டர்) தெளிக்கவும். அதிக நைட்ரஜன் உரமிடுவதைத் தவிர்க்கவும்.',
          language: 'ta',
          isGrounded: true,
          status: ResponseStatus.grounded,
          districtName: 'தஞ்சாவூர் (Thanjavur)',
          cropName: 'நெல் / குறுவை (Paddy)',
          averageDataAgeDays: 11,
          timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
          evidenceSources: const [
            EvidenceSource(
              id: 'EVID-TNAU-TA-01',
              title: 'தமிழ்நாடு வேளாண்மை பல்கலைக்கழக நெல் நோய் மேலாண்மை கையேடு 2025',
              publicationDate: '2025-06-15',
              authorOrInstitute: 'TNAU பயிர் பாதுகாப்பு மையம், கோயம்புத்தூர்',
              documentType: 'பல்கலைக்கழக ஆவணப் பதிவு',
              excerpt: 'குறுவை பருவத்தில் களிமண் நிலங்களில் நெல் குலை நோய் தாக்குதல் அதிகரிக்கும் போது ட்ரைசைக்ளசோல் தெளிப்பு மற்றும் பொட்டாஷ் உரம் பிரித்து அளித்தல் அவசியம்.',
              excerptTamil: 'குறுவை பருவத்தில் களிமண் நிலங்களில் நெல் குலை நோய் தாக்குதல் அதிகரிக்கும் போது ட்ரைசைக்ளசோல் தெளிப்பு மற்றும் பொட்டாஷ் உரம் பிரித்து அளித்தல் அவசியம்.',
              confidenceScore: 0.96,
              datasetAgeDays: 11,
              urlOrRef: 'TNAU-CPPS-BULLETIN-2025/RICE-BLAST',
              isVerified: true,
            ),
            EvidenceSource(
              id: 'EVID-TRRI-TA-02',
              title: 'ஆடுதுறை நெல் ஆராய்ச்சி நிலைய தட்பவெப்ப எச்சரிக்கை பதிவு',
              publicationDate: '2025-06-20',
              authorOrInstitute: 'TRRI ஆடுதுறை, தஞ்சாவூர்',
              documentType: 'மண்டல ஆராய்ச்சி மையம்',
              excerpt: 'காவேரி டெல்டா மண்டலத்தில் இரவு நேர ஈரப்பதம் 85% கடக்கும் போது குலை நோய் வித்திகள் வேகமுறுகின்றன.',
              excerptTamil: 'காவேரி டெல்டா மண்டலத்தில் இரவு நேர ஈரப்பதம் 85% கடக்கும் போது குலை நோய் வித்திகள் வேகமுறுகின்றன.',
              confidenceScore: 0.93,
              datasetAgeDays: 6,
              urlOrRef: 'TRRI-ADUTHURAI-ALERT-88',
              isVerified: true,
            ),
          ],
          clarificationQuestions: const [],
        );

      case 'grounded':
      default:
        return RagResponse(
          id: 'RESP-MOCK-EN-01',
          queryId: 'QUERY-101',
          responseText:
              'For Rice Blast (Pyricularia oryzae) management in Thanjavur clay soils during Kuruvai season: Apply Tricyclazole 75% WP @ 0.6 g/L water at initiation of blast lesions. Split Nitrogen application into 3 equal doses (basal, tillering, panicle initiation) and maintain 50 kg/ha Potash to reduce disease severity.',
          responseTextTamil:
              'தஞ்சாவூர் குறுவை பருவத்தில் நெல் குலை நோயைக் கட்டுப்படுத்த, ட்ரைசைக்ளசோல் 75% WP மருந்தை 0.6 கிராம்/லிட்டர் தண்ணீரில் கலந்து தெளிக்கவும். நைட்ரஜன் உரத்தை மூன்று சம பங்குகளாகப் பிரித்து இடவும்.',
          language: language,
          isGrounded: true,
          status: ResponseStatus.grounded,
          districtName: 'Thanjavur',
          cropName: 'Paddy / Rice (CR 1009 Sub 1)',
          averageDataAgeDays: 14,
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
          evidenceSources: const [
            EvidenceSource(
              id: 'EVID-TNAU-01',
              title: 'TNAU Crop Production Guide: Paddy Disease Management Protocols 2025',
              publicationDate: '2025-05-10',
              authorOrInstitute: 'Tamil Nadu Agricultural University (TNAU), Coimbatore',
              documentType: 'Extension Bulletin No. 408',
              excerpt: 'Tricyclazole 75 WP @ 0.6g/l shows 92.4% efficacy against Leaf Blast in Delta clay soils under high humidity (>85%). Avoid excess late Nitrogen topdressing.',
              excerptTamil: 'டெல்டா களிமண் நிலங்களில் ட்ரைசைக்ளசோல் 75 WP 92.4% நோய் கட்டுப்பாடு அளிக்கிறது.',
              confidenceScore: 0.95,
              datasetAgeDays: 14,
              urlOrRef: 'TNAU-CPG-2025/RICE-PATHOLOGY-L3',
              isVerified: true,
            ),
            EvidenceSource(
              id: 'EVID-ICAR-02',
              title: 'ICAR-NRRI Advisory on Kuruvai Season Blast Outbreaks in Cauvery Basin',
              publicationDate: '2025-05-28',
              authorOrInstitute: 'ICAR - National Rice Research Institute',
              documentType: 'Scientific Advisory Series',
              excerpt: 'In Cauvery delta alluvial soils, split potash fertilization combined with systemic triazole foliar spray mitigates blast yield penalty by up to 1.8 t/ha.',
              excerptTamil: 'காவேரி படுகை வண்டல் நிலங்களில் பொட்டாஷ் உரப்பிரிப்பு விளைச்சல் இழப்பைத் தடுக்கிறது.',
              confidenceScore: 0.92,
              datasetAgeDays: 12,
              urlOrRef: 'ICAR-NRRI-CAUVERY-DELTA-2025-04',
              isVerified: true,
            ),
            EvidenceSource(
              id: 'EVID-TRRI-03',
              title: 'TRRI Aduthurai Regional Station Field Trial Summary',
              publicationDate: '2025-06-02',
              authorOrInstitute: 'Tamil Nadu Rice Research Institute, Aduthurai',
              documentType: 'Station Field Trial Report',
              excerpt: 'Soil analysis of Thanjavur district blocks shows high clay retention requiring neem-coated urea applications alongside fungicide sprays.',
              excerptTamil: 'தஞ்சாவூர் வட்டார களிமண் பகுப்பாய்வு வேப்பம்பெண்ணெய் பூசிய யூரியாவை பரிந்துரைக்கிறது.',
              confidenceScore: 0.89,
              datasetAgeDays: 7,
              urlOrRef: 'TRRI-ADT-REP-2025-KURUVAI',
              isVerified: true,
            ),
          ],
          clarificationQuestions: const [],
        );
    }
  }

  @override
  Future<List<Region>> fetchSupportedRegions() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const [
      Region(
        id: 'thanjavur_01',
        districtName: 'Thanjavur',
        districtNameTamil: 'தஞ்சாவூர்',
        stateName: 'Tamil Nadu',
        agroClimaticZone: 'Cauvery Delta Zone',
        dominantSoilType: 'Alluvial & Deep Clay',
        primarySeason: 'Kuruvai & Samba',
        latitude: 10.7870,
        longitude: 79.1378,
      ),
      Region(
        id: 'coimbatore_02',
        districtName: 'Coimbatore',
        districtNameTamil: 'கோயம்புத்தூர்',
        stateName: 'Tamil Nadu',
        agroClimaticZone: 'Western Zone',
        dominantSoilType: 'Black Cotton Soil (Vertisols)',
        primarySeason: 'Kharif & Rabi',
        latitude: 11.0168,
        longitude: 76.9558,
      ),
      Region(
        id: 'ramanathapuram_03',
        districtName: 'Ramanathapuram',
        districtNameTamil: 'ராமநாதபுரம்',
        stateName: 'Tamil Nadu',
        agroClimaticZone: 'Coastal & Southern Dry Zone',
        dominantSoilType: 'Saline Coastal & Sandy Loam',
        primarySeason: 'Special Late Rabi / Dryland',
        latitude: 9.3639,
        longitude: 78.8395,
      ),
      Region(
        id: 'madurai_04',
        districtName: 'Madurai',
        districtNameTamil: 'மதுரை',
        stateName: 'Tamil Nadu',
        agroClimaticZone: 'Southern Zone',
        dominantSoilType: 'Red Loam & Clay Loam',
        primarySeason: 'Chithirai & Samba',
        latitude: 9.9252,
        longitude: 78.1198,
      ),
    ];
  }

  @override
  Future<FieldSensorData> fetchFieldSensorData(String regionId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final now = DateTime.now();

    if (regionId.contains('coimbatore')) {
      return FieldSensorData(
        sensorId: 'SENS-CBE-09',
        district: 'Coimbatore',
        soilMoisturePct: 28.4,
        temperatureCelsius: 33.8,
        humidityPct: 62.0,
        nitrogenPpm: 112.0,
        phLevel: 7.8,
        lastUpdated: now.subtract(const Duration(minutes: 10)),
      );
    }

    if (regionId.contains('ramanathapuram')) {
      return FieldSensorData(
        sensorId: 'SENS-RAM-12',
        district: 'Ramanathapuram',
        soilMoisturePct: 18.2,
        temperatureCelsius: 35.1,
        humidityPct: 54.0,
        nitrogenPpm: 88.0,
        phLevel: 8.2,
        lastUpdated: now.subtract(const Duration(minutes: 25)),
      );
    }

    return FieldSensorData(
      sensorId: 'SENS-THANJ-04',
      district: 'Thanjavur',
      soilMoisturePct: 44.5,
      temperatureCelsius: 30.6,
      humidityPct: 82.0,
      nitrogenPpm: 156.0,
      phLevel: 6.8,
      lastUpdated: now.subtract(const Duration(minutes: 5)),
    );
  }

  @override
  Future<LowBandwidthMessage> sendLowBandwidthQuery(RagQuery query) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return LowBandwidthMessage(
      id: 'SMS-MSG-${DateTime.now().millisecondsSinceEpoch}',
      queryText: query.questionText,
      payloadSizeKb: 1.14,
      compressedSummary:
          'TRICYCLAZOLE 75WP@0.6g/L for Rice Blast (Thanjavur/Kuruvai). Split N topdressing into 3 doses + 50kg K2O/ha. Ref: TNAU-CPG2025',
      compressedSummaryTamil:
          'குறுவை நெல் குலை நோய்: ட்ரைசைக்ளசோல் 75WP (0.6g/L) தெளிக்கவும். N உரத்தை 3 பங்காக இடவும். Ref: TNAU2025',
      queueStatus: 'delivered',
      retryCount: 0,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<List<Farmer>> fetchFarmersList() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const [
      Farmer(
        id: 'FARM-001',
        name: 'M. Palanisamy',
        phone: '+91 98421 88321',
        district: 'Thanjavur',
        state: 'Tamil Nadu',
        preferredLanguage: 'ta',
        crops: ['Paddy', 'Blackgram'],
        landSizeAcres: 4.5,
        agroZone: 'Cauvery Delta Zone',
      ),
      Farmer(
        id: 'FARM-002',
        name: 'K. Arumugam',
        phone: '+91 97892 41105',
        district: 'Coimbatore',
        state: 'Tamil Nadu',
        preferredLanguage: 'en',
        crops: ['Cotton', 'Maize'],
        landSizeAcres: 8.0,
        agroZone: 'Western Zone',
      ),
      Farmer(
        id: 'FARM-003',
        name: 'S. Ramanathan',
        phone: '+91 94431 09277',
        district: 'Ramanathapuram',
        state: 'Tamil Nadu',
        preferredLanguage: 'ta',
        crops: ['Groundnut', 'Chilli'],
        landSizeAcres: 3.2,
        agroZone: 'Coastal Dry Zone',
      ),
    ];
  }
}
