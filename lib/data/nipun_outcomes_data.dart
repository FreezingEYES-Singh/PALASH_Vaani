import '../models/curriculum_item.dart';
import '../models/worksheet_template.dart';

class NipunOutcome {
  final String code;
  final GradeLevel grade;
  final SubjectArea subject;
  final String titleHindi;
  final String titleTribal;
  final String description;
  final String competencyGoal;

  const NipunOutcome({
    required this.code,
    required this.grade,
    required this.subject,
    required this.titleHindi,
    required this.titleTribal,
    required this.description,
    required this.competencyGoal,
  });
}

class NipunOutcomesData {
  static const List<NipunOutcome> outcomes = [
    NipunOutcome(
      code: 'FLN-L1-01',
      grade: GradeLevel.balvatika,
      subject: SubjectArea.language,
      titleHindi: 'मौखिक भाषा विकास व अभिवादन',
      titleTribal: 'ᱢᱚᱪᱟ ᱛᱮ ᱨᱚᱲ ᱟᱨ ᱡᱚᱦᱟᱨ (Oral Expression)',
      description: 'बच्चा मातृभाषा में बातचीत करता है, सरल प्रश्नों के उत्तर देता है और चित्र देखकर अपनी भाषा में बताता है।',
      competencyGoal: 'Lakshya 2: Effective Communicators (EC)',
    ),
    NipunOutcome(
      code: 'FLN-L1-04',
      grade: GradeLevel.class1,
      subject: SubjectArea.language,
      titleHindi: 'चित्र-शब्द सम्बद्धता (शब्दावली संवर्धन)',
      titleTribal: 'ᱪᱤᱛᱟᱹᱨ ᱟᱨ ᱟᱹᱲᱟᱹ ᱢᱤᱞᱟᱹᱣ (Picture-Word Association)',
      description: 'चित्र देखकर पशु, पक्षी, पेड़-पौधों के नाम अपनी मातृभाषा और लिपि (ओल चिकी) में पहचानना।',
      competencyGoal: 'Lakshya 2: Effective Communicators (EC)',
    ),
    NipunOutcome(
      code: 'FLN-L2-01',
      grade: GradeLevel.class1,
      subject: SubjectArea.language,
      titleHindi: 'ध्वनि चेतना व अक्षर अनुरेखण',
      titleTribal: 'ᱥᱟᱰᱮ ᱵᱟᱰᱟᱭ ᱟᱨ ᱚᱞ ᱪᱤᱠᱤ ᱪᱤᱱᱦᱟᱹᱣ (Phonological & Tracing)',
      description: 'ध्वनि-प्रतीक सम्बद्धता समझना और ओल चिकी अक्षरों का सही दिशा में अनुरेखण करना।',
      competencyGoal: 'Lakshya 2: Effective Communicators (EC)',
    ),
    NipunOutcome(
      code: 'FLN-M1-01',
      grade: GradeLevel.balvatika,
      subject: SubjectArea.mathematics,
      titleHindi: 'संख्या बोध (१ से ५ की पहचान व गिनती)',
      titleTribal: 'ᱮᱞ ᱵᱟᱰᱟᱭ (᱑ ᱠᱷᱚᱱ ᱕ ᱞᱮᱠᱷᱟ)',
      description: 'मूर्त वस्तुओं को गिनकर सही संख्या प्रतीक (१, २, ३, ४, ५) से मिलान करना।',
      competencyGoal: 'Lakshya 3: Involved Learners (IL)',
    ),
    NipunOutcome(
      code: 'FLN-M1-02',
      grade: GradeLevel.class1,
      subject: SubjectArea.mathematics,
      titleHindi: 'गिनो और लिखो (संख्या ६ से १०)',
      titleTribal: 'ᱞᱮᱠᱷᱟᱭ ᱢᱮ ᱟᱨ ᱚᱞ ᱢᱮ (Numbers 6 to 10)',
      description: 'कक्षा में चित्रों व वस्तुओं की गिनती करके सही अंक लिखना।',
      competencyGoal: 'Lakshya 3: Involved Learners (IL)',
    ),
  ];

