# RagUzhavan (ரக் உழவன்)

> **Region-Aware Agricultural Intelligence System**  
> Anchored in official district crop advisories, university research bulletins, data freshness metrics, mobile speech-to-text, on-device translation with numeric protection, and zero speculative hallucinations.

---

## Executive Overview

**RagUzhavan** is a mobile and cross-platform agricultural intelligence application designed to deliver precise, time-sensitive farming advice tailored to specific districts, soil types, crop growth stages, and agricultural seasons. 

Traditional AI assistants often provide generic or hallucinated farming recommendations that fail to account for local agro-climatic conditions or regional pest outbreaks. **RagUzhavan** addresses this critical gap by anchoring all agricultural answers in verified extension literature (such as Tamil Nadu Agricultural University bulletins, ICAR scientific advisories, and station reports). Every response explicitly presents verified citations, publishing institution dates, dataset age in days, and clear indicators when evidence is unavailable.

---

## Aim & Core Objectives

1. **District-Grounded Advisory**: Eliminate speculative advice by grounding responses in district-specific soil chemistry, climate zones, and crop seasons (e.g., Thanjavur Cauvery Delta clay soils, Coimbatore black cotton Vertisols, Ramanathapuram coastal drylands).
2. **Authoritative Citation & Record Freshness**: Present every cited document with its publishing institution, release date, dataset age in days, and confidence score.
3. **Interactive Context Clarification**: Automatically detect missing field parameters (e.g., soil drainage or irrigation system) and prompt farmers for clarification before issuing recommendations.
4. **Data Staleness & Ungrounded Alerts**: Explicitly notify users when extension data for a given crop or timeframe is missing or older than 180 days, refusing to fabricate speculative answers.
5. **Mobile Voice & Hands-Free Interaction**: Support field farmers with hands-free Speech-to-Text (STT) query input and Text-to-Speech (TTS) response readout.
6. **On-Device Translation with Scientific Protection**: Deliver instant localized text output while preserving vital agricultural numeric metrics (dosages like `0.6 g/L`, `50 kg/ha`, active chemical names, and rule IDs like `RULE-TNAU-BLAST-01`) through token masking.
7. **Low-Bandwidth & Rural Field Accessibility**: Support compressed 2G SMS query packet transmission (1.1 KB payload) and offline queueing for remote farmland connectivity.
8. **Native Bilingual Support**: Complete localized interface in **English** and **Tamil (தமிழ்)** across all navigation, forms, evidence drawers, and alerts.

---

## Key System Features

- **Grounded Agricultural Advisory Engine**: Delivers actionable advice on pest management, disease treatment, fertilizer application, and irrigation schedules backed by university citations.
- **Mobile Speech & Accessibility Layer**: Real-time microphone voice input (`SpeechToTextService`) and voice readout (`TextToSpeechService`) tailored for farmers in the field.
- **Agricultural Numeric Protection Engine**: On-device machine translation (`TranslationService`) using Google ML Kit with custom regex token masking to ensure chemical dosages, application rates, and rule IDs are never corrupted during translation.
- **Evidence Source Inspector**: Expandable drawer detailing cited bulletins, authoring bodies (TNAU, ICAR, TRRI), publication dates, excerpt quotes, and verification badges.
- **Scientific Field Telemetry**: Real-time readouts of field sensor metrics, including soil moisture %, temperature °C, relative humidity %, Nitrogen NPK ppm, and soil pH levels.
- **District Scope & Agro-Climatic Selector**: Explore soil profiles, dominant crop seasons, geo-coordinates, and active meteorological/pest alerts across districts.
- **Low-Bandwidth / 2G SMS Channel**: Compress complex queries into lightweight 1.1 KB SMS payloads with store-and-forward offline sync status.
- **Portal Access Control**: Dual access modes for Farmers and Agricultural Extension Officers / Admins to inspect regional query telemetry and research freshness audits.
- **Editorial Soil & Field Design System**: Cinematic aesthetic featuring the custom **RagUzhavan** emblem, soil, straw, field leaf, and paper tones paired with **Footlight MT Light** display typography.

---

## Tech Stack & Architecture

