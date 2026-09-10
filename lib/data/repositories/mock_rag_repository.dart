import 'dart:async';
import 'rag_repository.dart';
import '../models/rag_query.dart';
import '../models/rag_response.dart';
import '../models/evidence_source.dart';
import '../models/clarification_question.dart';
import '../models/numeric_recommendation.dart';
import '../models/region.dart';
import '../models/field_sensor_data.dart';
import '../models/low_bandwidth_message.dart';
import '../models/farmer.dart';

class MockRagRepository implements RagRepository {
  @override
  Future<RagResponse> askQuestion(RagQuery query) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final text = query.questionText.toLowerCase();

    if (text.contains('disconnected') || text.contains('backend disconnected')) {
      return fetchPresetScenarioResponse('disconnected', language: query.language);
    }

    if (!text.contains('thanjavur') &&
        !text.contains('coimbatore') &&
        !text.contains('ramanathapuram') &&
        !text.contains('madurai') &&
        !text.contains('budalur') &&
        !text.contains('kadaladi') &&
        !text.contains('தஞ்சாவூர்') &&
        query.regionId.isEmpty) {
      return fetchPresetScenarioResponse('clarification_location', language: query.language);
    }

    if (text.contains('kadaladi') || text.contains('no data') || text.contains('groundnut')) {
      return fetchPresetScenarioResponse('no_data', language: query.language);
    }

    if (text.contains('cotton') || text.contains('bollworm') || text.contains('clarify')) {
      return fetchPresetScenarioResponse('clarification_cotton', language: query.language);
    }

    if (query.language == 'ta' || text.contains('தமிழ்') || text.contains('நெல்')) {
      return fetchPresetScenarioResponse('tamil_grounded', language: 'ta');
    }

