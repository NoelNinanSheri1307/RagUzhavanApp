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
      // General & App Identity
      'appName': 'RagUzhavan',
      'appTagline': 'Region-Aware Agricultural Intelligence System',
      'districtContext': 'District Context',
      'agroZone': 'Agro-Climatic Zone',
      'cropSeason': 'Crop & Season',
      'language': 'Language',
      'english': 'English',
      'tamil': 'தமிழ் (Tamil)',
      
      // Navigation
      'navHome': 'Overview',
      'navAsk': 'Query System',
      'navRegion': 'District Scope',
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
      'selectRegion': 'Select Active District',
      'viewEvidence': 'Inspect Evidence Sources',
      'hideEvidence': 'Hide Evidence Sources',
      'provideClarification': 'Provide Missing Details',

      // Ask Question Screen
      'askHeader': 'Region & Season Grounded Query',
      'askSubheader': 'Ask a time-sensitive farming question. Responses are strictly anchored in official agricultural records.',
      'questionPlaceholder': 'E.g., What is the recommended treatment for rice blast in Thanjavur clay soil during Kuruvai season?',
      'cropNameLabel': 'Target Crop',
      'growthStageLabel': 'Growth Stage',
      'irrigationLabel': 'Irrigation System',
      'presetQueries': 'Sample Regional Enquiries',

      // Response & Grounded Evidence Screen
      'responseHeader': 'Grounded Agricultural Assessment',
      'evidenceCount': 'Verified Documents Cited',
      'dataAgeLabel': 'Record Freshness',
      'publicationDate': 'Published',
      'confidenceScore': 'Evidence Confidence',
      'authorInstitute': 'Publishing Institution',
      'statusGrounded': 'VERIFIED GROUNDED EVIDENCE',
      'statusClarification': 'ADDITIONAL CONTEXT REQUIRED',
      'statusNoData': 'NO CURRENT DATA AVAILABLE',
      'noDataExplanation': 'No grounded agricultural research or extension data for this district, crop, or timeframe was retrieved. The system refrains from producing speculative recommendations.',
      'clarificationPrompt': 'To ensure precise recommendations, please provide the following details regarding your field conditions:',

      // Region Selector
      'regionHeader': 'District & Agro-Climatic Scope',
      'soilType': 'Dominant Soil Type',
      'primaryCrops': 'Primary Crops',
      'activeAlerts': 'District Agricultural Alerts',
      'sensorTelemetry': 'Field Sensor Telemetry',

      // Low Bandwidth / SMS Mode
      'lowBandwidthHeader': 'Low-Bandwidth / SMS Channel',
      'lowBandwidthSubheader': 'Designed for 2G networks and remote field connectivity via compressed packet payload.',
      'payloadSize': 'Payload Size',
      'queueStatus': 'Transmission Queue',
      'compressedSummary': 'Compressed SMS Digest',
      'sendSmsQuery': 'Send via SMS Queue',

      // Admin & Telemetry
      'adminHeader': 'Regional Data Audit & Telemetry',
      'registeredFarmers': 'Registered Farmers',
      'queriesProcessed': 'Queries Processed Today',
      'groundedPercentage': 'Grounded Response Rate',
      'outdatedDataAlerts': 'Data Staleness Warnings',

      // Auth & Roles
      'loginHeader': 'Agricultural Portal Access',
      'usernamePlaceholder': 'Phone Number or Extension ID',
      'passwordPlaceholder': 'Security Pin / Password',
      'roleFarmer': 'Farmer Access',
      'roleAdmin': 'Agricultural Officer / Admin',

      // Common Labels & Errors
      'loading': 'Retrieving regional records...',
      'errorGeneric': 'Unable to process query at this time.',
      'networkError': 'Connection unavailable. Switch to low-bandwidth mode.',
      'apiEndpoint': 'API Base URL Config',
      'mockModeNotice': 'Running in Autonomous Frontend Mode (Mock Repository active).',
    },
    'ta': {
      // General & App Identity
      'appName': 'ரக் உழவன்',
      'appTagline': 'மண்டல விவசாய அறிவுத்திறன் அமைப்பு',
      'districtContext': 'மாவட்டச் சூழல்',
      'agroZone': 'வேளாண் தட்பவெப்ப மண்டலம்',
      'cropSeason': 'பயிர் மற்றும் பருவம்',
      'language': 'மொழி',
      'english': 'English',
      'tamil': 'தமிழ் (Tamil)',

      // Navigation
      'navHome': 'முகப்பு',
      'navAsk': 'கேள்வி கேட்க',
      'navRegion': 'மாவட்ட எல்லை',
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
      'selectRegion': 'மாவட்டத்தைத் தேர்ந்தெடு',
      'viewEvidence': 'ஆதாரங்களை ஆய்வு செய்',
      'hideEvidence': 'ஆதாரங்களை மறை',
      'provideClarification': 'கூடுதல் விவரங்களை அளி',

      // Ask Question Screen
      'askHeader': 'மண்டல மற்றும் பருவ ஆவண கேள்வி',
      'askSubheader': 'உங்கள் விவசாயக் கேள்வியைக் கேளுங்கள். பதில்கள் அதிகாரப்பூர்வ விவசாய பதிவுகளின் அடிப்படையில் வழங்கப்படும்.',
      'questionPlaceholder': 'எ.கா: தஞ்சாவூர் களிமண் நிலத்தில் குறுவை பருவத்தில் நெல் குலை நோய்க்கான பரிந்துரைக்கப்பட்ட சிகிச்சை என்ன?',
      'cropNameLabel': 'பயிர் பெயர்',
      'growthStageLabel': 'வளர்ச்சி நிலை',
      'irrigationLabel': 'பாசன முறை',
      'presetQueries': 'மாதிரி மாவட்டக் கேள்விகள்',

      // Response & Grounded Evidence Screen
      'responseHeader': 'ஆதாரப்பூர்வ விவசாய மதிப்பீடு',
      'evidenceCount': 'சரிபார்க்கப்பட்ட ஆவணங்கள்',
      'dataAgeLabel': 'தரவுப் பழமை',
      'publicationDate': 'வெளியிடப்பட்ட தேதி',
      'confidenceScore': 'ஆதார நம்பிக்கையளவு',
      'authorInstitute': 'வெளியிட்ட நிறுவனம்',
      'statusGrounded': 'உறுதிசெய்யப்பட்ட ஆதாரப் பதில்',
      'statusClarification': 'கூடுதல் விவரம் தேவைப்படுகிறது',
      'statusNoData': 'தற்போதைய தரவு இல்லை',
      'noDataExplanation': 'இந்த மாவட்டம், பயிர் அல்லது காலத்திற்குரிய ஆதாரப்பூர்வ விவசாய ஆராய்ச்சி தரவுகள் கிடைக்கவில்லை. கணினி ஊக பதில்களை வழங்காது.',
      'clarificationPrompt': 'துல்லியமான பரிந்துரையை வழங்க, உங்கள் நிலத்தின் கீழ்வரும் விவரங்களைக் குறிப்பிடவும்:',

      // Region Selector
      'regionHeader': 'மாவட்ட மற்றும் வேளாண் தட்பவெப்பப் பரப்பு',
      'soilType': 'முக்கிய மண் வகை',
      'primaryCrops': 'முதன்மைப் பயிர்கள்',
      'activeAlerts': 'மாவட்ட விவசாய எச்சரிக்கைகள்',
      'sensorTelemetry': 'நில உணரி அளவீடுகள்',

      // Low Bandwidth / SMS Mode
      'lowBandwidthHeader': 'குறைந்த அலைவரிசை / குறுஞ்செய்தி வழி',
      'lowBandwidthSubheader': '2G நெட்வொர்க் மற்றும் தொலைதூர கிராமப் பகுதிகளுக்கான சுருக்கப்பட்ட குறுஞ்செய்தி வழி.',
      'payloadSize': 'செய்தி அளவு',
      'queueStatus': 'அனுப்பும் வரிசை நிலை',
      'compressedSummary': 'சுருக்கப்பட்ட செய்திச் சாரம்',
      'sendSmsQuery': 'குறுஞ்செய்தி வழியில் அனுப்புக',

      // Admin & Telemetry
      'adminHeader': 'மண்டல தரவு தணிக்கை மற்றும் அளவீடுகள்',
      'registeredFarmers': 'பதிவுசெய்த விவசாயிகள்',
      'queriesProcessed': 'இன்று கேட்கப்பட்ட கேள்விகள்',
      'groundedPercentage': 'ஆதாரப்பூர்வ பதில் விகிதம்',
      'outdatedDataAlerts': 'பழைய தரவு எச்சரிக்கைகள்',

      // Auth & Roles
      'loginHeader': 'விவசாய இணைய முகப்பு அணுகல்',
      'usernamePlaceholder': 'தொலைபேசி எண் அல்லது அடையாள எண்',
      'passwordPlaceholder': 'கடவுச்சொல்',
      'roleFarmer': 'விவசாயி அணுகல்',
      'roleAdmin': 'வேளாண் அலுவலர் / நிர்வாகி',

      // Common Labels & Errors
      'loading': 'மண்டல பதிவுகளைப் பெறுகிறது...',
      'errorGeneric': 'தற்போது கேள்வியைச் செயலாக்க முடியவில்லை.',
      'networkError': 'இணைப்பு இல்லை. குறைந்த அலைவரிசை பயன்முறைக்கு மாறவும்.',
      'apiEndpoint': 'API முகவரி அமைப்பு',
      'mockModeNotice': 'சுயாதீன முன்முனை பயன்முறையில் இயங்குகிறது.',
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