  static const List<WorksheetTemplate> predefinedWorksheets = [
    // --- WORKSHEET 1: COUNT AND MATCH (MATH) ---
    WorksheetTemplate(
      id: 'ws_math_01',
      titleHindi: 'गिनो और मिलाओ (संख्या १ से ५)',
      titleSanthali: 'ᱞᱮᱠᱷᱟᱭ ᱢᱮ ᱟᱨ ᱡᱚᱲᱟᱣ ᱢᱮ (᱑ - ᱕)',
      grade: GradeLevel.balvatika,
      subject: SubjectArea.mathematics,
      type: WorksheetType.countAndMatch,
      nipunOutcomeCode: 'FLN-M1-01',
      nipunOutcomeText: 'Recognizes numerals 1 to 5 and pairs them with correct quantities of objects.',
      items: [
        WorksheetExerciseItem(
          promptHindi: 'कितने हाथी हैं? (१ हाथी)',
          promptTribal: 'ᱛᱤᱱᱟᱹᱜ ᱦᱟᱛᱤ ᱢᱮᱱᱟᱜ ᱠᱚᱣᱟ? (ᱢᱤᱫ ᱦᱟᱛᱤ)',
          phoneticPrompt: 'Tinaag hati menak kowa? (Mit hati)',
          answerKey: '᱑ (ᱢᱤᱫ / १)',
          visualEmoji: '🐘',
          count: 1,
          options: ['᱑', '᱒', '᱓'],
        ),
        WorksheetExerciseItem(
          promptHindi: 'कितने पेड़ हैं? (२ पेड़)',
          promptTribal: 'ᱛᱤᱱᱟᱹᱜ ᱫᱟᱨᱮ ᱢᱮᱱᱟᱜ-ᱟ? (ᱵᱟᱨ ᱫᱟᱨᱮ)',
          phoneticPrompt: 'Tinaag dare menak-a? (Bar dare)',
          answerKey: '᱒ (ᱵᱟᱨ / २)',
          visualEmoji: '🌳',
          count: 2,
          options: ['᱑', '᱒', '᱔'],
        ),
        WorksheetExerciseItem(
          promptHindi: 'कितने सेब हैं? (३ सेब)',
          promptTribal: 'ᱛᱤᱱᱟᱹᱜ ᱥᱮᱣ ᱢᱮᱱᱟᱜ-ᱟ? (ᱯᱮ ᱥᱮᱣ)',
          phoneticPrompt: 'Tinaag sew menak-a? (Pe sew)',
          answerKey: '᱓ (ᱯᱮ / ३)',
          visualEmoji: '🍎',
          count: 3,
          options: ['᱒', '᱓', '᱕'],
        ),
        WorksheetExerciseItem(
          promptHindi: 'कितनी चिड़ियाँ हैं? (४ चिड़ियाँ)',
          promptTribal: 'ᱛᱤᱱᱟᱹᱜ ᱪᱮᱬᱮ ᱢᱮᱱᱟᱜ ᱠᱚᱣᱟ? (ᱯᱩᱱ ᱪᱮᱬᱮ)',
          phoneticPrompt: 'Tinaag chene menak kowa? (Pun chene)',
          answerKey: '᱔ (ᱯᱩᱱ / ४)',
          visualEmoji: '🐦',
          count: 4,
          options: ['᱓', '᱔', '᱕'],
        ),
        WorksheetExerciseItem(
          promptHindi: 'कितनी मछलियाँ हैं? (५ मछलियाँ)',
          promptTribal: 'ᱛᱤᱱᱟᱹᱜ ᱦᱟᱹᱠᱩ ᱢᱮᱱᱟᱜ ᱠᱚᱣᱟ? (ᱢᱚᱬᱮ ᱦᱟᱹᱠᱩ)',
          phoneticPrompt: 'Tinaag haku menak kowa? (Mone haku)',
          answerKey: '᱕ (ᱢᱚᱬᱮ / ५)',
          visualEmoji: '🐟',
          count: 5,
          options: ['᱒', '᱔', '᱕'],
        ),
      ],
    ),

    // --- WORKSHEET 2: PICTURE TO WORD MATCH (LANGUAGE) ---
    WorksheetTemplate(
      id: 'ws_lang_01',
      titleHindi: 'चित्र देखकर नाम से मिलाओ',
      titleSanthali: 'ᱪᱤᱛᱟᱹᱨ ᱧᱮᱞ ᱠᱟᱛᱮ ᱧᱩᱛᱩᱢ ᱡᱚᱲᱟᱣ ᱢᱮ',
      grade: GradeLevel.class1,
      subject: SubjectArea.language,
      type: WorksheetType.pictureWordAssociation,
      nipunOutcomeCode: 'FLN-L1-04',
      nipunOutcomeText: 'Matches environmental illustrations with bilingual written words (Hindi + Ol Chiki).',
      items: [
        WorksheetExerciseItem(
          promptHindi: 'हाथी (Elephant)',
          promptTribal: 'ᱦᱟᱛᱤ (Hati)',
          phoneticPrompt: 'हाती',
          answerKey: 'ᱦᱟᱛᱤ',
          visualEmoji: '🐘',
          options: ['ᱦᱟᱛᱤ', 'ᱫᱟᱨᱮ', 'ᱥᱮᱛᱟ'],
        ),
        WorksheetExerciseItem(
          promptHindi: 'पेड़ (Tree)',
          promptTribal: 'ᱫᱟᱨᱮ (Dare)',
          phoneticPrompt: 'दारे',
          answerKey: 'ᱫᱟᱨᱮ',
          visualEmoji: '🌳',
          options: ['ᱵᱟᱦᱟ', 'ᱫᱟᱨᱮ', 'ᱜᱟᱹᱭ'],
        ),
        WorksheetExerciseItem(
          promptHindi: 'गाय (Cow)',
          promptTribal: 'ᱜᱟᱹᱭ (Gai)',
          phoneticPrompt: 'गई',
          answerKey: 'ᱜᱟᱹᱭ',
          visualEmoji: '🐄',
          options: ['ᱛᱟᱹᱨᱩᱵ', 'ᱜᱟᱹᱭ', 'ᱦᱟᱹᱠᱩ'],
        ),
        WorksheetExerciseItem(
          promptHindi: 'फूल (Flower)',
          promptTribal: 'ᱵᱟᱦᱟ (Baha)',
          phoneticPrompt: 'बाहा',
          answerKey: 'ᱵᱟᱦᱟ',
          visualEmoji: '🌸',
          options: ['ᱵᱟᱦᱟ', 'ᱫᱟᱜ', 'ᱪᱮᱬᱮ'],
        ),
      ],
    ),

    // --- WORKSHEET 3: OL CHIKI TRACING & SOUND PRACTICE ---
    WorksheetTemplate(
      id: 'ws_trace_01',
      titleHindi: 'ओल चिकी अक्षर अनुरेखण व ध्वनि',
      titleSanthali: 'ᱚᱞ ᱪᱤᱠᱤ ᱟᱠᱷᱚᱨ ᱪᱤᱱᱦᱟᱹᱣ ᱟᱨ ᱚᱞ',
      grade: GradeLevel.class1,
      subject: SubjectArea.language,
      type: WorksheetType.tracing,
      nipunOutcomeCode: 'FLN-L2-01',
      nipunOutcomeText: 'Practices stroke order and phonemic association of basic Ol Chiki characters.',
      items: [
        WorksheetExerciseItem(
          promptHindi: 'अक्षर "ᱚ" (ओ / La)',
          promptTribal: 'ᱚᱞ (Ol - Writing / Letter)',
          phoneticPrompt: 'ओ (Ol)',
          answerKey: 'ᱚ',
          visualEmoji: '✏️',
          options: ['ᱚ', 'ᱛ', 'ᱜ'],
        ),
        WorksheetExerciseItem(
          promptHindi: 'अक्षर "ᱛ" (त / At)',
          promptTribal: 'ᱚᱛ (Ot - Earth / Soil)',
          phoneticPrompt: 'ओत (Ot)',
          answerKey: 'ᱛ',
          visualEmoji: '🌍',
          options: ['ᱛ', 'ᱞ', 'ᱟ'],
        ),
        WorksheetExerciseItem(
          promptHindi: 'अक्षर "ᱜ" (ग / Ag)',
          promptTribal: 'ᱚᱜ (Og - Vomit / Sound of crow)',
          phoneticPrompt: 'ओग (Og)',
          answerKey: 'ᱜ',
          visualEmoji: '🦅',
          options: ['ᱜ', 'ᱝ', 'ᱡ'],
        ),
      ],
    ),
  ];
}
