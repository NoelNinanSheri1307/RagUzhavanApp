# RagUzhavan API Contracts Specification

This document details the expected REST API contracts for integration between the RagUzhavan Flutter frontend application and the backend RAG pipeline (hosted on Railway or local development environments).

---

## Configuration & Fallback Rules

1. **Environment Flag**: `API_BASE_URL` (configurable via `ApiService` / `AppConfig`).
2. **Prototype / Mock Fallback**: When `API_BASE_URL` is empty, empty string, or unreachable:
   - The application automatically falls back to local `MockRagRepository` and `MockAuthRepository`.
   - UI widgets display clear provenance and mock status indicators (e.g. `[DEMO DATA - FALLBACK ACTIVE]`).
   - Network errors do not break the UI.
3. **Remote Execution**: When `API_BASE_URL` is configured (e.g., `https://api.raguzhavan.org/v1`), `ApiService` routes requests via Dio. If a remote call fails:
   - The app presents a clear error state.
   - Stale or fabricated data is **never** silently presented as current backend data.

---

## 1. Authentication Endpoints

### `POST /auth/login`
Authenticates a user (Farmer or Admin) with role credentials.

**Request Payload:**
```json
{
  "username": "9876543210",
  "password": "user_password",
  "role": "farmer" // "farmer" | "admin"
}
```

**Response Payload (200 OK):**
```json
{
  "token": "jwt-token-string",
  "role": "farmer",
  "farmer": {
    "id": "FARM-101",
    "name": "Muthusamy K.",
    "phone": "+91 98765 43210",
    "district": "Thanjavur",
    "block": "Budalur",
    "state": "Tamil Nadu",
    "preferredLanguage": "ta",
    "crops": ["Paddy / Rice", "Pulses"],
    "landSizeAcres": 3.5,
    "agroZone": "Cauvery Delta Zone",
    "season": "Kuruvai",
    "accountStatus": "Active",
    "lastActivity": "2026-09-10T11:45:00.000Z"
  }
}
```

---

### `POST /auth/register`
Registers a new farmer in the system.

**Request Payload:**
```json
{
  "name": "Muthusamy K.",
  "phone": "+91 98765 43210",
  "district": "Thanjavur",
  "block": "Budalur",
  "state": "Tamil Nadu",
  "preferredLanguage": "ta",
  "crops": ["Paddy / Rice"],
  "landSizeAcres": 3.5,
  "agroZone": "Cauvery Delta Zone",
  "season": "Kuruvai"
}
```

**Response Payload (201 Created):**
```json
{
  "id": "FARM-101",
  "message": "Farmer registration successful",
  "accountStatus": "Active"
}
```

---

## 2. Region & District Metadata Endpoint

### `GET /regions`
Returns state, district, and block hierarchy data along with agro-climatic zones.

**Response Payload (200 OK):**
```json
{
  "states": [
    {
      "name": "Tamil Nadu",
      "districts": [
        {
          "name": "Thanjavur",
          "blocks": ["Budalur", "Kumbakonam", "Orathanadu", "Papanasam", "Pattukkottai", "Thanjavur", "Thiruvaiyaru", "Thiruvonam"],
          "agroZone": "Cauvery Delta Zone"
        }
      ]
    }
  ]
}
```

---

## 3. RAG Intelligence Endpoints

### `POST /rag/query`
Submits a regional agricultural query to the RAG engine.

**Request Payload:**
```json
{
  "query": "White spots on paddy leaves during tillering stage",
  "location": "Budalur, Thanjavur, Tamil Nadu",
  "district": "Thanjavur",
  "block": "Budalur",
  "crop": "Paddy / Rice",
  "growthStage": "Tillering",
  "season": "Kuruvai",
  "language": "en"
}
```

