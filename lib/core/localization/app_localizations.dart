import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ta'),
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // General & Identity
      'appName': 'RagUzhavan',
      'appTagline': 'Region-Aware Agricultural Intelligence System',
      'stateContext': 'State',
      'districtContext': 'District',
      'blockContext': 'Block',
      'agroZone': 'Agro-Climatic Zone',
      'cropSeason': 'Crop & Season',
      'primarySeason': 'Primary Season',
      'language': 'Language',
      'english': 'English',
      'tamil': 'தமிழ் (Tamil)',

      // Navigation
      'navHome': 'Overview',
      'navAsk': 'Query System',
      'navRegion': 'District & Block Scope',
      'navLowBandwidth': 'Low Bandwidth',
      'navSettings': 'Settings',
      'navAdmin': 'Admin Control',
      'navFarmers': 'Farmers Directory',

      // Actions & Buttons
      'askQuestion': 'Submit Agricultural Query',
      'submit': 'Submit',
      'cancel': 'Cancel',
      'retry': 'Retry Query',
      'clear': 'Clear',
      'save': 'Save Settings',
      'login': 'Sign In',
      'register': 'Register Account',
      'logout': 'Sign Out',
      'switchLanguage': 'Switch Language',
      'selectRegion': 'Select Active Scope',
      'viewEvidence': 'Inspect Evidence Sources',
      'hideEvidence': 'Hide Evidence Sources',
      'provideClarification': 'Provide Missing Details',

      // Landing Problem & Narrative
      'landingProblemTitle': 'Fragmented Agricultural Knowledge',
      'landingProblemSub': 'Critical data exists across weather models, mandi APIs, soil cards, and university bulletins—but remains disconnected from daily farming decisions.',
      'narrativeStep1': '1. Fragmented Data',
      'narrativeStep2': '2. Regional Scope',
      'narrativeStep3': '3. Grounded Evidence',
      'narrativeStep4': '4. Precise Action',
      'publicSourcesTitle': 'PUBLIC AGRICULTURAL DATASETS SYNTHESIZED',

      // Farmer Home
      'farmerDashboardTitle': 'FARMER OVERVIEW',
      'whatCanIAskTitle': 'What can I ask RagUzhavan?',
      'askCategoryIrrigation': 'Irrigation Advisory',
      'askCategorySowing': 'Sowing Calendar',
      'askCategoryAttention': 'Field Condition Warning',
      'askCategoryAdvisory': 'Regional Advisory',
      'askCategoryMandi': 'Mandi Commodity Price',
      'sampleIrrigation': 'Should I irrigate my paddy field this week?',
      'sampleSowing': 'When should I sow Samba paddy in Thanjavur?',
      'sampleAttention': 'Is high night humidity likely to require blast attention?',
      'sampleAdvisory': 'What does the current regional advisory recommend for Kuruvai?',
      'sampleMandi': 'Is today\'s paddy mandi price in Thanjavur worth considering?',

      // Ask & Clarification
      'askHeader': 'Region & Season Grounded Query',
      'askSubheader': 'Ask a time-sensitive farming question. Responses are strictly anchored in official agricultural records.',
      'questionPlaceholder': 'E.g., Should I irrigate my paddy field this week in Budalur block?',
      'cropNameLabel': 'Target Crop',
      'growthStageLabel': 'Growth Stage',
      'irrigationLabel': 'Irrigation System',
      'presetQueries': 'Sample Regional Enquiries',
      'clarificationNeededHeader': 'ADDITIONAL CONTEXT REQUIRED',
      'missingContextPrompt': 'I need one more detail to ground your recommendation:',

      // RAG Response Sections (Non-ChatGPT Layout)
      'responseHeader': 'Grounded Agricultural Assessment',
      'secRecommendation': 'RECOMMENDATION',
      'secWhatToDo': 'WHAT TO DO',
      'secWhen': 'WHEN TO APPLY',
      'secHowMuch': 'HOW MUCH / DOSAGE',
      'secWhy': 'SCIENTIFIC RATIONALE',
      'secGrounding': 'GROUNDING INDEX',
      'secDataAge': 'DATASET FRESHNESS',
      'secSources': 'CITED SOURCES & PROVENANCE',

      // Status Banners
      'statusGrounded': 'VERIFIED GROUNDED EVIDENCE',
      'statusClarification': 'ADDITIONAL CONTEXT REQUIRED',
      'statusNoData': 'NO CURRENT DATA AVAILABLE FOR YOUR BLOCK',
      'noDataExplanation': 'No current research bulletins or station data are available for your selected block. The system explicitly refrains from substituting neighboring district data.',
      'provenanceRuleLabel': 'Deterministic Rule',

      // Low Bandwidth SMS Simulator (50 KB Constraint)
      'lowBandwidthHeader': 'Low-Bandwidth / 2G SMS Channel',
      'lowBandwidthSubheader': 'Simulates receiving compact 1.8 KB text messages under strict 50 KB total exchange constraint.',
      'exchangeSize': 'Exchange Payload Size',
      'constraintLimit': '50.0 KB Max Engineering Constraint',
      'queueStatus': 'Queue Status',
      'essentialReason': 'Essential Rationale',
      'sendSmsQuery': 'Send via SMS Queue',

      // Region Scope Selector
      'regionHeader': 'State, District & Block Scope',
      'stateLabel': 'State Jurisdiction',
      'districtLabel': 'District Scope (Mandatory)',
      'blockLabel': 'Block / Taluk (Preferred)',
      'soilType': 'Dominant Soil Type',
      'primaryCrops': 'Primary Crops',
      'activeAlerts': 'District Agricultural Alerts',
      'sensorTelemetry': 'Field Sensor Telemetry',

      // Admin & Common
      'adminHeader': 'Regional Data Audit & Telemetry',
      'registeredFarmers': 'Registered Farmers',
      'queriesProcessed': 'Queries Processed Today',
      'groundedPercentage': 'Grounded Response Rate',
      'outdatedDataAlerts': 'Data Staleness Warnings',
      'loginHeader': 'Agricultural Portal Access',
      'usernamePlaceholder': 'Phone Number or Extension ID',
      'passwordPlaceholder': 'Security PIN',
      'roleFarmer': 'Farmer Access',
      'roleAdmin': 'Agricultural Officer / Admin',
      'loading': 'Retrieving regional records...',
      'errorGeneric': 'Unable to process query at this time.',
      'networkError': 'Connection unavailable. Switch to low-bandwidth mode.',
      'apiEndpoint': 'API Base URL Config',
      'mockModeNotice': 'Operating with localized agricultural vector database.',
    },
    'ta': {
      // General & Identity
      'appName': 'ரக் உழவன்',
      'appTagline': 'மண்டல விவசாய அறிவுத்திறன் அமைப்பு',
      'stateContext': 'மாநிலம்',
      'districtContext': 'மாவட்டம்',
      'blockContext': 'வட்டாரம் / ஒன்றியம்',
      'agroZone': 'வேளாண் தட்பவெப்ப மண்டலம்',
      'cropSeason': 'பயிர் மற்றும் பருவம்',
      'primarySeason': 'முதன்மைப் பருவம்',
      'language': 'மொழி',
      'english': 'English',
      'tamil': 'தமிழ் (Tamil)',

      // Navigation
      'navHome': 'முகப்பு',
      'navAsk': 'கேள்வி கேட்க',
      'navRegion': 'மாவட்ட மற்றும் வட்டார எல்லை',
      'navLowBandwidth': 'குறைந்த அலைவரிசை',
      'navSettings': 'அமைப்புகள்',
      'navAdmin': 'நிர்வாகக் கட்டுப்பாடு',
      'navFarmers': 'விவசாயிகள் விவரம்',

      // Actions & Buttons
      'askQuestion': 'விவசாயக் கேள்வியை சமர்ப்பிக்கவும்',
      'submit': 'சமர்ப்பி',
      'cancel': 'ரத்து செய்',
      'retry': 'மீண்டும் முயல்க',
      'clear': 'அழி',
      'save': 'அமைப்புகளைச் சேமி',
      'login': 'உள்நுழைக',
      'register': 'பதிவு செய்க',
      'logout': 'வெளியேறு',
      'switchLanguage': 'மொழியை மாற்று',
      'selectRegion': 'எல்லையைத் தேர்ந்தெடு',
      'viewEvidence': 'ஆதாரங்களை ஆய்வு செய்',
      'hideEvidence': 'ஆதாரங்களை மறை',
      'provideClarification': 'கூடுதல் விவரங்களை அளி',

      // Landing Problem & Narrative
      'landingProblemTitle': 'சிதறிய விவசாயத் தகவல்கள்',
      'landingProblemSub': 'வானிலை, சந்தை விலை, மண் அட்டை மற்றும் பல்கலைக்கழக வழிகாட்டல்கள் தனித்தனியாக சிதறிக்கிடக்கின்றன.',
      'narrativeStep1': '1. சிதறிய தரவு',
      'narrativeStep2': '2. மண்டலச் சூழல்',
      'narrativeStep3': '3. சரிபார்க்கப்பட்ட சான்று',
      'narrativeStep4': '4. துல்லிய நடவடிக்கை',
      'publicSourcesTitle': 'ஒருங்கிணைக்கப்பட்ட பொது விவசாயத் தரவுகள்',

      // Farmer Home
      'farmerDashboardTitle': 'விவசாயி முகப்பு',
      'whatCanIAskTitle': 'ரக் உழவனிடம் என்ன கேட்கலாம்?',
      'askCategoryIrrigation': 'பாசன வழிகாட்டுதல்',
      'askCategorySowing': 'விதைப்பு நாட்காட்டி',
      'askCategoryAttention': 'பயிர் நிலைக் கவனிப்பு',
      'askCategoryAdvisory': 'மண்டலப் பரிந்துரை',
      'askCategoryMandi': 'சந்தை விலை நிலவரம்',
      'sampleIrrigation': 'இந்த வாரம் நெல் வயலுக்கு நீர் பாய்ச்ச வேண்டுமா?',
      'sampleSowing': 'தஞ்சாவூரில் சம்பா நெல் விதைப்பு எப்போது தொடங்குவது?',
      'sampleAttention': 'இரவு நேர அதிக ஈரப்பதம் குலை நோய் தாக்குதலை உருவாக்குமா?',
      'sampleAdvisory': 'குறுவை பருவத்திற்கான தற்போதைய மண்டலப் பரிந்துரை என்ன?',
      'sampleMandi': 'இன்றைய தஞ்சாவூர் நெல் சந்தை விலை உகந்ததா?',

      // Ask & Clarification
      'askHeader': 'மண்டல மற்றும் பருவ ஆவண கேள்வி',
      'askSubheader': 'உங்கள் விவசாயக் கேள்வியைக் கேளுங்கள். பதில்கள் அதிகாரப்பூர்வ விவசாய பதிவுகளின் அடிப்படையில் வழங்கப்படும்.',
      'questionPlaceholder': 'எ.கா: பூதலூர் வட்டாரத்தில் இந்த வாரம் நெல் வயலுக்கு பாசனம் செய்ய வேண்டுமா?',
      'cropNameLabel': 'பயிர் பெயர்',
      'growthStageLabel': 'வளர்ச்சி நிலை',
      'irrigationLabel': 'பாசன முறை',
      'presetQueries': 'மாதிரி மாவட்டக் கேள்விகள்',
      'clarificationNeededHeader': 'கூடுதல் விவரம் தேவைப்படுகிறது',
      'missingContextPrompt': 'துல்லியமான பரிந்துரையை வழங்க எனக்கு ஒரு கூடுதல் விவரம் தேவை:',

      // RAG Response Sections (Non-ChatGPT Layout)
      'responseHeader': 'ஆதாரப்பூர்வ விவசாய மதிப்பீடு',
      'secRecommendation': 'முதன்மைப் பரிந்துரை',
      'secWhatToDo': 'செய்ய வேண்டிய நடவடிக்கை',
      'secWhen': 'எப்போது செய்ய வேண்டும்',
      'secHowMuch': 'அளவு / மருந்து அளவு',
      'secWhy': 'அறிவியல் காரணம்',
      'secGrounding': 'ஆதார நம்பிக்கைக் குறியீடு',
      'secDataAge': 'தரவுப் பழமை',
      'secSources': 'ஆதார ஆவணங்கள் & மூலம்',

      // Status Banners
      'statusGrounded': 'உறுதிசெய்யப்பட்ட ஆதாரப் பதில்',
      'statusClarification': 'கூடுதல் விவரம் தேவைப்படுகிறது',
      'statusNoData': 'தங்களின் வட்டாரத்திற்குரிய தற்போதைய தரவு இல்லை',
      'noDataExplanation': 'நீங்கள் தேர்ந்தெடுத்த வட்டாரத்திற்குரிய தற்போதைய ஆராய்ச்சித் தரவுகள் கிடைக்கவில்லை. கணினி பக்கத்து மாவட்டத் தரவுகளை மாற்றாக வழங்காது.',
      'provenanceRuleLabel': 'அறிவியல் விதி',

      // Low Bandwidth SMS Simulator (50 KB Constraint)
      'lowBandwidthHeader': 'குறைந்த அலைவரிசை / 2G குறுஞ்செய்தி வழி',
      'lowBandwidthSubheader': '50 KB அதிகபட்ச வரம்பிற்குள் 1.8 KB சுருக்கப்பட்ட குறுஞ்செய்திகளைப் பெறும் மாதிரி.',
      'exchangeSize': 'செய்திப் பரிமாற்ற அளவு',
      'constraintLimit': '50.0 KB அதிகபட்ச வரம்பு',
      'queueStatus': 'வரிசை நிலை',
      'essentialReason': 'முதன்மை காரணம்',
      'sendSmsQuery': 'குறுஞ்செய்தி வழியில் அனுப்புக',

      // Region Scope Selector
      'regionHeader': 'மாநிலம், மாவட்டம் மற்றும் வட்டார எல்லை',
      'stateLabel': 'மாநில அதிகார வரம்பு',
      'districtLabel': 'மாவட்ட எல்லை (கட்டாயமானது)',
      'blockLabel': 'வட்டாரம் / ஒன்றியம் (முதன்மை)',
      'soilType': 'முக்கிய மண் வகை',
      'primaryCrops': 'முதன்மைப் பயிர்கள்',
      'activeAlerts': 'மாவட்ட விவசாய எச்சரிக்கைகள்',
      'sensorTelemetry': 'நில உணரி அளவீடுகள்',

      // Admin & Common
      'adminHeader': 'மண்டல தரவு தணிக்கை மற்றும் அளவீடுகள்',
      'registeredFarmers': 'பதிவுசெய்த விவசாயிகள்',
      'queriesProcessed': 'இன்று கேட்கப்பட்ட கேள்விகள்',
      'groundedPercentage': 'ஆதாரப்பூர்வ பதில் விகிதம்',
      'outdatedDataAlerts': 'பழைய தரவு எச்சரிக்கைகள்',
      'loginHeader': 'விவசாய இணைய முகப்பு அணுகல்',
      'usernamePlaceholder': 'தொலைபேசி எண் அல்லது அடையாள எண்',
      'passwordPlaceholder': 'கடவுச்சொல்',
      'roleFarmer': 'விவசாயி அணுகல்',
      'roleAdmin': 'வேளாண் அலுவலர் / நிர்வாகி',
      'loading': 'மண்டல பதிவுகளைப் பெறுகிறது...',
      'errorGeneric': 'தற்போது கேள்வியைச் செயலாக்க முடியவில்லை.',
      'networkError': 'இணைப்பு இல்லை. குறைந்த அலைவரிசை பயன்முறைக்கு மாறவும்.',
      'apiEndpoint': 'API முகவரி அமைப்பு',
      'mockModeNotice': 'உள்ளூர் விவசாயத் தரவுத்தளத்துடன் இயங்குகிறது.',
    },
  };

  String text(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ta'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
