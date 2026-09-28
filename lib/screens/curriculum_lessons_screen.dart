import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/fln_curriculum_data.dart';
import '../models/curriculum_item.dart';
import '../models/translation_result.dart';
import '../state/app_state.dart';
import '../widgets/dual_script_text.dart';
import '../widgets/tribal_badge.dart';

class CurriculumLessonsScreen extends StatefulWidget {
  const CurriculumLessonsScreen({super.key});

  @override
  State<CurriculumLessonsScreen> createState() => _CurriculumLessonsScreenState();
}

class _CurriculumLessonsScreenState extends State<CurriculumLessonsScreen> {
  GradeLevel? _filterGrade;
  SubjectArea? _filterSubject;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final filteredItems = FlnCurriculumData.items.where((item) {
      if (_filterGrade != null && item.grade != _filterGrade) return false;
      if (_filterSubject != null && item.subject != _filterSubject) return false;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return item.hindiPhrase.toLowerCase().contains(query) ||
            item.category.toLowerCase().contains(query) ||
            item.santhaliOlChiki.contains(query);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E4D2B),
        title: const Text('पाठ्यक्रम व पाठ (FLN Curriculum)', style: TextStyle(fontSize: 16, color: Colors.white)),
        actions: [
          LanguagePill(language: appState.selectedLanguage),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips & Search Bar
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Column(
              children: [
                // Search Input
                TextField(
                  decoration: InputDecoration(
                    hintText: 'पाठ, शब्द या निर्देश खोजें...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                const SizedBox(height: 10),

                // Grade Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Text('कक्षा: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      _buildFilterChip('सभी (All)', _filterGrade == null, () => setState(() => _filterGrade = null)),
                      _buildFilterChip('बालवाटिका', _filterGrade == GradeLevel.balvatika, () => setState(() => _filterGrade = GradeLevel.balvatika)),
                      _buildFilterChip('कक्षा १ (Class 1)', _filterGrade == GradeLevel.class1, () => setState(() => _filterGrade = GradeLevel.class1)),
                      const SizedBox(width: 10),
                      const Text('| विषय: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      _buildFilterChip('सभी (All)', _filterSubject == null, () => setState(() => _filterSubject = null)),
                      _buildFilterChip('भाषा', _filterSubject == SubjectArea.language, () => setState(() => _filterSubject = SubjectArea.language)),
                      _buildFilterChip('गणित', _filterSubject == SubjectArea.mathematics, () => setState(() => _filterSubject = SubjectArea.mathematics)),
                      _buildFilterChip('पर्यावरण', _filterSubject == SubjectArea.environmentalAwareness, () => setState(() => _filterSubject = SubjectArea.environmentalAwareness)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Curriculum Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return _buildCurriculumCard(context, item, appState);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.black87)),
        selected: isSelected,
        selectedColor: const Color(0xFF1E4D2B),
        backgroundColor: const Color(0xFFF1F5F9),
        showCheckmark: false,
        onSelected: (_) => onTap(),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      ),
    );
  }

  Widget _buildCurriculumCard(BuildContext context, CurriculumItem item, AppState appState) {
    String nativeScript;
    String phoneticGuide;

    switch (appState.selectedLanguage) {
      case TargetTribalLanguage.santhali:
        nativeScript = item.santhaliOlChiki;
        phoneticGuide = item.santhaliPhoneticDeva;
        break;
      case TargetTribalLanguage.mundari:
        nativeScript = item.mundariDeva;
        phoneticGuide = item.mundariDeva;
        break;
      case TargetTribalLanguage.ho:
        nativeScript = item.hoWarangChiti;
        phoneticGuide = item.hoDeva;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Metadata Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(item.iconEmoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    item.category,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.nipunOutcomeCode,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF0369A1)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Source Hindi Phrase
          Text(
            item.hindiPhrase,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 6),

          // Dual-Script Native & Phonetic Guide
          DualScriptText(
            olChikiText: nativeScript,
            phoneticDevanagari: phoneticGuide,
            latinPhonetic: item.santhaliLatinPhonetic,
            fontSize: 20,
          ),
          const SizedBox(height: 10),

          // Bottom Competency & Action Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  item.nipunOutcomeDesc,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E4D2B),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                    ),
                    icon: const Icon(Icons.volume_up, size: 15, color: Colors.white),
                    label: const Text('Play Audio', style: TextStyle(color: Colors.white, fontSize: 11)),
                    onPressed: () => appState.playAudio(phoneticGuide),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