**Response Payload (200 OK):**
```json
{
  "id": "RESP-8921",
  "queryId": "Q-104",
  "responseText": "Symptoms indicate Blast (Pyricularia oryzae). Apply Tricyclazole 75% WP at 0.6 g/L water.",
  "responseTextTamil": "இலைக்கருகல் நோய் அறிகுறிகள் தென்படுகின்றன. டிரைசைக்ளசோல் 75% WP மருந்தினை 0.6 கிராம்/லிட்டர் தண்ணீரில் கலந்து தெளிக்கவும்.",
  "recommendationSummary": "Fungicidal spray recommended for Leaf Blast outbreak.",
  "recommendationSummaryTamil": "இலைக்கருகல் நோய்க்கு பூஞ்சானக்கொல்லி தெளிப்பு பரிந்துரைக்கப்படுகிறது.",
  "whatToDo": "Spray Tricyclazole 75% WP",
  "whatToDoTamil": "டிரைசைக்ளசோல் 75% WP தெளிக்கவும்",
  "whenToApply": "Early morning or late evening within 48 hours",
  "whenToApplyTamil": "48 மணி நேரத்திற்குள் அதிகாலை அல்லது மாலையில்",
  "howMuchAmount": "0.6 g per Liter of water (200 L water per acre)",
  "howMuchAmountTamil": "0.6 கிராம்/லிட்டர் தண்ணீர் (ஏக்கருக்கு 200 லிட்டர் தண்ணீர்)",
  "whyReason": "High humidity (>78%) and warm temperatures favor conidia germination.",
  "whyReasonTamil": "அதிக ஈரப்பதம் மற்றும் வெப்பம் நோய் பரவலுக்கு ஏதுவாக உள்ளது.",
  "groundingScore": 0.94,
  "ruleId": "RULE-TNAU-BLAST-01",
  "citedProvenance": "TNAU Crop Production Guide 2025 (Paddy, p. 142)",
  "numericRecommendations": [
    {
      "parameter": "Fungicide Dosage",
      "value": 0.6,
      "unit": "g/L",
      "ruleId": "RULE-TNAU-BLAST-01",
      "sourceTitle": "TNAU Crop Production Guide 2025",
      "publicationDate": "2025-01-15",
      "retrievedDate": "2026-09-08",
      "region": "Thanjavur Delta",
      "cropApplicability": "Paddy / Rice"
    }
  ],
  "language": "en",
  "isGrounded": true,
  "evidenceSources": [
    {
      "id": "SRC-TNAU-2025",
      "title": "TNAU Advisory Bulletin - Rice Blast Management in Delta Zone",
      "publicationDate": "2025-01-15",
      "retrievedDate": "2026-09-08",
      "region": "Thanjavur Delta",
      "cropApplicability": "Paddy / Rice",
      "authorOrInstitute": "Tamil Nadu Agricultural University (TNAU)",
      "documentType": "Official Advisory",
      "excerpt": "For leaf blast control in Kuruvai paddy, apply Tricyclazole 75% WP @ 0.6 g/L.",
      "excerptTamil": "குருவை நெல் பயிரில் இலைக்கருகல் நோயைக் கட்டுப்படுத்த டிரைசைக்ளசோல் தெளிக்கவும்.",
      "confidenceScore": 0.96,
      "datasetAgeDays": 12,
      "urlOrRef": "https://tnau.ac.in/advisories/blast-2025.pdf",
      "isVerified": true
    }
  ],
  "clarificationQuestions": [],
  "timestamp": "2026-09-10T12:00:00.000Z",
  "status": "grounded",
  "stateName": "Tamil Nadu",
  "districtName": "Thanjavur",
  "blockName": "Budalur",
  "cropName": "Paddy / Rice",
  "growthStage": "Tillering",
  "season": "Kuruvai",
  "averageDataAgeDays": 12
}
```

---

### `GET /rag/evidence?id={evidenceId}`
Retrieves detailed metadata for a specific evidence source.

**Response Payload (200 OK):**
```json
{
  "id": "SRC-TNAU-2025",
  "title": "TNAU Advisory Bulletin - Rice Blast Management in Delta Zone",
  "publicationDate": "2025-01-15",
  "retrievedDate": "2026-09-08",
  "region": "Thanjavur Delta",
  "cropApplicability": "Paddy / Rice",
  "authorOrInstitute": "Tamil Nadu Agricultural University (TNAU)",
  "documentType": "Official Advisory",
  "excerpt": "For leaf blast control in Kuruvai paddy, apply Tricyclazole 75% WP @ 0.6 g/L.",
  "excerptTamil": "குருவை நெல் பயிரில் இலைக்கருகல் நோயைக் கட்டுப்படுத்த டிரைசைக்ளசோல் தெளிக்கவும்.",
  "confidenceScore": 0.96,
  "datasetAgeDays": 12,
  "urlOrRef": "https://tnau.ac.in/advisories/blast-2025.pdf",
  "isVerified": true
}
```

---

## 4. Messaging Endpoint (Low-Bandwidth / SMS Simulator)

### `GET /messages`
Retrieves compressed low-bandwidth messages for offline or feature-phone farmers.

**Response Payload (200 OK):**
```json
[
  {
    "id": "MSG-001",
    "querySnippet": "Blast on Kuruvai Paddy",
    "compactAdvice": "Spray Tricyclazole 75WP @ 0.6g/L within 48 hrs.",
    "compactAdviceTamil": "டிரைசைக்ளசோல் 75WP 0.6கி/லி தெளிக்கவும்.",
    "district": "Thanjavur",
    "crop": "Paddy / Rice",
    "timestamp": "2026-09-10T10:30:00.000Z",
    "payloadSizeBytes": 142,
    "isDeliveredViaSms": true
  }
]
```

---

## 5. Admin & Farmer Management Endpoint

### `GET /farmers`
Returns the list of registered farmers for administrative inspection. Supports filtering query parameters: `district`, `crop`, `status`.

**Query Parameters:**
- `district`: (optional) e.g., `Thanjavur`
- `crop`: (optional) e.g., `Paddy / Rice`
- `status`: (optional) e.g., `Active` | `Pending Review` | `Flagged`

**Response Payload (200 OK):**
```json
[
  {
    "id": "FARM-101",
    "name": "Muthusamy K.",
    "phone": "+91 98765 43210",
    "district": "Thanjavur",
    "block": "Budalur",
    "state": "Tamil Nadu",
    "preferredLanguage": "ta",
    "crops": ["Paddy / Rice", "Pulses"],
    "landSizeAcres": 3.5,
    "agroZone": "Cauvery Delta Zone",
    "season": "Kuruvai",
    "accountStatus": "Active",
    "lastActivity": "2026-09-10T11:45:00.000Z"
  },
  {
    "id": "FARM-102",
    "name": "Selvaraj P.",
    "phone": "+91 94431 89012",
    "district": "Thanjavur",
    "block": "Thiruvaiyaru",
    "state": "Tamil Nadu",
    "preferredLanguage": "ta",
    "crops": ["Paddy / Rice", "Sugarcane"],
    "landSizeAcres": 5.0,
    "agroZone": "Cauvery Delta Zone",
    "season": "Samba",
    "accountStatus": "Pending Review",
    "lastActivity": "2026-09-09T16:20:00.000Z"
  }
]
```
