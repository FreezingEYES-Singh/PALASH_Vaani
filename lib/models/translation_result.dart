import 'curriculum_item.dart';

enum TargetTribalLanguage {
  santhali,
  mundari,
  ho,
}

class TranslationResult {
  final String sourceText;
  final String sourceLang; // 'Hindi' or 'Tribal'
  final TargetTribalLanguage targetLang;
  final String nativeScriptText; // Ol Chiki for Santhali, Warang Chiti/Deva for Ho/Mundari
  final String phoneticDevanagari; // Teacher pronunciation guide
  final String latinPhonetic;
  final String englishMeaning;
  final bool isFastPathCacheHit;
  final ConfidenceTier confidenceTier;
  final double confidenceScore; // e.g., 0.96
  final int asrLatencyMs;
  final int mtLatencyMs;
  final int ttsLatencyMs;
  final int totalLatencyMs;
  final DateTime timestamp;
  final String? audioPath;

  const TranslationResult({
    required this.sourceText,
    required this.sourceLang,
    required this.targetLang,
    required this.nativeScriptText,
    required this.phoneticDevanagari,
    required this.latinPhonetic,
    required this.englishMeaning,
    required this.isFastPathCacheHit,
    required this.confidenceTier,
    required this.confidenceScore,
    required this.asrLatencyMs,
    required this.mtLatencyMs,
    required this.ttsLatencyMs,
    required this.totalLatencyMs,
    required this.timestamp,
    this.audioPath,
  });

  bool get isSub3Seconds => totalLatencyMs <= 3000;
}
