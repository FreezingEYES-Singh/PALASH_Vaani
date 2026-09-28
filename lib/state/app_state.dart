import 'package:flutter/foundation.dart';
import '../models/curriculum_item.dart';
import '../models/feedback_record.dart';
import '../models/translation_result.dart';
import '../services/speech_service.dart';
import '../services/translation_engine.dart';

enum IntercomMode {
  teacherToStudent,
  studentToTeacher,
}

class AppState extends ChangeNotifier {
  TargetTribalLanguage _selectedLanguage = TargetTribalLanguage.santhali;
  GradeLevel _selectedGrade = GradeLevel.class1;
  SubjectArea _selectedSubject = SubjectArea.language;
  IntercomMode _intercomMode = IntercomMode.teacherToStudent;
  
  bool _isOffline = true;
  String _selectedDistrict = 'Dumka (Santhal Pargana)';
  
  bool _isProcessing = false;
  bool _isAudioPlaying = false;
  
  TranslationResult? _latestResult;
  final List<TranslationResult> _translationHistory = [];
  final List<FeedbackRecord> _feedbackList = [];

  // Hardware Profiler metrics
  final int _osReservedRamMb = 1200;
  final int _appActiveRamMb = 385;
  int _lastLatencyMs = 2050;

  // Getters
  TargetTribalLanguage get selectedLanguage => _selectedLanguage;
  GradeLevel get selectedGrade => _selectedGrade;
  SubjectArea get selectedSubject => _selectedSubject;
  IntercomMode get intercomMode => _intercomMode;
  bool get isOffline => _isOffline;
  String get selectedDistrict => _selectedDistrict;
  bool get isProcessing => _isProcessing;
  bool get isAudioPlaying => _isAudioPlaying;
  TranslationResult? get latestResult => _latestResult;
  List<TranslationResult> get translationHistory => List.unmodifiable(_translationHistory);
  List<FeedbackRecord> get feedbackList => List.unmodifiable(_feedbackList);
  int get osReservedRamMb => _osReservedRamMb;
  int get appActiveRamMb => _appActiveRamMb;
  int get lastLatencyMs => _lastLatencyMs;

  AppState() {
    TranslationEngine.initialize();
    SpeechService.initialize();
    _seedInitialHistory();
  }

  void _seedInitialHistory() {
    _latestResult = TranslationResult(
      sourceText: 'बच्चों, अपनी किताबें खोलो',
      sourceLang: 'Hindi',
      targetLang: TargetTribalLanguage.santhali,
      nativeScriptText: 'ᱜᱤᱫᱽᱨᱟᱹ ᱠᱚ, ᱟᱯᱱᱟᱨᱟᱜ ᱯᱩᱛᱷᱤ ᱡᱷᱤᱡᱽ ᱯᱮ',
      phoneticDevanagari: 'गिदरा को, आपनाराग पुथि झिज पे',
      latinPhonetic: 'Gidra ko, aapnaaraag puthi jhij pe',
      englishMeaning: 'Children, open your books',
      isFastPathCacheHit: true,
      confidenceTier: ConfidenceTier.tier1Verified,
      confidenceScore: 0.99,
      asrLatencyMs: 410,
      mtLatencyMs: 24,
      ttsLatencyMs: 620,
      totalLatencyMs: 1054,
      timestamp: DateTime(2026, 9, 27, 10, 0),
    );
    if (_latestResult != null) {
      _translationHistory.add(_latestResult!);
    }
  }

  void setLanguage(TargetTribalLanguage lang) {
    _selectedLanguage = lang;
    notifyListeners();
  }

  void setGrade(GradeLevel grade) {
    _selectedGrade = grade;
    notifyListeners();
  }

  void setSubject(SubjectArea subject) {
    _selectedSubject = subject;
    notifyListeners();
  }

  void setIntercomMode(IntercomMode mode) {
    _intercomMode = mode;
    notifyListeners();
  }

  void toggleOfflineMode() {
    _isOffline = !_isOffline;
    notifyListeners();
  }

  void setDistrict(String district) {
    _selectedDistrict = district;
    notifyListeners();
  }

  /// Execute Teacher Hindi -> Tribal translation
  Future<void> translateTeacherSpeech(String hindiInput) async {
    if (hindiInput.trim().isEmpty) return;
    _isProcessing = true;
    notifyListeners();

    try {
      final result = await TranslationEngine.translate(
        sourceText: hindiInput,
        sourceLang: 'Hindi',
        targetLang: _selectedLanguage,
      );

      _latestResult = result;
      _lastLatencyMs = result.totalLatencyMs;
      _translationHistory.insert(0, result);

      // Trigger native voice output
      await playAudio(result.phoneticDevanagari);
    } catch (e) {
      debugPrint('Translation error: $e');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Execute Student Tribal -> Teacher Hindi translation
  Future<void> translateChildSpeech(String tribalSpeech) async {
    if (tribalSpeech.trim().isEmpty) return;
    _isProcessing = true;
    notifyListeners();

    try {
      final result = TranslationEngine.translateChildToHindi(
        santhaliSpeech: tribalSpeech,
      );

      _latestResult = result;
      _lastLatencyMs = result.totalLatencyMs;
      _translationHistory.insert(0, result);

      await playAudio(result.phoneticDevanagari);
    } catch (e) {
      debugPrint('Child translation error: $e');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// Plays synthesized audio prompt
  Future<void> playAudio(String text) async {
    _isAudioPlaying = true;
    notifyListeners();

    await SpeechService.speakText(text);

    _isAudioPlaying = false;
    notifyListeners();
  }

  /// Adds teacher community feedback for offline sync
  void addFeedback({
    required String sourceHindi,
    required String generatedTribal,
    required String correctedTribal,
    required String teacherNotes,
  }) {
    final record = FeedbackRecord(
      id: 'fb_${DateTime.now().millisecondsSinceEpoch}',
      sourceHindi: sourceHindi,
      generatedTribal: generatedTribal,
      correctedTribal: correctedTribal,
      teacherNotes: teacherNotes,
      district: _selectedDistrict,
      language: _selectedLanguage.name,
      createdAt: DateTime.now(),
    );

    _feedbackList.insert(0, record);
    notifyListeners();
  }

  /// Simulates sync with Cluster Resource Centre (CRC)
  Future<int> syncWithCRC() async {
    _isProcessing = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1400));
    final count = _feedbackList.length;

    _isProcessing = false;
    notifyListeners();
    return count;
  }
}
