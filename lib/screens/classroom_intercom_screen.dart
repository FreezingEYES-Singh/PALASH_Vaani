import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/translation_result.dart';
import '../state/app_state.dart';
import '../widgets/dual_script_text.dart';
import '../widgets/tribal_badge.dart';

class ClassroomIntercomScreen extends StatefulWidget {
  const ClassroomIntercomScreen({super.key});

  @override
  State<ClassroomIntercomScreen> createState() => _ClassroomIntercomScreenState();
}

class _ClassroomIntercomScreenState extends State<ClassroomIntercomScreen> {
  final TextEditingController _inputController = TextEditingController();
  bool _isRecording = false;

  final List<String> _quickTeacherPhrases = [
    'बच्चों, अपनी किताबें खोलो',
    'यहाँ देखो',
    'हाथ उठाओ',
    'शांत रहो',
    'गिनती करो',
    'बहुत बढ़िया!',
    'तुम्हारा नाम क्या है?',
    'पेड़ देखो',
  ];

  final List<String> _quickChildResponses = [
    'ᱦᱟᱛᱤ! (हाथी)',
    'ᱫᱟᱨᱮ! (पेड़)',
    'ᱢᱤᱫ! (एक)',
    'ᱵᱟᱨ! (दो)',
    'ᱦᱚᱭ! (हाँ)',
    'ᱵᱟᱝ! (नहीं)',
  ];

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _simulateVoiceRecord(AppState appState) async {
    setState(() => _isRecording = true);

    // Simulate 1.2s speaking window
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    setState(() => _isRecording = false);

    // If teacher mode, pick active text or random common phrase
    final text = _inputController.text.trim().isNotEmpty
        ? _inputController.text.trim()
        : 'बच्चों, अपनी किताबें खोलो';

    if (appState.intercomMode == IntercomMode.teacherToStudent) {
      await appState.translateTeacherSpeech(text);
    } else {
      await appState.translateChildSpeech('ᱦᱟᱛᱤ!');
    }
  }

  void _showFeedbackDialog(BuildContext context, TranslationResult result, AppState appState) {
    final noteController = TextEditingController();
    final correctionController = TextEditingController(text: result.nativeScriptText);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.flag, color: Color(0xFFD96B27)),
            SizedBox(width: 8),
            Text('सामुदायिक सुधार (Community Correction)', style: TextStyle(fontSize: 15)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('मूल हिंदी: ${result.sourceText}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 10),
            TextField(
              controller: correctionController,
              decoration: const InputDecoration(
                labelText: 'सुधारित संथाली / जनजातीय वाक्य',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'शिक्षक टिप्पणी / स्थानीय बोली नोट',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E4D2B)),
            onPressed: () {
              appState.addFeedback(
                sourceHindi: result.sourceText,
                generatedTribal: result.nativeScriptText,
                correctedTribal: correctionController.text.trim(),
                teacherNotes: noteController.text.trim(),
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('सुधार ऑफलाइन सहेजा गया। CRC बैठक में सिंक होगा।')),
              );
            },
            child: const Text('Save Offline', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isTeacherMode = appState.intercomMode == IntercomMode.teacherToStudent;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E4D2B),
        title: const Text('कक्षा संवाद (Voice-to-Voice Intercom)', style: TextStyle(fontSize: 16, color: Colors.white)),
        actions: [
          LanguagePill(language: appState.selectedLanguage),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // Mode Toggle Bar (Teacher Mode vs Child Mode)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => appState.setIntercomMode(IntercomMode.teacherToStudent),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isTeacherMode ? const Color(0xFF1E4D2B) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person, size: 16, color: isTeacherMode ? Colors.white : Colors.grey.shade700),
                          const SizedBox(width: 6),
                          Text(
                            'शिक्षक ➔ छात्र (Hindi to Tribal)',
                            style: TextStyle(
                              color: isTeacherMode ? Colors.white : Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => appState.setIntercomMode(IntercomMode.studentToTeacher),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !isTeacherMode ? const Color(0xFFD96B27) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.face, size: 16, color: !isTeacherMode ? Colors.white : Colors.grey.shade700),
                          const SizedBox(width: 6),
                          Text(
                            'छात्र ➔ शिक्षक (Tribal to Hindi)',
                            style: TextStyle(
                              color: !isTeacherMode ? Colors.white : Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),


          // Main Conversation Canvas
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: appState.translationHistory.length,
              itemBuilder: (context, index) {
                final item = appState.translationHistory[index];
                return _buildDialogueBubble(context, item, appState);
              },
            ),
          ),

          // Quick Tap Phrases Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: Colors.white,
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: isTeacherMode ? _quickTeacherPhrases.length : _quickChildResponses.length,
              separatorBuilder: (context, index) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final phrase = isTeacherMode ? _quickTeacherPhrases[index] : _quickChildResponses[index];
                return ActionChip(
                  backgroundColor: const Color(0xFFF1F5F9),
                  label: Text(phrase, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  onPressed: () {
                    _inputController.text = phrase;
                    if (isTeacherMode) {
                      appState.translateTeacherSpeech(phrase);
                    } else {
                      appState.translateChildSpeech(phrase);
                    }
                  },
                );
              },
            ),
          ),

          // Microphone & Input Bottom Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -3)),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      decoration: InputDecoration(
                        hintText: isTeacherMode ? 'हिंदी में बोलें या टाइप करें...' : 'छात्र संथाली में बोलें...',
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      onSubmitted: (text) {
                        if (text.trim().isNotEmpty) {
                          if (isTeacherMode) {
                            appState.translateTeacherSpeech(text);
                          } else {
                            appState.translateChildSpeech(text);
                          }
                          _inputController.clear();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Push-to-Talk Mic Button
                  GestureDetector(
                    onTap: () => _simulateVoiceRecord(appState),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _isRecording
                            ? Colors.red
                            : (isTeacherMode ? const Color(0xFF1E4D2B) : const Color(0xFFD96B27)),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording ? Colors.red : const Color(0xFF1E4D2B)).withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: _isRecording ? 4 : 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRecording ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogueBubble(BuildContext context, TranslationResult item, AppState appState) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TribalBadge(tier: item.confidenceTier),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.flag_outlined, size: 18, color: Colors.grey),
                    tooltip: 'Flag / Suggest Correction',
                    onPressed: () => _showFeedbackDialog(context, item, appState),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up, size: 20, color: Color(0xFF1E4D2B)),
                    tooltip: 'Play Native Voice',
                    onPressed: () => appState.playAudio(item.phoneticDevanagari),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Source Input
          Text(
            '${item.sourceLang}: "${item.sourceText}"',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 8),

          // Dual-Script Output
          DualScriptText(
            olChikiText: item.nativeScriptText,
            phoneticDevanagari: item.phoneticDevanagari,
            latinPhonetic: item.latinPhonetic,
            fontSize: 21,
          ),
        ],
      ),
    );
  }
}
