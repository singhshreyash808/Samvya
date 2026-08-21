import 'dart:ui';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceAssistantService {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _speechEnabled = false;

  Future<void> init() async {
    _speechEnabled = await _speechToText.initialize();
  }

  Future<void> speak(String text, {String languageCode = 'en-US'}) async {
    await _flutterTts.setLanguage(languageCode);
    await _flutterTts.speak(text);
  }

  static String getLanguageCode(Locale locale) {
    switch (locale.languageCode) {
      case 'hi':
        return 'hi-IN';
      case 'or':
        return 'or-IN';
      case 'ta':
        return 'ta-IN';
      default:
        return 'en-US';
    }
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }

  Future<void> startListening(Function(String) onResult) async {
    if (!_speechEnabled) {
      await init();
    }
    // Need to wait briefly if just initialized, but usually it's fine.
    await _speechToText.listen(onResult: (result) {
      onResult(result.recognizedWords);
    });
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  bool get isListening => _speechToText.isListening;
}
