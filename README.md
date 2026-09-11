# RagUzhavan (ரக் உழவன்)

> **Region-Aware Agricultural Intelligence System**  
> Solves agricultural data fragmentation by unifying ICAR scientific advisories, university research bulletins, Agmarknet mandi prices, and soil telemetry datasets with zero speculative hallucinations.

---

## Executive Overview

**RagUzhavan** is a mobile and cross-platform agricultural intelligence application designed to deliver precise, time-sensitive farming advice tailored to specific districts, soil types, crop growth stages, and agricultural seasons across India.

Traditional AI assistants often provide generic or hallucinated farming recommendations that fail to account for local agro-climatic conditions or regional pest outbreaks. **RagUzhavan** addresses this critical gap by extracting, organizing, and unifying knowledge across isolated agricultural datasets (ICAR bulletins, TNAU advisories, Agmarknet price boards, and field telemetry). Every response explicitly presents verified citations, publishing institution dates, dataset age in days, and clear indicators when evidence is unavailable.

---

## Aim & Core Objectives

1. **Solving Data Fragmentation**: Extract and unify data across multiple agricultural datasets (ICAR, TNAU, Agmarknet, weather forecasts, and soil telemetry) to deliver grounded advice to farmers.
2. **Authoritative Citation & Record Freshness**: Present every cited document with its publishing institution, release date, dataset age in days, and confidence score.
3. **Mobile Voice & Hands-Free Interaction**: Support field farmers with one-tap Speech-to-Text (STT) query input and Text-to-Speech (TTS) response readout.
4. **On-Device Translation with Scientific Protection**: Deliver instant localized text output in English and Tamil (தமிழ்) while preserving vital agricultural numeric metrics (dosages like `0.6 g/L`, `25 kg/acre`, price quotes `₹2,320/q`, and rule IDs like `RULE-TNAU-BLAST-01`) through token masking.
5. **Extension Officer Control & Admin Ingestion**: Provide dedicated admin workflows for agricultural officers to inspect knowledge graph node connections, monitor daily query telemetry, toggle scientific guardrails, and ingest/manage research bulletins in the ChromaDB vector database.
6. **Low-Bandwidth & Rural Field Accessibility**: Support lightweight query payloads and offline queueing (`Hive` local storage) for remote farmland connectivity.
7. **Native Bilingual Support**: Complete localized interface in **English** and **Tamil (தமிழ்)** across all navigation, forms, evidence drawers, and alerts.

---

## Key System Features

- **Grounded Agricultural Advisory Engine**: Delivers actionable advice on pest management, disease treatment, fertilizer application, and irrigation schedules backed by university citations.
- **Mobile Speech & Accessibility Layer**: Real-time microphone voice input (`SpeechToTextService`) and voice readout (`TextToSpeechService`) tailored for farmers in the field.
- **Agricultural Numeric Protection Engine**: On-device machine translation (`TranslationService`) using Google ML Kit with custom regex token masking to ensure chemical dosages, application rates, and rule IDs are never corrupted during translation.
- **Admin Knowledge Graph & Document Ingestion**: Extension officer portal for document ingestion, knowledge graph visualization, and guardrail verification.
- **Evidence Source Inspector**: Expandable drawer detailing cited bulletins, authoring bodies (TNAU, ICAR, TRRI), publication dates, excerpt quotes, and verification badges.
- **Scientific Field Telemetry**: Real-time readouts of field sensor metrics, including soil moisture %, temperature °C, relative humidity %, Nitrogen NPK ppm, and soil pH levels.
- **District Scope & Agro-Climatic Selector**: Explore soil profiles, dominant crop seasons, geo-coordinates, and active meteorological/pest alerts across districts.
- **Low-Bandwidth / Store-and-Forward Sync**: Lightweight query payloads with store-and-forward offline sync status.
- **Editorial Soil & Field Design System**: Cinematic aesthetic featuring warm soil, straw, field leaf, and parchment tones paired with **Footlight MT Light** display typography.

---

## Showcase Web Presentation

The repository includes a dedicated standalone presentation website in `app_present/index.html` showcasing:
- High-resolution iPhone 15 Pro device mockups featuring actual app screenshots.
- Direct download link for the standalone Android APK (`app_present/raguzhavan.apk`).
- Interactive feature walk-throughs for Farmers and Extension Officers.

---

## Tech Stack & Architecture

### Core Technologies
- **Framework**: [Flutter](https://flutter.dev) (Dart 3.10+, Material 3)
- **State Management**: [Provider](https://pub.dev/packages/provider) with clean reactive Notifiers (`AuthService`, `LocaleNotifier`)
- **Navigation & Routing**: [GoRouter](https://pub.dev/packages/go_router) with role-based auth guards (`/farmer/*`, `/admin/*`)
- **HTTP Client**: [Dio](https://pub.dev/packages/dio) with interceptors and configurable base URL
- **Speech & Audio**: `speech_to_text` (Mobile STT) & `flutter_tts` (Mobile TTS)
- **On-Device ML**: `google_mlkit_translation` (On-device neural translation with numeric protection)
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
│   ├── admin/           # Admin telemetry dashboard, knowledge graph, document ingestion & registered farmer directory
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
```

- **Local Mode (Localized Repository)**: Uses `MockRagRepository` to provide deterministic local responses backed by TNAU/ICAR datasets.
- **Production Mode (Live Railway Hub)**: Uses `ApiRagRepository` connected directly to `https://backend-production-e510.up.railway.app`.

### Backend API Integration Map (FastAPI on Railway)

| Feature | HTTP Method | Endpoint | Purpose |
| :--- | :--- | :--- | :--- |
| **Authentication** | `POST` | `/token` | OAuth2 form-urlencoded authentication token generation |
| **Registration** | `POST` | `/register` | User profile registration |
| **User Profile** | `GET / PATCH` | `/users/me` | Fetch & update current user profile (name, phone, district, crop) |
| **Chat Sessions** | `GET / POST` | `/sessions` | List active sessions or instantiate new session |
| **Session Messages**| `GET` | `/sessions/{id}/messages` | Retrieve session message history with reasoning & cited sources |
| **RAG Query** | `POST` | `/sessions/{id}/ask` | Submit agricultural query to vector search pipeline |
| **Knowledge Graph** | `GET` | `/sources/graph` | Fetch graph nodes & relationships for visual interactive map |
| **Sources Corpus** | `GET / DELETE` | `/sources`, `/sources/{id}` | Manage ingested vector store document corpus |
| **System Settings** | `GET / PATCH` | `/admin/settings` | Audit & toggle retrieval guardrails and evidence policy |

---

## Design System & Typography

- **Editorial Display Font**: **Footlight MT Light** (`assets/fonts/FootlightMTLight.otf`) used for all primary headers, screen titles, and section titles.
- **UI & Metadata Font**: High-readability sans-serif for body text, sensor readouts, and metadata tables.
- **Restrained Color Palette**:
  - `Background`: `#231812` (Rich Dark Soil)
  - `Surface`: `#322219` (Moist Loam Earth)
  - `Field`: `#2E7D32` (Deep Crop Green)
  - `Leaf`: `#4CAF50` (Sprout Green)
  - `Straw`: `#D97706` (Harvest Gold Amber)
  - `Paper`: `#FFF8E7` (Cream Parchment)
  - `Foreground`: `#FFF8E7` (High-Contrast Text)

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
   # Local Mode
   flutter run

   # Configured for Remote Railway Production Backend
   flutter run --dart-define=API_BASE_URL=https://backend-production-e510.up.railway.app
   ```

---

## License

This project is developed for hackathon and agricultural technology demonstration purposes.
