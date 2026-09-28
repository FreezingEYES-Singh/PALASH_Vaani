import 'package:flutter/material.dart';
import '../models/curriculum_item.dart';
import '../models/translation_result.dart';

class TribalBadge extends StatelessWidget {
  final ConfidenceTier tier;

  const TribalBadge({super.key, required this.tier});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color text;
    String label;
    IconData icon;

    switch (tier) {
      case ConfidenceTier.tier1Verified:
        bg = const Color(0xFFE8F5E9);
        border = const Color(0xFF81C784);
        text = const Color(0xFF1B5E20);
        label = 'Tier 1 • SCERT Verified';
        icon = Icons.verified;
        break;
      case ConfidenceTier.tier2EdgeNeural:
        bg = const Color(0xFFFFF8E1);
        border = const Color(0xFFFFD54F);
        text = const Color(0xFFF57F17);
        label = 'Tier 2 • Edge Model';
        icon = Icons.smart_toy;
        break;
      case ConfidenceTier.tier3CommunityFlagged:
        bg = const Color(0xFFFFEBEE);
        border = const Color(0xFFE57373);
        text = const Color(0xFFB71C1C);
        label = 'Tier 3 • Flagged for Review';
        icon = Icons.flag;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: text),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class LanguagePill extends StatelessWidget {
  final TargetTribalLanguage language;

  const LanguagePill({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    String title;
    String script;

    switch (language) {
      case TargetTribalLanguage.santhali:
        title = 'Santhali';
        script = 'Ol Chiki (ᱚᱞ ᱪᱤᱠᱤ)';
        break;
      case TargetTribalLanguage.mundari:
        title = 'Mundari';
        script = 'Devanagari';
        break;
      case TargetTribalLanguage.ho:
        title = 'Ho';
        script = 'Warang Chiti (𑢹𑣉𑣉)';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E4D2B), // Forest Green
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.translate, size: 12, color: Colors.white70),
          const SizedBox(width: 5),
          Text(
            '$title ($script)',
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
