import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rag_uzhavan/core/localization/app_localizations.dart';

void main() {
  group('AppLocalizations Tests', () {
    test('English localizations return correct string values', () {
      final l10n = AppLocalizations(const Locale('en'));
      expect(l10n.text('appName'), equals('RagUzhavan'));
      expect(l10n.text('districtContext'), equals('District Context'));
      expect(l10n.text('statusGrounded'), equals('VERIFIED GROUNDED EVIDENCE'));
    });

    test('Tamil localizations return correct Tamil string values', () {
      final l10n = AppLocalizations(const Locale('ta'));
      expect(l10n.text('appName'), equals('ரக் உழவன்'));
      expect(l10n.text('districtContext'), equals('மாவட்டச் சூழல்'));
      expect(l10n.text('statusGrounded'), equals('உறுதிசெய்யப்பட்ட ஆதாரப் பதில்'));
    });
  });
}
