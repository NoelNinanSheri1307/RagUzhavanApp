import 'package:flutter/material.dart';

class LocaleNotifier extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;

  void setLocale(Locale newLocale) {
    if (_locale == newLocale) return;
    _locale = newLocale;
    notifyListeners();
  }

  void toggleLanguage() {
    if (_locale.languageCode == 'en') {
      setLocale(const Locale('ta'));
    } else {
      setLocale(const Locale('en'));
    }
  }
}
