import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

abstract class TextToSpeechService {
  Future<void> initialize();
  Future<void> speak(String text, {required String languageCode, Function(String error)? onError});
  Future<void> stop();
  bool get isSpeaking;
}

class AppTextToSpeechService implements TextToSpeechService {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  bool _isInitialized = false;

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      _tts.setStartHandler(() {
        _isSpeaking = true;
      });
      _tts.setCompletionHandler(() {
        _isSpeaking = false;
      });
      _tts.setErrorHandler((msg) {
        _isSpeaking = false;
      });
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
    }
  }

  @override
  Future<void> speak(String text, {required String languageCode, Function(String error)? onError}) async {
    if (kIsWeb) {
      if (onError != null) {
        onError('Voice output unavailable on web; read the answer below.');
      }
      return;
    }

    await initialize();

    try {
      final voiceLang = languageCode == 'ta' ? 'ta-IN' : 'en-US';
      await _tts.setLanguage(voiceLang);
      await _tts.setSpeechRate(0.45);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _isSpeaking = true;
      final result = await _tts.speak(text);
      if (result == 0 && onError != null) {
        _isSpeaking = false;
        onError('Voice unavailable on this device; read the answer below.');
      }
    } catch (e) {
      _isSpeaking = false;
      if (onError != null) {
        onError('Voice unavailable on this device; read the answer below.');
      }
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
      _isSpeaking = false;
    } catch (e) {
      _isSpeaking = false;
    }
  }
}