### Core Technologies
- **Framework**: [Flutter](https://flutter.dev) (Dart 3.10+, Material 3)
- **State Management**: [Provider](https://pub.dev/packages/provider) with clean reactive Notifiers (`AuthService`, `LocaleNotifier`)
- **Navigation & Routing**: [GoRouter](https://pub.dev/packages/go_router) with role-based auth guards (`/farmer/*`, `/admin/*`)
- **HTTP Client**: [Dio](https://pub.dev/packages/dio) with interceptors and configurable base URL
- **Speech & Audio**: `speech_to_text` (Mobile STT) & `flutter_tts` (Mobile TTS)
- **On-Device ML**: `google_mlkit_translation` (On-device neural translation)
- **Localization**: Flutter `flutter_localizations` & `intl` supporting English (`en`) and Tamil (`ta`)

### Architectural Blueprint

```
lib/
├── core/
│   ├── config/          # AppConfig with single API_BASE_URL entry point
│   ├── localization/    # AppLocalizations & LocaleNotifier (EN & TA)
│   ├── routing/         # AppRouter & GoRouter auth guards
│   ├── services/        # SpeechToTextService, TextToSpeechService, TranslationService
│   ├── theme/           # AppColors (soil/field palette) & AppTheme (Footlight font)
│   └── utils/           # DateFormatter & dataset age formatters
├── data/
│   ├── models/          # Farmer, Region, CropContext, RagQuery, RagResponse, EvidenceSource, LowBandwidthMessage, FieldSensorData
│   ├── repositories/    # RagRepository interface, MockRagRepository, ApiRagRepository
│   └── services/        # DioClient wrapper & AuthService
├── features/
│   ├── admin/           # Admin telemetry dashboard & registered farmer directory
│   ├── auth/            # Portal login & farmer registration
│   ├── farmer/          # Farmer dashboard, ask query, grounded response, region selector, low-bandwidth mode, settings
│   └── landing/         # Cinematic editorial hero & scenario inspector
└── shared/
    ├── animations/      # Editorial motion primitives (EditorialSlideUp, UnfoldCard, PulseIndicator)
    └── widgets/         # EditorialHeader, FieldNotebookCard, ScientificTelemetryBar, EvidenceDrawer, LanguageSelector, EditorialNavBar
```

### Decoupled Repository Pattern & Backend Readiness

The application UI relies strictly on the abstract `RagRepository` interface:

```dart
abstract class RagRepository {
  Future<RagResponse> askQuestion(RagQuery query);
  Future<RagResponse> fetchPresetScenarioResponse(String scenarioKey, {String language = 'en'});
  Future<List<Region>> fetchSupportedRegions();
  Future<FieldSensorData> fetchFieldSensorData(String regionId);
  Future<LowBandwidthMessage> sendLowBandwidthQuery(RagQuery query);
  Future<List<Farmer>> fetchFarmersList();
}
```

- **Mock Mode (Autonomous Frontend)**: Uses `MockRagRepository` to provide realistic agricultural data for Thanjavur, Coimbatore, Ramanathapuram, and Madurai districts.
- **Production Mode**: Uses `ApiRagRepository` powered by `DioClient`. Changing `API_BASE_URL` at compile time or runtime seamlessly connects the frontend to the Railway RAG backend service.

---

## Design System & Typography

- **Editorial Display Font**: **Footlight MT Light** (`assets/fonts/FootlightMTLight.otf`) used for all primary headers, screen titles, and section titles.
- **App Emblem**: Custom **RagUzhavan** emblem (`assets/images/logo.png`) embedded across headers, landing pages, and authentication screens.
- **UI & Metadata Font**: High-readability sans-serif for body text, sensor readouts, and metadata tables.
- **Restrained Color Palette**:
  - `Background`: `#0B0B09` (Rich Soil Night)
  - `Surface`: `#12110E` (Notebook Card)
  - `Earth`: `#4A3A2A` (Organic Earth Brown)
  - `Field`: `#71835B` (Muted Crop Green)
  - `Leaf`: `#A8B58C` (Sage Leaf Highlight)
  - `Straw`: `#C7A86B` (Harvest Wheat Gold)
  - `Paper`: `#E8E1D3` (Editorial Paper)
  - `Foreground`: `#F4F1E8` (High-Contrast Off-White)

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.19.0 or higher)
- [Dart SDK](https://dart.dev/get-started/sdk) (v3.10.4 or higher)

### Installation & Execution

1. **Clone the repository**:
   ```bash
   git clone https://github.com/NoelNinanSheri1307/RagUzhavanApp.git
   cd RagUzhavanApp
   ```

2. **Fetch Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run Static Analysis & Automated Unit Tests**:
   ```bash
   flutter analyze
   flutter test
   ```

4. **Launch Application**:
   ```bash
   # Autonomous Frontend Mode (Default Mock Repository)
   flutter run

   # Configured for Remote Railway Backend
   flutter run --dart-define=API_BASE_URL=https://raguzhavan-backend.up.railway.app
   ```

---

## License

This project is developed for hackathon and agricultural technology demonstration purposes.
