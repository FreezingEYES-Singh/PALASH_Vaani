enum GradeLevel {
  balvatika,
  class1,
  class2,
  class3,
}

enum SubjectArea {
  language,
  mathematics,
  environmentalAwareness,
}

enum ConfidenceTier {
  tier1Verified, // SCERT/PALASH textbook verified (100% accurate, zero latency)
  tier2EdgeNeural, // Quantized on-device model inference
  tier3CommunityFlagged, // Flagged for review
}

class CurriculumItem {
  final String id;
  final GradeLevel grade;
  final SubjectArea subject;
  final String category;
  final String hindiPhrase;
  final String santhaliOlChiki;
  final String santhaliPhoneticDeva; // Devanagari phonetic guide for Hindi teacher
  final String santhaliLatinPhonetic;
  final String mundariDeva;
  final String hoWarangChiti;
  final String hoDeva;
  final String englishMeaning;
  final String nipunOutcomeCode;
  final String nipunOutcomeDesc;
  final ConfidenceTier confidence;
  final String audioPromptText;
  final String iconEmoji;

  const CurriculumItem({
    required this.id,
    required this.grade,
    required this.subject,
    required this.category,
    required this.hindiPhrase,
    required this.santhaliOlChiki,
    required this.santhaliPhoneticDeva,
    required this.santhaliLatinPhonetic,
    required this.mundariDeva,
    required this.hoWarangChiti,
    required this.hoDeva,
    required this.englishMeaning,
    required this.nipunOutcomeCode,
    required this.nipunOutcomeDesc,
    this.confidence = ConfidenceTier.tier1Verified,
    required this.audioPromptText,
    required this.iconEmoji,
  });
}
