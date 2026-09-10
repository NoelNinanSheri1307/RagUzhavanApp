import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rag_uzhavan/core/localization/app_localizations.dart';

void main() {
  group('AppLocalizations Tests', () {
    test('English localizations return correct string values for new response sections', () {
      final l10n = AppLocalizations(const Locale('en'));
      expect(l10n.text('appName'), equals('RagUzhavan'));
      expect(l10n.text('blockContext'), equals('Block'));
      expect(l10n.text('secRecommendation'), equals('RECOMMENDATION'));
      expect(l10n.text('statusNoData'), equals('NO CURRENT DATA AVAILABLE FOR YOUR BLOCK'));
      expect(l10n.text('publicSourcesTitle'), equals('PUBLIC AGRICULTURAL DATASETS SYNTHESIZED'));
    });

    test('Tamil localizations return correct Tamil string values', () {
      final l10n = AppLocalizations(const Locale('ta'));
      expect(l10n.text('appName'), equals('ரக் உழவன்'));
      expect(l10n.text('blockContext'), equals('வட்டாரம் / ஒன்றியம்'));
      expect(l10n.text('secRecommendation'), equals('முதன்மைப் பரிந்துரை'));
      expect(l10n.text('statusNoData'), equals('தங்களின் வட்டாரத்திற்குரிய தற்போதைய தரவு இல்லை'));
    });
  });
}
