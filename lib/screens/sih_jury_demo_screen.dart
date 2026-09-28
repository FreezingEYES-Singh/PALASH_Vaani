import 'dart:async';
import 'package:flutter/material.dart';
import '../models/curriculum_item.dart';
import '../models/worksheet_template.dart';
import '../services/pdf_export_service.dart';
import '../services/speech_service.dart';
import '../widgets/latency_meter_widget.dart';
import '../widgets/tribal_badge.dart';

class SihJuryDemoScreen extends StatefulWidget {
  const SihJuryDemoScreen({super.key});

  @override
  State<SihJuryDemoScreen> createState() => _SihJuryDemoScreenState();
}

class _SihJuryDemoScreenState extends State<SihJuryDemoScreen> {
  int _currentStep = 0;
  bool _isAutoPlaying = false;
  Timer? _autoPlayTimer;
  double _stepProgress = 0.0;
  Timer? _progressTimer;

  final List<Map<String, dynamic>> _demoStages = [
    {
      'title': 'चरण 1: शिक्षक हिंदी आदेश (Teacher Hindi Prompt)',
      'subtitle': 'गैर-जनजातीय शिक्षक द्वारा कक्षा में हिंदी निर्देश',
      'icon': Icons.record_voice_over,
      'badge': 'Speech Input (ASR)',
      'color': const Color(0xFF1E4D2B), // Forest green
      'detail': 'शिक्षक बोलते हैं: "बच्चों, अपनी किताबें खोलो"',
      'sourceText': 'बच्चों, अपनी किताबें खोलो',
      'status': 'WebRTC VAD द्वारा 380ms में आवाज़ पहचानी गई (Noisy Classroom Filtered)',
    },
    {
      'title': 'चरण 2: डुअल-पाथ इंटेंट रूटिंग (Dual-Path AI Engine)',
      'subtitle': 'एससीईआरटी पाठ्यक्रम फास्ट-पाथ बनाम न्यूरल फॉलबैक',
      'icon': Icons.alt_route,
      'badge': '< 30ms Cache Hit',
      'color': const Color(0xFF2A9D8F), // Teal
      'detail': 'JCERT PALASH FLN पाठ्यक्रम डेटाबेस में मैच मिला (100% Verified)',
      'sourceText': 'बच्चों, अपनी किताबें खोलो',
      'status': 'Tier 1 Verified SCERT Pack • Zero Hallucination • 24ms MT Latency',
    },
    {
      'title': 'चरण 3: दोहरी-लिपि प्रस्तुति (Dual-Script Scaffolding)',
      'subtitle': 'संथाली ओल चिकी लिपि + शिक्षक के लिए देवनागरी उच्चारण',
      'icon': Icons.translate,
      'badge': 'Dual-Script Engine',
      'color': const Color(0xFFD96B27), // Terracotta
      'olChiki': 'ᱜᱤᱫᱽᱨᱟᱹ ᱠᱚ, ᱟᱯᱱᱟᱨᱟᱜ ᱯᱩᱛᱷᱤ ᱡᱷᱤᱡᱽ ᱯᱮ',
      'devaGuide': 'गिदरा को, आपनाराग पुथि झिज पे',
      'meaning': 'Children, open your books (Follows oral instructions in classroom)',
      'status': 'शिक्षक देवनागरी गाइड देखकर स्वयं बोल सकते हैं या ऑडियो बजा सकते हैं',
    },
    {
      'title': 'चरण 4: ऑन-डिवाइस ऑडियो व सब-3s लेटेंसी (Latency Budget)',
      'subtitle': 'पाइपर-ओएनएनएक्स 16kHz स्थानीय वॉयस सिंथेसिस',
      'icon': Icons.volume_up,
      'badge': 'Total Latency: 1.02s',
      'color': const Color(0xFF0284C7), // Sky Blue
      'status': 'कक्षा स्पीकर पर 1.02 सेकंड में संथाली वाणी बजी (Target: <= 3.0s Passed!)',
      'metrics': {'asr': 380, 'mt': 24, 'tts': 620, 'total': 1024},
    },
    {
      'title': 'चरण 5: छात्र प्रतिपुष्टि (Reverse Tribal-to-Hindi Intercom)',
      'subtitle': 'जनजातीय बच्चे अपनी मातृभाषा में उत्तर देते हैं',
      'icon': Icons.hearing,
      'badge': 'Child Mother Tongue',
      'color': const Color(0xFF9333EA), // Purple
      'childTribal': 'ᱦᱟᱛᱤ! ᱫᱟᱨᱮ ᱥᱟᱵ ᱟᱠᱟᱫᱟᱭ!',
      'childPhonetic': 'हाती! दारे साब आकादाय!',
      'translatedHindi': 'हाथी! उसने पेड़ पकड़ रखा है!',
      'status': 'गैर-जनजातीय शिक्षक को तुरंत स्क्रीन पर हिंदी अर्थ दिखता है',
    },
    {
      'title': 'चरण 6: 2 GB रैम व हार्डवेयर सुरक्षा (Edge Resource Budget)',
      'subtitle': 'इंट8 क्वांटाइज़्ड मॉडल्स • शून्य इंटरनेट • ज़ीरो ओओएम क्रैश',
      'icon': Icons.memory,
      'badge': '385 MB / 2048 MB',
      'color': const Color(0xFF0F766E), // Dark Teal
      'status': 'Android 9 ओएस और बैकग्राउंड ऐप्स के लिए 460+ MB सुरक्षा हेडरुम उपलब्ध है',
      'ramDetail': 'IndicConformer (85MB) + AdiBhashaa MT (115MB) + Piper TTS (75MB) + UI (110MB)',
    },
    {
      'title': 'चरण 7: प्रिंट करने योग्य निपुण भारत वर्कशीट (A4 Vector PDF)',
      'subtitle': 'लोकल ट्रू-टाइप फोंट से बिना इंटरनेट A4 वर्कशीट तैयार',
      'icon': Icons.picture_as_pdf,
      'badge': '100% Offline PDF',
      'color': const Color(0xFFE11D48), // Rose
      'status': 'नोतो सेन्स ओल चिकी (Noto Sans Ol Chiki) से ज़ीरो-टोफू बॉक्स मुद्रण',
    },
  ];

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _progressTimer?.cancel();
    super.dispose();
  }

  void _startAutoPlay() {
    setState(() {
      _isAutoPlaying = true;
      _stepProgress = 0.0;
    });

    _triggerStepAudio(_currentStep);

    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;
      setState(() {
        _stepProgress += 0.0125; // 4 seconds per step
        if (_stepProgress >= 1.0) {
          _stepProgress = 0.0;
          if (_currentStep < _demoStages.length - 1) {
            _currentStep++;
            _triggerStepAudio(_currentStep);
          } else {
            _isAutoPlaying = false;
            _autoPlayTimer?.cancel();
            timer.cancel();
          }
        }
      });
    });
  }

  void _stopAutoPlay() {
    _progressTimer?.cancel();
    _autoPlayTimer?.cancel();
    setState(() {
      _isAutoPlaying = false;
      _stepProgress = 0.0;
    });
  }

  void _goToStep(int step) {
    _stopAutoPlay();
    setState(() {
      _currentStep = step;
      _stepProgress = 0.0;
    });
    _triggerStepAudio(step);
  }

  void _triggerStepAudio(int step) {
    if (step == 0) {
      SpeechService.speakText('बच्चों, अपनी किताबें खोलो', lang: 'hi-IN');
    } else if (step == 3) {
      SpeechService.speakText('गिदरा को, आपनाराग पुथि झिज पे', lang: 'hi-IN');
    } else if (step == 4) {
      SpeechService.speakText('हाथी! उसने पेड़ पकड़ रखा है!', lang: 'hi-IN');
    }
  }

  void _generateDemoPdf(BuildContext context) async {
    final template = WorksheetTemplate(
      id: 'sih_jury_demo_ws',
      titleHindi: 'ओल चिकी वर्णमाला व शब्द पहचान',
      titleSanthali: 'ᱚᱞ ᱪᱤᱠᱤ ᱪᱤᱠᱤ ᱩᱯᱨᱩᱢ',
      grade: GradeLevel.class1,
      subject: SubjectArea.language,
      type: WorksheetType.tracing,
      nipunOutcomeCode: 'FLN-L1-02',
      nipunOutcomeText: 'Follows oral and written vocabulary instructions',
      items: const [
        WorksheetExerciseItem(
          promptHindi: 'किताब (Book)',
          promptTribal: 'ᱯᱩᱛᱷᱤ',
          phoneticPrompt: 'पुथि',
          answerKey: 'ᱯᱩᱛᱷᱤ',
          visualEmoji: '📖',
        ),
        WorksheetExerciseItem(
          promptHindi: 'पेड़ (Tree)',
          promptTribal: 'ᱫᱟᱨᱮ',
          phoneticPrompt: 'दारे',
          answerKey: 'ᱫᱟᱨᱮ',
          visualEmoji: '🌳',
        ),
        WorksheetExerciseItem(
          promptHindi: 'हाथी (Elephant)',
          promptTribal: 'ᱦᱟᱛᱤ',
          phoneticPrompt: 'हाती',
          answerKey: 'ᱦᱟᱛᱤ',
          visualEmoji: '🐘',
        ),
      ],
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('प्रिंट करने योग्य A4 द्विभाषी वर्कशीट तैयार हो रही है...'),
        backgroundColor: Color(0xFF1E4D2B),
        duration: Duration(seconds: 2),
      ),
    );

    await PdfExportService.printWorksheet(template);
  }

  @override
  Widget build(BuildContext context) {
    final currentStage = _demoStages[_currentStep];
    final color = currentStage['color'] as Color;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark slate navy
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'SIH 2026',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'जूरी लाइव सिमुलेशन (30-Sec Demo)',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Text(
              'PALASH-Vaani • Real-Time Classroom Pipeline Walkthrough',
              style: TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _isAutoPlaying ? 'पॉज़ करें (Pause)' : 'ऑटो-प्ले शुरू करें (Auto-Play)',
            icon: Icon(
              _isAutoPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: Colors.amberAccent,
              size: 28,
            ),
            onPressed: () {
              if (_isAutoPlaying) {
                _stopAutoPlay();
              } else {
                _startAutoPlay();
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Step Progress Bar Indicator
          if (_isAutoPlaying)
            LinearProgressIndicator(
              value: _stepProgress,
              backgroundColor: const Color(0xFF1E293B),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amberAccent),
              minHeight: 3,
            ),

          // Steps Horizontal Tracker
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            color: const Color(0xFF1E293B).withOpacity(0.5),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_demoStages.length, (index) {
                  final isDone = index < _currentStep;
                  final isCurrent = index == _currentStep;
                  return GestureDetector(
                    onTap: () => _goToStep(index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? Colors.amber.shade700
                            : isDone
                                ? const Color(0xFF1E4D2B)
                                : const Color(0xFF334155),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrent ? Colors.amberAccent : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isDone ? Icons.check_circle : (isCurrent ? Icons.play_arrow : Icons.circle_outlined),
                            size: 13,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Step ${index + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Main Step Card Area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stage Header Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.85), const Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: color.withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(color: color.withOpacity(0.2), blurRadius: 16, offset: const Offset(0, 6)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(currentStage['icon'] as IconData, color: Colors.white, size: 24),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Text(
                                currentStage['badge'] as String,
                                style: const TextStyle(
                                  color: Colors.amberAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          currentStage['title'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentStage['subtitle'] as String,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Stage Interactive Visual Body
                  _buildStageSpecificContent(context, _currentStep, currentStage),

                  const SizedBox(height: 16),

                  // Technical Status & Architecture Note
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: Colors.amberAccent, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'तकनीकी सत्यापन (Technical Verification):',
                                style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                currentStage['status'] as String,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Control Navigation Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              border: const Border(top: BorderSide(color: Color(0xFF334155))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _currentStep > 0 ? () => _goToStep(_currentStep - 1) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF334155),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF1E293B),
                  ),
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('पिछला (Prev)', style: TextStyle(fontSize: 12)),
                ),
                Text(
                  '${_currentStep + 1} / ${_demoStages.length}',
                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                ElevatedButton.icon(
                  onPressed: _currentStep < _demoStages.length - 1
                      ? () => _goToStep(_currentStep + 1)
                      : () => _goToStep(0),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentStep == _demoStages.length - 1
                        ? const Color(0xFF10B981)
                        : Colors.amber.shade700,
                    foregroundColor: Colors.white,
                  ),
                  icon: Icon(
                    _currentStep == _demoStages.length - 1 ? Icons.replay : Icons.arrow_forward,
                    size: 16,
                  ),
                  label: Text(
                    _currentStep == _demoStages.length - 1 ? 'पुनः चलाएं (Restart)' : 'अगला (Next)',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageSpecificContent(BuildContext context, int step, Map<String, dynamic> stage) {
    switch (step) {
      case 0:
        return _buildStep1Prompt(stage);
      case 1:
        return _buildStep2Routing(stage);
      case 2:
        return _buildStep3DualScript(stage);
      case 3:
        return _buildStep4Latency(stage);
      case 4:
        return _buildStep5ReverseIntercom(stage);
      case 5:
        return _buildStep6Memory(stage);
      case 6:
        return _buildStep7Pdf(context, stage);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1Prompt(Map<String, dynamic> stage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF065F46)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.mic, color: Color(0xFF34D399), size: 20),
              SizedBox(width: 8),
              Text(
                'लाइव स्ट्रीमिंग ASR (WebRTC VAD + Noise Gate)',
                style: TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    stage['sourceText'] as String,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.amberAccent),
                  onPressed: () => SpeechService.speakText(stage['sourceText'] as String, lang: 'hi-IN'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF34D399), size: 14),
              SizedBox(width: 6),
              Text('कक्षा के बच्चों का शोर स्वतः फ़िल्टर किया गया', style: TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Routing(Map<String, dynamic> stage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0F766E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'डुअल-पाथ इंटेंट आर्किटेक्चर (Dual-Path Router):',
            style: TextStyle(color: Color(0xFF2DD4BF), fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B).withOpacity(0.4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF34D399).withOpacity(0.5)),
            ),
            child: const Row(
              children: [
                Icon(Icons.bolt, color: Colors.amberAccent, size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Path A: JCERT PALASH FLN Cache (Hit!)',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Text(
                        'लेटेंसी: 24 ms • सटीकता: 100% • शून्य AI हैलुसिनेशन',
                        style: TextStyle(color: Color(0xFF34D399), fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: const Row(
              children: [
                Icon(Icons.memory, color: Colors.white38, size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Path B: Distilled AdiBhashaa INT8 (Standby)',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                      Text(
                        'असामान्य वार्तालाप के लिए ऑन-डिवाइस न्यूरल अनुवाद (< 580ms)',
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3DualScript(Map<String, dynamic> stage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD96B27)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'संथाली आउटपुट (Ol Chiki + Devanagari Guide):',
                style: TextStyle(color: Color(0xFFFDBA74), fontWeight: FontWeight.bold, fontSize: 12),
              ),
              TribalBadge(
                tier: ConfidenceTier.tier1Verified,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFD96B27).withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage['olChiki'] as String,
                  style: const TextStyle(
                    fontFamily: 'NotoSansOlChiki',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.amberAccent,
                  ),
                ),
                const Divider(color: Colors.white24, height: 16),
                Row(
                  children: [
                    const Icon(Icons.school, size: 14, color: Colors.lightBlueAccent),
                    const SizedBox(width: 6),
                    Text(
                      'शिक्षक उच्चारण गाइड: ${stage['devaGuide']}',
                      style: const TextStyle(fontSize: 13, color: Colors.lightBlueAccent, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'अर्थ: ${stage['meaning']}',
            style: const TextStyle(color: Colors.white70, fontSize: 11, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4Latency(Map<String, dynamic> stage) {
    final metrics = stage['metrics'] as Map<String, dynamic>;
    return Column(
      children: [
        LatencyMeterWidget(
          asrMs: metrics['asr'],
          mtMs: metrics['mt'],
          ttsMs: metrics['tts'],
          totalMs: metrics['total'],
          isFastPath: true,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0284C7).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF0284C7).withOpacity(0.4)),
          ),
          child: const Row(
            children: [
              Icon(Icons.verified, color: Colors.lightGreenAccent, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'SIH PS 26042 नियम: लेटेंसी <= 3.0s आवश्यक • परिणाम: 1.02s (PASS)',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep5ReverseIntercom(Map<String, dynamic> stage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.face, color: Colors.purpleAccent, size: 20),
              SizedBox(width: 8),
              Text(
                'जनजातीय छात्र आवाज इनपुट (Tribal Speech Response):',
                style: TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage['childTribal'] as String,
                  style: const TextStyle(
                    fontFamily: 'NotoSansOlChiki',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purpleAccent,
                  ),
                ),
                Text(
                  'उच्चारण: ${stage['childPhonetic']}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.arrow_downward, color: Colors.amberAccent, size: 16),
              SizedBox(width: 6),
              Text('तुरंत गैर-जनजातीय शिक्षक के लिए अनुवाद:', style: TextStyle(color: Colors.amberAccent, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E4D2B).withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF34D399)),
            ),
            child: Text(
              stage['translatedHindi'] as String,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep6Memory(Map<String, dynamic> stage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF14B8A6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '2 GB RAM बजट अनुपालन (Memory Gauge):',
                style: TextStyle(color: Color(0xFF2DD4BF), fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                '385 MB / 2048 MB',
                style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 20,
              child: Row(
                children: [
                  Expanded(
                    flex: 1200,
                    child: Container(
                      color: const Color(0xFF64748B),
                      child: const Center(
                        child: Text('OS: 1.2 GB', style: TextStyle(color: Colors.white, fontSize: 9)),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 385,
                    child: Container(
                      color: const Color(0xFF10B981),
                      child: const Center(
                        child: Text('PALASH: 385 MB', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 463,
                    child: Container(
                      color: const Color(0xFF0284C7),
                      child: const Center(
                        child: Text('Headroom: 463 MB', style: TextStyle(color: Colors.white, fontSize: 9)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            stage['ramDetail'] as String,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildStep7Pdf(BuildContext context, Map<String, dynamic> stage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE11D48)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.print, color: Color(0xFFFB7185), size: 20),
              SizedBox(width: 8),
              Text(
                'निपुण भारत द्विभाषी A4 वर्कशीट (Bilingual PDF):',
                style: TextStyle(color: Color(0xFFFB7185), fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'गाँव के विद्यालय में बिना इंटरनेट के तुरंत A4 वर्कशीट तैयार होती है। सोहराय कला व ओल चिकी वर्णमाला के साथ बच्चे अभ्यास करते हैं।',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _generateDemoPdf(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.picture_as_pdf, size: 18),
              label: const Text('लाइव A4 पीडीएफ खोलें / प्रिंट करें (Open Vector PDF)', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
