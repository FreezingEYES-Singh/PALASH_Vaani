import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/translation_result.dart';
import '../state/app_state.dart';
import '../widgets/dual_script_text.dart';
import '../widgets/tribal_badge.dart';
import 'classroom_intercom_screen.dart';
import 'community_sync_screen.dart';
import 'curriculum_lessons_screen.dart';
import 'worksheet_flashcard_screen.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E4D2B), // Deep Forest Green
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            // App Logo
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.school,
                  color: Color(0xFF1E4D2B),
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'पलाश-वाणी',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    'प्राथमिक मातृभाषा शिक्षण साधन',
                    style: TextStyle(
                      color: Color(0xFFD1E7DD),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Clean, understated Offline Status Pill
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24, width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF34D399), // Emerald pulse dot
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'ऑफ़लाइन',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Language & District Selector
            _buildLanguageSelector(context, appState),
            const SizedBox(height: 16),

            // 2. Quick Action Classroom Teaching Banner
            _buildQuickTeachingBanner(context),
            const SizedBox(height: 20),

            // 3. Section Title: Classroom Pedagogical Modules
            const Text(
              'शिक्षण मॉड्यूल (Classroom Modules)',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),

            // 4. 4 Core Action Cards Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 700 ? 4 : 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: [
                _buildActionCard(
                  context,
                  title: 'कक्षा संवाद',
                  englishTitle: 'Intercom',
                  subtitle: 'द्विभाषी ध्वनि अनुवाद',
                  badge: 'ध्वनि',
                  icon: Icons.mic_rounded,
                  color: const Color(0xFFD96B27), // Warm Terracotta
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ClassroomIntercomScreen()),
                  ),
                ),
                _buildActionCard(
                  context,
                  title: 'पाठ्यक्रम पाठ',
                  englishTitle: 'Curriculum',
                  subtitle: 'कक्षा १-३ FLN सामग्री',
                  badge: 'SCERT',
                  icon: Icons.menu_book_rounded,
                  color: const Color(0xFF1E4D2B), // Forest Green
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CurriculumLessonsScreen()),
                  ),
                ),
                _buildActionCard(
                  context,
                  title: 'कार्यपत्रक व फ्लैशकार्ड',
                  englishTitle: 'Worksheets',
                  subtitle: 'प्रिंट योग्य PDF व शब्दावली',
                  badge: 'NIPUN',
                  icon: Icons.assignment_rounded,
                  color: const Color(0xFF2A9D8F), // Teal
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WorksheetFlashcardScreen()),
                  ),
                ),
                _buildActionCard(
                  context,
                  title: 'सामुदायिक सिंक',
                  englishTitle: 'Resource Sync',
                  subtitle: 'संकुल ऑफ़लाइन सामग्री',
                  badge: 'संकुल',
                  icon: Icons.sync_alt_rounded,
                  color: const Color(0xFF4338CA), // Slate Indigo
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CommunitySyncScreen()),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 5. Recent Classroom Interaction
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'हाल का संवाद (Recent Dialogue)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                if (appState.latestResult != null)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ClassroomIntercomScreen()),
                    ),
                    icon: const Icon(Icons.arrow_forward, size: 14, color: Color(0xFF1E4D2B)),
                    label: const Text(
                      'सभी देखें',
                      style: TextStyle(color: Color(0xFF1E4D2B), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            if (appState.latestResult != null)
              _buildLatestDialogueCard(context, appState.latestResult!, appState)
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.record_voice_over_outlined, size: 36, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(
                      'अभी तक कोई संवाद नहीं हुआ है',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '"कक्षा संवाद" खोलें और हिन्दी में बोलकर अनुवाद करें',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
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
  // LANGUAGE & DISTRICT SELECTION CARD
  // ==========================================
  Widget _buildLanguageSelector(BuildContext context, AppState appState) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Color(0xFF1E4D2B)),
                  const SizedBox(width: 4),
                  Text(
                    'जिला: ${appState.selectedDistrict}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'प्राथमिक विद्यालय',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 3 Tribal Language Selection Chips
          Row(
            children: [
              _buildLangChip(
                title: 'संताली',
                sub: 'Ol Chiki',
                isSelected: appState.selectedLanguage == TargetTribalLanguage.santhali,
                onTap: () => appState.setLanguage(TargetTribalLanguage.santhali),
              ),
              const SizedBox(width: 8),
              _buildLangChip(
                title: 'मुंडारी',
                sub: 'Devanagari',
                isSelected: appState.selectedLanguage == TargetTribalLanguage.mundari,
                onTap: () => appState.setLanguage(TargetTribalLanguage.mundari),
              ),
              const SizedBox(width: 8),
              _buildLangChip(
                title: 'हो',
                sub: 'Warang Chiti',
                isSelected: appState.selectedLanguage == TargetTribalLanguage.ho,
                onTap: () => appState.setLanguage(TargetTribalLanguage.ho),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLangChip({
    required String title,
    required String sub,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE8F5E9) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF1E4D2B) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFF1E4D2B) : const Color(0xFF334155),
                ),
              ),
              Text(
                sub,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // QUICK CLASSROOM TEACHING BANNER
  // ==========================================
  Widget _buildQuickTeachingBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E4D2B), Color(0xFF2D6A4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E4D2B).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.spatial_audio_off_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'कक्षा शिक्षण संवाद',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'हिन्दी में बोलें, मातृभाषा में पढ़ाएं',
                      style: TextStyle(
                        color: Color(0xFFD1E7DD),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF4A261), // Warm Terracotta Gold
                foregroundColor: const Color(0xFF1E293B),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.mic, size: 18, color: Color(0xFF1E293B)),
              label: const Text(
                'संवाद शुरू करें (Start Classroom Intercom)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ClassroomIntercomScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ACTION CARDS
  // ==========================================
  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String englishTitle,
    required String subtitle,
    required String badge,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: color,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // RECENT DIALOGUE PREVIEW
  // ==========================================
  Widget _buildLatestDialogueCard(BuildContext context, TranslationResult result, AppState appState) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TribalBadge(tier: result.confidenceTier),
              IconButton(
                icon: const Icon(Icons.volume_up, color: Color(0xFF1E4D2B), size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => appState.playAudio(result.phoneticDevanagari),
                tooltip: 'ध्वनि सुनें',
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Source Input
          Text(
            'शिक्षक (Hindi): "${result.sourceText}"',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 8),

          // Output Dual Script
          DualScriptText(
            olChikiText: result.nativeScriptText,
            phoneticDevanagari: result.phoneticDevanagari,
            latinPhonetic: result.latinPhonetic,
            fontSize: 18,
          ),
        ],
      ),
    );
  }
}
