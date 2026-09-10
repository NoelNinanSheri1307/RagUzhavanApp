import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

abstract class SpeechToTextService {
  Future<bool> initialize();
  bool get isAvailable;
  bool get isListening;
  String get lastRecognizedText;
  Future<void> startListening({
    required String languageCode,
    required Function(String text) onResult,
    required Function(String error) onError,
  });
  Future<void> stopListening();
}

class AppSpeechToTextService implements SpeechToTextService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;
  bool _isListening = false;
  String _lastRecognizedText = '';

  @override
  bool get isAvailable => _isAvailable;

  @override
  bool get isListening => _isListening;

  @override
  String get lastRecognizedText => _lastRecognizedText;

  @override
  Future<bool> initialize() async {
    if (kIsWeb) {
      _isAvailable = false;
      return false;
    }
    try {
      _isAvailable = await _speech.initialize(
        onError: (val) {
          _isListening = false;
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
          }
        },
      );
      return _isAvailable;
    } catch (e) {
      _isAvailable = false;
      return false;
    }
  }

  @override
  Future<void> startListening({
    required String languageCode,
    required Function(String text) onResult,
    required Function(String error) onError,
  }) async {
    if (!_isAvailable) {
      final initialized = await initialize();
      if (!initialized) {
        onError('Speech recognition is unavailable on this device.');
        return;
      }
    }

    final localeId = languageCode == 'ta' ? 'ta_IN' : 'en_US';

    try {
      _isListening = true;
      _lastRecognizedText = '';
      await _speech.listen(
        onResult: (result) {
          _lastRecognizedText = result.recognizedWords;
          onResult(result.recognizedWords);
          if (result.finalResult) {
            _isListening = false;
          }
        },
        listenOptions: stt.SpeechListenOptions(
          localeId: localeId,
          cancelOnError: true,
          listenMode: stt.ListenMode.dictation,
        ),
      );
    } catch (e) {
      _isListening = false;
      onError('Unable to start speech recognition: ${e.toString()}');
    }
  }

  @override
  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
  }
}
