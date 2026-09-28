import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/nipun_outcomes_data.dart';
import '../data/visual_flashcards_data.dart';
import '../models/worksheet_template.dart';
import '../services/pdf_export_service.dart';
import '../state/app_state.dart';
import '../widgets/dual_script_text.dart';

class WorksheetFlashcardScreen extends StatefulWidget {
  const WorksheetFlashcardScreen({super.key});

  @override
  State<WorksheetFlashcardScreen> createState() => _WorksheetFlashcardScreenState();
}

class _WorksheetFlashcardScreenState extends State<WorksheetFlashcardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'सभी (All)';
  String _searchQuery = '';
  bool _showTribalCognates = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E4D2B),
        title: const Text('कार्यपत्रक व फ्लैशकार्ड', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFF4A261),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.assignment_outlined, size: 18), text: 'कार्यपत्रक'),
            Tab(icon: Icon(Icons.style_outlined, size: 18), text: 'फ्लैशकार्ड'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWorksheetsTab(context, appState),
          _buildFlashcardsTab(context, appState),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: BILINGUAL WORKSHEETS
  // ==========================================
  Widget _buildWorksheetsTab(BuildContext context, AppState appState) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: NipunOutcomesData.predefinedWorksheets.length,
      itemBuilder: (context, index) {
        final worksheet = NipunOutcomesData.predefinedWorksheets[index];
        return _buildWorksheetCard(context, worksheet, appState);
      },
    );
  }

  Widget _buildWorksheetCard(BuildContext context, WorksheetTemplate worksheet, AppState appState) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'COMPETENCY: ${worksheet.nipunOutcomeCode}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'GRADE: ${worksheet.grade.name.toUpperCase()}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF856404)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            worksheet.titleHindi,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          Text(
            worksheet.titleSanthali,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E4D2B)),
          ),
          const SizedBox(height: 4),
          Text(
            worksheet.nipunOutcomeText,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Exercise preview items
          Column(
            children: worksheet.items.take(3).map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(item.visualEmoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.promptHindi, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          Text(item.promptTribal, style: const TextStyle(fontSize: 11, color: Color(0xFF1E4D2B))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(item.answerKey, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Action Button: Generate & Print A4 PDF
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E4D2B),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.print, color: Colors.white, size: 18),
              label: const Text(
                'A4 द्विभाषी कार्यपत्रक प्रिंट करें (Generate Printable PDF)',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              onPressed: () => PdfExportService.printWorksheet(worksheet),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: MULTILINGUAL VISUAL FLASHCARDS
  // ==========================================
  Widget _buildFlashcardsTab(BuildContext context, AppState appState) {
    final filteredCards = VisualFlashcardsData.flashcards.where((card) {
      final matchesCategory = _selectedCategory == 'सभी (All)' || card.category == _selectedCategory;
      final q = _searchQuery.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          card.hindiWord.toLowerCase().contains(q) ||
          card.englishWord.toLowerCase().contains(q) ||
          card.santhaliOlChiki.toLowerCase().contains(q) ||
          card.santhaliPhoneticDeva.toLowerCase().contains(q) ||
          card.santhaliLatinPhonetic.toLowerCase().contains(q) ||
          card.mundariWord.toLowerCase().contains(q) ||
          card.hoWord.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList();

    return Column(
      children: [
        // Top Filter Bar: Search + Category Chips + Tribal Cognates Switch
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search input
              TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'शब्द या अर्थ खोजें (Search words)...',
                  hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF1E4D2B)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Category Filter Horizontal Scroll
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: VisualFlashcardsData.categories.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, idx) {
                    final cat = VisualFlashcardsData.categories[idx];
                    final isSelected = _selectedCategory == cat;
                    return ChoiceChip(
                      label: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : const Color(0xFF334155),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFF1E4D2B),
                      backgroundColor: const Color(0xFFF1F5F9),
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedCategory = cat);
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Active Stats & Multi-Tribal Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filteredCards.length} शब्द उपलब्ध (${VisualFlashcardsData.flashcards.length} कुल)',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                  ),
                  Row(
                    children: [
                      const Text(
                        'हो व मुंडारी तुलना:',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(width: 4),
                      Transform.scale(
                        scale: 0.75,
                        child: Switch(
                          value: _showTribalCognates,
                          activeColor: const Color(0xFF1E4D2B),
                          onChanged: (val) => setState(() => _showTribalCognates = val),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Flashcards Grid
        Expanded(
          child: filteredCards.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'कोई शब्द नहीं मिला ("$_searchQuery")',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 900
                        ? 4
                        : MediaQuery.of(context).size.width > 600
                            ? 3
                            : 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: MediaQuery.of(context).size.width > 600
                        ? (_showTribalCognates ? 0.72 : 0.82)
                        : (_showTribalCognates ? 0.64 : 0.74),
                  ),
                  itemCount: filteredCards.length,
                  itemBuilder: (context, index) {
                    final card = filteredCards[index];
                    return _buildFlashcard(context, card, appState);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFlashcard(BuildContext context, VisualFlashcard card, AppState appState) {
    return InkWell(
      onTap: () => _showFlashcardDetailModal(context, card, appState),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top: Category tag & Audio Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    card.category.split(' ')[0],
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up, size: 18, color: Color(0xFF1E4D2B)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'ध्वनि सुनें',
                  onPressed: () => appState.playAudio(card.santhaliPhoneticDeva),
                ),
              ],
            ),

            // Visual Emoji
            Text(card.visualEmoji, style: const TextStyle(fontSize: 36)),

            // Dual-Script Text (Ol Chiki + Devanagari guide)
            DualScriptText(
              olChikiText: card.santhaliOlChiki,
              phoneticDevanagari: card.santhaliPhoneticDeva,
              fontSize: 16,
              isCenter: true,
            ),

            // Meaning
            Text(
              '${card.hindiWord} • ${card.englishWord}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Optional Multi-tribal Cognates (Mundari & Ho)
            if (_showTribalCognates)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade300, width: 0.6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Flexible(
                      child: Text(
                        'मुंडारी: ${card.mundariWord}',
                        style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'हो: ${card.hoWord}',
                        style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // FLASHCARD MODAL / MULTILINGUAL DETAIL
  // ==========================================
  void _showFlashcardDetailModal(BuildContext context, VisualFlashcard card, AppState appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top drag pill
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),

              // Visual Emoji
              Text(card.visualEmoji, style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 8),

              // Ol Chiki Primary Heading
              Text(
                card.santhaliOlChiki,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E4D2B),
                  letterSpacing: 1.0,
                ),
              ),

              // Phonetic Devanagari & Latin
              Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFD56B)),
                ),
                child: Text(
                  'उच्चारण (Pronunciation): ${card.santhaliPhoneticDeva} (${card.santhaliLatinPhonetic})',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF856404)),
                ),
              ),

              Text(
                '${card.hindiWord} (Hindi) • ${card.englishWord} (English)',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 14),

              // Cultural Context Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA5D6A7)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.eco, size: 20, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'सांस्कृतिक संदर्भ (Cultural Note): ${card.culturalContextNote}',
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF1B5E20), fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Comparative Tribal Language Table
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    _buildComparisonRow('ᱥᱟᱱᱛᱟᱲᱤ (संताली)', '${card.santhaliOlChiki} (${card.santhaliPhoneticDeva})', isHeader: false),
                    const Divider(height: 1),
                    _buildComparisonRow('ᱢᱩᱱᱰᱟᱨᱤ (मुंडारी)', card.mundariWord, isHeader: false),
                    const Divider(height: 1),
                    _buildComparisonRow('ᱦᱳ (हो)', card.hoWord, isHeader: false),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Audio Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E4D2B),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.volume_up, color: Colors.white, size: 22),
                  label: const Text(
                    'संताली ध्वनि सुनें (Play Vernacular Audio)',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => appState.playAudio(card.santhaliPhoneticDeva),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComparisonRow(String language, String word, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            language,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
          ),
          Text(
            word,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
        ],
      ),
    );
  }
}
