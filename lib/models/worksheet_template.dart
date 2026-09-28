import 'curriculum_item.dart';

enum WorksheetType {
  tracing,
  countAndMatch,
  pictureWordAssociation,
  oralAssessment,
}

class WorksheetExerciseItem {
  final String promptHindi;
  final String promptTribal;
  final String phoneticPrompt;
  final String answerKey;
  final String visualEmoji;
  final int count;
  final List<String> options;

  const WorksheetExerciseItem({
    required this.promptHindi,
    required this.promptTribal,
    required this.phoneticPrompt,
    required this.answerKey,
    required this.visualEmoji,
    this.count = 1,
    this.options = const [],
  });
}

class WorksheetTemplate {
  final String id;
  final String titleHindi;
  final String titleSanthali;
  final GradeLevel grade;
  final SubjectArea subject;
  final WorksheetType type;
  final String nipunOutcomeCode;
  final String nipunOutcomeText;
  final List<WorksheetExerciseItem> items;

  const WorksheetTemplate({
    required this.id,
    required this.titleHindi,
    required this.titleSanthali,
    required this.grade,
    required this.subject,
    required this.type,
    required this.nipunOutcomeCode,
    required this.nipunOutcomeText,
    required this.items,
  });
}
