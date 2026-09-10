import 'package:flutter/foundation.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

abstract class TranslationService {
  Future<String> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    Function(String error)? onError,
  });
  Future<bool> isModelDownloaded(String languageCode);
  Future<bool> downloadModel(String languageCode);
}

class AppTranslationService implements TranslationService {
  final Map<String, OnDeviceTranslator> _translators = {};

  TranslateLanguage _getLanguage(String code) {
    if (code.toLowerCase() == 'ta') {
      return TranslateLanguage.tamil;
    }
    return TranslateLanguage.english;
  }

  @override
  Future<bool> isModelDownloaded(String languageCode) async {
    if (kIsWeb) return false;
    try {
      final modelManager = OnDeviceTranslatorModelManager();
      final lang = _getLanguage(languageCode);
      return await modelManager.isModelDownloaded(lang.bcpCode);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> downloadModel(String languageCode) async {
    if (kIsWeb) return false;
    try {
      final modelManager = OnDeviceTranslatorModelManager();
      final lang = _getLanguage(languageCode);
      return await modelManager.downloadModel(lang.bcpCode);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    Function(String error)? onError,
  }) async {
    if (sourceLanguage == targetLanguage || text.trim().isEmpty) {
      return text;
    }

    if (kIsWeb) {
      if (onError != null) {
        onError('On-device translation model unavailable on web platform.');
      }
      return text;
    }

    // Protection of Agricultural Numeric Information & Structured Identifiers
    final Map<String, String> protectedTokens = {};
    int tokenCounter = 0;

    String maskedText = text;

    // Pattern 1: Numerical dosages and formulas e.g. 0.6 g/L, 50 kg/ha, 75% WP, 2.5 L/ha, 4.5 Acres
    final dosageRegex = RegExp(r'\b\d+(\.\d+)?\s*(g/L|kg/ha|kg|g|mg|L|ml|%|WP|EC|SC|SG|cm|m|mm|ha|acres)\b', caseSensitive: false);
    maskedText = maskedText.replaceAllMapped(dosageRegex, (match) {
      final key = '___AGRI_DOSAGE_${tokenCounter++}___';
      protectedTokens[key] = match.group(0)!;
      return key;
    });

    // Pattern 2: Deterministic Rule IDs e.g. RULE-TNAU-BLAST-01, RULE-ICAR-COTTON-04
    final ruleRegex = RegExp(r'\b(RULE|TNAU|ICAR|AGRI)-[A-Z0-9-]+\b');
    maskedText = maskedText.replaceAllMapped(ruleRegex, (match) {
      final key = '___AGRI_RULE_${tokenCounter++}___';
      protectedTokens[key] = match.group(0)!;
      return key;
    });

    // Pattern 3: Chemical and biological names e.g. Tricyclazole, Hexaconazole, Carbendazim, Pseudomonas
    final chemicalRegex = RegExp(r'\b(Tricyclazole|Hexaconazole|Carbendazim|Pseudomonas|Azospirillum|Bacillus)\b', caseSensitive: false);
    maskedText = maskedText.replaceAllMapped(chemicalRegex, (match) {
      final key = '___AGRI_CHEM_${tokenCounter++}___';
      protectedTokens[key] = match.group(0)!;
      return key;
    });

    try {
      final key = '${sourceLanguage}_$targetLanguage';
      if (!_translators.containsKey(key)) {
        _translators[key] = OnDeviceTranslator(
          sourceLanguage: _getLanguage(sourceLanguage),
          targetLanguage: _getLanguage(targetLanguage),
        );
      }

      final translator = _translators[key]!;
      String translated = await translator.translateText(maskedText);

      // Restore protected agricultural tokens
      protectedTokens.forEach((placeholder, originalValue) {
        translated = translated.replaceAll(placeholder, originalValue);
      });

      return translated;
    } catch (e) {
      if (onError != null) {
        onError('Translation model error: ${e.toString()}');
      }
      return text;
    }
  }

  void close() {
    for (final translator in _translators.values) {
      translator.close();
    }
    _translators.clear();
  }
}
