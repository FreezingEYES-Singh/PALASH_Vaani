import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SpeechService {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setLanguage('hi-IN');
      await _flutterTts.setSpeechRate(0.45); // Slower, child-friendly pace
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.05); // Friendly pitch for primary classroom
      _isInitialized = true;
    } catch (e) {
      debugPrint('SpeechService init error: $e');
    }
  }

  /// Speaks text using the TTS engine
  /// For Santhali/Tribal, we use phonetic Devanagari or phonemic speech synthesis
  static Future<void> speakText(String textToSpeak, {String lang = 'hi-IN'}) async {
    try {
      if (!_isInitialized) await initialize();
      await _flutterTts.stop();
      await _flutterTts.setLanguage(lang);
      await _flutterTts.speak(textToSpeak);
    } catch (e) {
      debugPrint('Error speaking text: $e');
    }
  }

  static Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('Error stopping TTS: $e');
    }
  }
}