    // Default for unhandled custom queries when backend is disconnected
    return fetchPresetScenarioResponse('disconnected', language: query.language);
  }

  @override
  Future<RagResponse> fetchPresetScenarioResponse(String scenarioKey, {String language = 'en'}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    switch (scenarioKey) {
      case 'disconnected':
        return RagResponse(
          id: 'RESP-DISCONNECTED-00',
          queryId: 'QUERY-DISCONNECTED',
          responseText:
              'Your question was received, but the RagUzhavan backend is not connected yet. Connect API_BASE_URL in Settings to receive live grounded regional advisories.',
          responseTextTamil:
              'உங்கள் கேள்வி பெறப்பட்டது, ஆனால் ரக் உழவன் பின்தள இணைப்பு இன்னும் இணைக்கப்படவில்லை. நேரலை வேளாண் தகவல்களைப் பெற அமைப்புகளில் API_BASE_URL ஐ இணைக்கவும்.',
          recommendationSummary: 'BACKEND NOT CONNECTED (AUTONOMOUS FRONTEND MODE)',
          recommendationSummaryTamil: 'பின்தள இணைப்பு இல்லை (சுயாதீன முன்முனை பயன்முறை)',
          whatToDo: 'Set API_BASE_URL to your Railway backend deployment URL in Settings.',
          whatToDoTamil: 'அமைப்புகளில் உங்களின் Railway பின்தள முகவரியை வழங்கவும்.',
          whenToApply: 'N/A — Autonomous Mode',
          whenToApplyTamil: 'பொருந்தாது',
          howMuchAmount: 'N/A',
          howMuchAmountTamil: 'பொருந்தாது',
          whyReason: 'The frontend explicitly refrains from presenting mock/fabricated answers as live backend responses.',
          whyReasonTamil: 'முன்முனை பயன்பாடு போலி பதில்களை நேரலை பதிவுகளாகக் காட்டுவதைத் தவிர்க்கிறது.',
          groundingScore: 0.0,
          ruleId: 'RULE-DISCONNECTED-00',
          citedProvenance: 'RagUzhavan Frontend State Engine',
          language: language,
          isGrounded: false,
          status: ResponseStatus.noData,
          stateName: 'Tamil Nadu',
          districtName: 'Unconnected Backend',
          blockName: 'Unconnected Block',
          blockNameTamil: 'இணைக்கப்படாத வட்டாரம்',
          cropName: 'Target Crop',
          growthStage: 'N/A',
          season: 'N/A',
          averageDataAgeDays: 0,
          timestamp: DateTime.now(),
          evidenceSources: const [],
          clarificationQuestions: const [],
        );

      case 'clarification_location':
        return RagResponse(
          id: 'RESP-MOCK-CLARIFY-LOC-01',
          queryId: 'QUERY-LOC-01',
          responseText:
              'I need one more detail before grounding your advisory: Which district and block is your field located in?',
          responseTextTamil:
              'உங்கள் வயல் எந்த மாவட்டம் மற்றும் வட்டாரத்தில் உள்ளது என்ற கூடுதல் விவரம் தேவை:',
          recommendationSummary: 'Location specification required for micro-climatic grounding.',
          recommendationSummaryTamil: 'துல்லியமான மண்டலப் பரிந்துரைக்கு இருப்பிடக் விவரம் தேவை.',
          whatToDo: 'Select your active district and block scope below.',
          whatToDoTamil: 'கீழே உங்களின் மாவட்டம் மற்றும் வட்டாரத்தைத் தேர்ந்தெடுக்கவும்.',
          whenToApply: 'Immediate action prior to processing query.',
          whenToApplyTamil: 'கேள்வியைச் செயலாக்கும் முன் தேவைப்படும் நடவடிக்கை.',
          howMuchAmount: 'N/A',
          howMuchAmountTamil: 'பொருந்தாது',
          whyReason: 'Extension bulletins vary significantly across Cauvery Delta alluvial clay vs Western Vertisol blocks.',
          whyReasonTamil: 'காவேரி டெல்டா வண்டல் மண் மற்றும் மேற்கு மண்டல கரிசல் மண் பரிந்துரைகள் மாறுபடும்.',
          groundingScore: 0.0,
          ruleId: 'RULE-DISCOVERY-LOC-00',
          citedProvenance: 'RagUzhavan Micro-Climatic Rule Engine',
          language: language,
          isGrounded: false,
          status: ResponseStatus.clarificationNeeded,
          stateName: 'Tamil Nadu',
          districtName: 'Unspecified District',
          blockName: 'Unspecified Block',
          blockNameTamil: 'குறிப்பிடப்படாத வட்டாரம்',
          cropName: 'Paddy / Rice',
          growthStage: 'Tillering',
          season: 'Kuruvai',
          averageDataAgeDays: 0,
          timestamp: DateTime.now(),
          evidenceSources: const [],
          clarificationQuestions: const [
            ClarificationQuestion(
              id: 'CLARIFY-DISTRICT-01',
              questionText: 'Select your field district jurisdiction:',
              questionTextTamil: 'உங்கள் வயல் அமைந்துள்ள மாவட்டத்தைத் தேர்ந்தெடுக்கவும்:',
              fieldName: 'districtName',
              options: ['Thanjavur (Cauvery Delta)', 'Coimbatore (Western Zone)', 'Ramanathapuram (Coastal Dry)', 'Madurai (Southern Zone)'],
              optionsTamil: ['தஞ்சாவூர் (காவேரி டெல்டா)', 'கோயம்புத்தூர் (மேற்கு மண்டலம்)', 'ராமநாதபுரம் (கடலோர உலர் மண்டலம்)', 'மதுரை (தெற்கு மண்டலம்)'],
            ),
          ],
        );

      case 'clarification_cotton':
      case 'clarification':
        return RagResponse(
          id: 'RESP-MOCK-CLARIFY-02',
          queryId: 'QUERY-102',
          responseText:
              'To recommend precise bollworm management for Cotton in Coimbatore (Thondamuthur block), additional specific field conditions are needed before matching CICR protocols.',
          responseTextTamil:
              'கோயம்புத்தூர் தொண்டாமுத்தூர் வட்டாரப் பருத்திப் பயிரில் காய் புழு மேலாண்மைக்கு துல்லியமான பரிந்துரை வழங்க, தங்களின் நில வடிகால் மற்றும் பாசன விவரங்கள் தேவை.',
          recommendationSummary: 'Field drainage and irrigation method specification required.',
          recommendationSummaryTamil: 'நில வடிகால் மற்றும் பாசன முறை விவரங்கள் தேவைப்படுகிறது.',
          whatToDo: 'Provide field drainage type and active irrigation method.',
          whatToDoTamil: 'நில வடிகால் அமைப்பு மற்றும் பாசன முறையைக் குறிப்பிடவும்.',
          whenToApply: 'Before chemical spray application.',
          whenToApplyTamil: 'மருந்து தெளிப்பதற்கு முன்.',
          howMuchAmount: 'N/A',
          howMuchAmountTamil: 'பொருந்தாது',
          whyReason: 'Poorly drained Vertisols require lower spray volume to prevent root asphyxiation during boll formation.',
          whyReasonTamil: 'குறைந்த வடிகால் கரிசல் நிலங்களில் வேர் அழுகலைத் தடுக்க தெளிப்பு அளவு மாறுபடும்.',
          groundingScore: 0.45,
          ruleId: 'RULE-CICR-COTTON-02',
          citedProvenance: 'CICR Cotton Extension Bulletin 2025',
          language: language,
          isGrounded: false,
          status: ResponseStatus.clarificationNeeded,
          stateName: 'Tamil Nadu',
          districtName: 'Coimbatore',
          blockName: 'Thondamuthur',
          blockNameTamil: 'தொண்டாமுத்தூர்',
          cropName: 'Cotton (MCU-5)',
          growthStage: 'Boll Formation',
          season: 'Kharif',
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
              'No current data available for your block (Kadaladi block, Ramanathapuram district). Station bulletins for groundnut dryland pest dynamics are older than 194 days. The system refrains from substituting neighboring district data.',
          responseTextTamil:
              'ராமநாதபுரம் மாவட்டம் கடலாடி வட்டாரத்திற்குரிய தற்போதைய தரவுகள் இல்லை. நிலக்கடலை அசுவினி பூச்சி பரவல் பற்றிய பதிவுகள் 194 நாட்களுக்கு முந்தையவை. கணினி பக்கத்து மாவட்டத் தரவுகளை மாற்றாக வழங்காது.',
          recommendationSummary: 'No current extension advisory retrieved for Kadaladi block.',
          recommendationSummaryTamil: 'கடலாடி வட்டாரத்திற்குரிய தற்போதைய வேளாண் அறிவுரை கிடைக்கவில்லை.',
          whatToDo: 'Consult local Assistant Agricultural Officer (AAO) or await updated IMD/TNAU station release.',
          whatToDoTamil: 'வட்டார உதவி வேளாண் அலுவலரை அனுகவும் அல்லது புதிய அறிவிப்பு வரை காத்திருக்கவும்.',
          whenToApply: 'N/A',
          whenToApplyTamil: 'பொருந்தாது',
          howMuchAmount: '0 (Refrain from unsanctioned chemical sprays)',
          howMuchAmountTamil: '0 (பரிந்துரைக்கப்படாத மருந்து தெளிப்பதைத் தவிர்க்கவும்)',
          whyReason: 'Dataset age exceeds 180-day safety threshold for dryland pest outbreaks.',
          whyReasonTamil: 'மானாவாரி பூச்சி மேலாண்மைத் தரவுகள் 180 நாட்கள் வரம்பைக் கடந்துவிட்டன.',
          groundingScore: 0.0,
          ruleId: 'RULE-STALENESS-EXPLICIT-00',
          citedProvenance: 'TNAU Station Bulletin Threshold Engine',
          language: language,
          isGrounded: false,
          status: ResponseStatus.noData,
          stateName: 'Tamil Nadu',
          districtName: 'Ramanathapuram',
          blockName: 'Kadaladi',
          blockNameTamil: 'கடலாடி',
          cropName: 'Groundnut (TMV-7)',
          growthStage: 'Pegging',
          season: 'Late Rabi / Dryland',
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
              'தஞ்சாவூர் மாவட்டம் பூதலூர் வட்டார குறுவை நெல் குலை நோயைக் கட்டுப்படுத்த, ட்ரைசைக்ளசோல் 75% WP மருந்தை 0.6 கிராம்/லிட்டர் தண்ணீரில் கலந்து தெளிக்கவும். நைட்ரஜன் உரத்தை 3 பங்காகப் பிரித்து இடவும்.',
          responseTextTamil:
              'தஞ்சாவூர் மாவட்டம் பூதலூர் வட்டார குறுவை நெல் குலை நோயைக் கட்டுப்படுத்த, ட்ரைசைக்ளசோல் 75% WP மருந்தை 0.6 கிராம்/லிட்டர் தண்ணீரில் கலந்து தெளிக்கவும். நைட்ரஜன் உரத்தை 3 பங்காகப் பிரித்து இடவும்.',
          recommendationSummary: 'ட்ரைசைக்ளசோல் 75% WP மருந்தை 0.6 கிராம்/லிட்டர் தெளிக்கவும்.',
          recommendationSummaryTamil: 'ட்ரைசைக்ளசோல் 75% WP மருந்தை 0.6 கிராம்/லிட்டர் தெளிக்கவும்.',
          whatToDo: 'இலையில் முதல் நோய் அறிகுறி தோன்றியவுடன் தெளிக்கவும்.',
          whatToDoTamil: 'இலையில் முதல் நோய் அறிகுறி தோன்றியவுடன் தெளிக்கவும்.',
          whenToApply: 'காலை 7:00 - 10:00 மணிக்குள் (இலை உலர்வாக இருக்கும்போது).',
          whenToApplyTamil: 'காலை 7:00 - 10:00 மணிக்குள் (இலை உலர்வாக இருக்கும்போது).',
          howMuchAmount: 'ஹெக்டேருக்கு 500 கிராம் ட்ரைசைக்ளசோல் 75% WP + 50 கிலோ பொட்டாஷ் உரப்பிரிப்பு.',
          howMuchAmountTamil: 'ஹெக்டேருக்கு 500 கிராம் ட்ரைசைக்ளசோல் 75% WP + 50 கிலோ பொட்டாஷ் உரப்பிரிப்பு.',
          whyReason: 'காவேரி டெல்டா களிமண் நிலங்களில் 85% இரவு நேர ஈரப்பதத்தில் குலை நோய் 92.4% கட்டுப்படுத்தப்படுகிறது.',
          whyReasonTamil: 'காவேரி டெல்டா களிமண் நிலங்களில் 85% இரவு நேர ஈரப்பதத்தில் குலை நோய் 92.4% கட்டுப்படுத்தப்படுகிறது.',
          groundingScore: 0.96,
          ruleId: 'RULE-TNAU-BLAST-TA-01',
          citedProvenance: 'தமிழ்நாடு வேளாண்மை பல்கலைக்கழக கையேடு 2025',
          language: 'ta',
          isGrounded: true,
          status: ResponseStatus.grounded,
          stateName: 'தமிழ்நாடு',
          districtName: 'தஞ்சாவூர் (Thanjavur)',
          blockName: 'Budalur',
          blockNameTamil: 'பூதலூர் (Budalur)',
          cropName: 'நெல் / குறுவை (Paddy)',
          growthStage: 'தூர்கட்டும் பருவம்',
          season: 'குறுவை 2025',
          averageDataAgeDays: 11,
          timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
          evidenceSources: const [
            EvidenceSource(
              id: 'EVID-TNAU-TA-01',
              title: 'தமிழ்நாடு வேளாண்மை பல்கலைக்கழக நெல் நோய் மேலாண்மை கையேடு 2025',
              publicationDate: '2025-06-15',
              authorOrInstitute: 'TNAU பயிர் பாதுகாப்பு மையம், கோயம்புத்தூர்',
              documentType: 'பல்கலைக்கழக ஆவணப் பதிவு',
              excerpt: 'குறுவை பருவத்தில் களிமண் நிலங்களில் நெல் குலை நோய் தாக்குதல் அதிகரிக்கும் போது ட்ரைசைக்ளசோல் தெளிப்பு (0.6 கிராம்/லிட்டர்) 92.4% நோயைக் கட்டுப்படுத்துகிறது.',
              excerptTamil: 'குறுவை பருவத்தில் களிமண் நிலங்களில் நெல் குலை நோய் தாக்குதல் அதிகரிக்கும் போது ட்ரைசைக்ளசோல் தெளிப்பு (0.6 கிராம்/லிட்டர்) 92.4% நோயைக் கட்டுப்படுத்துகிறது.',
              confidenceScore: 0.96,
              datasetAgeDays: 11,
              urlOrRef: 'TNAU-CPPS-BULLETIN-2025/RICE-BLAST',
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
              'For Rice Blast (Pyricularia oryzae) management in Thanjavur district (Budalur block) during Kuruvai season: Apply Tricyclazole 75% WP @ 0.6 g/L water at first lesion appearance. Maintain 50 kg/ha Potash split dosing.',
          responseTextTamil:
              'தஞ்சாவூர் மாவட்டம் பூதலூர் வட்டார குறுவை நெல் குலை நோயைக் கட்டுப்படுத்த, ட்ரைசைக்ளசோல் 75% WP மருந்தை 0.6 கிராம்/லிட்டர் தண்ணீரில் கலந்து தெளிக்கவும்.',
          recommendationSummary: 'Apply Tricyclazole 75% WP @ 0.6 g/L water with Potash topdressing.',
          recommendationSummaryTamil: 'ட்ரைசைக்ளசோல் 75% WP மருந்தை 0.6 கிராம்/லிட்டர் தண்ணீரில் கலந்து தெளிக்கவும்.',
          whatToDo: 'Foliar spray at first blast lesion appearance; split Nitrogen into 3 equal topdressings.',
          whatToDoTamil: 'முதல் நோய் அறிகுறி கண்டவுடன் இலைத் தெளிப்பு செய்யவும்.',
          whenToApply: 'Morning hours (7:00 AM - 10:00 AM) on dry foliage when humidity is >85%.',
          whenToApplyTamil: 'காலை 7:00 - 10:00 மணிக்குள் இலை உலர்வாக இருக்கும்போது தெளிக்கவும்.',
          howMuchAmount: '0.6 g/L water (500 g/ha Tricyclazole 75% WP) + 50 kg/ha MOP split fertilizer.',
          howMuchAmountTamil: '0.6 கிராம்/லிட்டர் (ஹெக்டேருக்கு 500 கிராம்) + 50 கிலோ பொட்டாஷ்.',
          whyReason: 'Cauvery Delta clay soils under Kuruvai high night humidity require systemic triazole activity to protect tillers.',
          whyReasonTamil: 'டெல்டா களிமண் நிலங்களில் அதிக ஈரப்பதத்தில் ட்ரைசைக்ளசோல் 92.4% நோய் கட்டுப்பாடு அளிக்கிறது.',
          groundingScore: 0.94,
          ruleId: 'RULE-TNAU-BLAST-01',
          citedProvenance: 'TNAU Crop Production Guide 2025 & ICAR-NRRI Advisory',
          numericRecommendations: const [
            NumericRecommendation(
              parameter: 'Tricyclazole 75% WP Dosage',
              value: 0.6,
              unit: 'g/L',
              ruleId: 'RULE-TNAU-BLAST-01',
              sourceTitle: 'TNAU Crop Production Guide 2025',
              publicationDate: '2025-05-10',
              retrievedDate: '2026-09-08',
              region: 'Thanjavur Delta',
              cropApplicability: 'Paddy / Rice',
            ),
            NumericRecommendation(
              parameter: 'MOP Potash Fertilizer',
              value: 50.0,
              unit: 'kg/ha',
              ruleId: 'RULE-ICAR-POTASH-04',
              sourceTitle: 'ICAR-NRRI Kuruvai Advisory',
              publicationDate: '2025-05-28',
              retrievedDate: '2026-09-08',
              region: 'Thanjavur Delta',
              cropApplicability: 'Paddy / Rice',
            ),
          ],
          language: language,
          isGrounded: true,
          status: ResponseStatus.grounded,
          stateName: 'Tamil Nadu',
          districtName: 'Thanjavur',
          blockName: 'Budalur',
          blockNameTamil: 'பூதலூர்',
          cropName: 'Paddy / Rice (CR 1009 Sub 1)',
          growthStage: 'Tillering Phase',
          season: 'Kuruvai 2025',
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
        id: 'thanjavur_budalur',
        stateName: 'Tamil Nadu',
        districtName: 'Thanjavur',
        districtNameTamil: 'தஞ்சாவூர்',
        blockName: 'Budalur',
        blockNameTamil: 'பூதலூர்',
        agroClimaticZone: 'Cauvery Delta Zone',
        dominantSoilType: 'Alluvial & Deep Clay',
        primarySeason: 'Kuruvai & Samba',
        latitude: 10.7870,
        longitude: 79.1378,
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
        dominantSoilType: 'Black Cotton Soil (Vertisols)',
        primarySeason: 'Kharif & Rabi',
        latitude: 11.0168,
        longitude: 76.9558,
        hasActiveStationData: true,
      ),
      Region(
        id: 'ramanathapuram_kadaladi',
        stateName: 'Tamil Nadu',
        districtName: 'Ramanathapuram',
        districtNameTamil: 'ராமநாதபுரம்',
        blockName: 'Kadaladi',
        blockNameTamil: 'கடலாடி',
        agroClimaticZone: 'Coastal & Southern Dry Zone',
        dominantSoilType: 'Saline Coastal & Sandy Loam',
        primarySeason: 'Special Late Rabi / Dryland',
        latitude: 9.3639,
        longitude: 78.8395,
        hasActiveStationData: false,
      ),
      Region(
        id: 'madurai_thiruparankundram',
        stateName: 'Tamil Nadu',
        districtName: 'Madurai',
        districtNameTamil: 'மதுரை',
        blockName: 'Thiruparankundram',
        blockNameTamil: 'திருப்பரங்குன்றம்',
        agroClimaticZone: 'Southern Zone',
        dominantSoilType: 'Red Loam & Clay Loam',
        primarySeason: 'Chithirai & Samba',
        latitude: 9.9252,
        longitude: 78.1198,
        hasActiveStationData: true,
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
        district: 'Coimbatore (Thondamuthur)',
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
        district: 'Ramanathapuram (Kadaladi)',
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
      district: 'Thanjavur (Budalur)',
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
      payloadSizeBytes: 1840, // 1.8 KB
      maxConstraintBytes: 51200, // 50.0 KB engineering constraint
      recommendation:
          'SPRAY TRICYCLAZOLE 75WP @ 0.6g/L for Rice Blast (Thanjavur / Budalur / Kuruvai). Split N topdressing + 50kg MOP/ha.',
      recommendationTamil:
          'குறுவை நெல் குலை நோய் (பூதலூர்): ட்ரைசைக்ளசோல் 75WP (0.6g/L) தெளிக்கவும். N உரப் பிரிப்பு + 50kg பொட்டாஷ்.',
      essentialReason:
          'Cauvery Delta clay soils under >85% night humidity require triazole systemic protection.',
      essentialReasonTamil:
          'காவேரி டெல்டா களிமண் நிலங்களில் 85% இரவு ஈரப்பதத்தில் ட்ரைசைக்ளசோல் 92.4% பாதுகாப்பு அளிக்கிறது.',
      citedSource: 'TNAU-CPG-2025/BULLETIN-408',
      publicationDate: '2025-05-10',
      dataAgeDays: 14,
      queueStatus: 'delivered',
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<List<Farmer>> fetchFarmersList() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    return [
      Farmer(
        id: 'FARM-001',
        name: 'M. Palanisamy',
        phone: '+91 98421 88321',
        district: 'Thanjavur',
        block: 'Budalur',
        state: 'Tamil Nadu',
        preferredLanguage: 'ta',
        crops: ['Paddy / Rice', 'Blackgram'],
        landSizeAcres: 4.5,
        agroZone: 'Cauvery Delta Zone',
        season: 'Kuruvai',
        accountStatus: 'Active',
        lastActivity: now.subtract(const Duration(minutes: 15)),
      ),
      Farmer(
        id: 'FARM-002',
        name: 'K. Arumugam',
        phone: '+91 97892 41105',
        district: 'Coimbatore',
        block: 'Thondamuthur',
        state: 'Tamil Nadu',
        preferredLanguage: 'en',
        crops: ['Cotton', 'Maize'],
        landSizeAcres: 8.0,
        agroZone: 'Western Zone',
        season: 'Kharif',
        accountStatus: 'Active',
        lastActivity: now.subtract(const Duration(hours: 3)),
      ),
      Farmer(
        id: 'FARM-003',
        name: 'S. Ramanathan',
        phone: '+91 94431 09277',
        district: 'Ramanathapuram',
        block: 'Kadaladi',
        state: 'Tamil Nadu',
        preferredLanguage: 'ta',
        crops: ['Groundnut', 'Chilli'],
        landSizeAcres: 3.2,
        agroZone: 'Coastal Dry Zone',
        season: 'Late Rabi',
        accountStatus: 'Pending Review',
        lastActivity: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      Farmer(
        id: 'FARM-004',
        name: 'V. Sundaram',
        phone: '+91 98765 12345',
        district: 'Thanjavur',
        block: 'Kumbakonam',
        state: 'Tamil Nadu',
        preferredLanguage: 'ta',
        crops: ['Paddy / Rice', 'Sugarcane'],
        landSizeAcres: 6.0,
        agroZone: 'Cauvery Delta Zone',
        season: 'Samba',
        accountStatus: 'Active',
        lastActivity: now.subtract(const Duration(minutes: 42)),
      ),
      Farmer(
        id: 'FARM-005',
        name: 'R. Meenakshi',
        phone: '+91 99440 98765',
        district: 'Madurai',
        block: 'Thiruparankundram',
        state: 'Tamil Nadu',
        preferredLanguage: 'ta',
        crops: ['Jasmine', 'Pulses'],
        landSizeAcres: 2.8,
        agroZone: 'Southern Zone',
        season: 'Chithirai',
        accountStatus: 'Flagged',
        lastActivity: now.subtract(const Duration(days: 2)),
      ),
    ];
  }
}
