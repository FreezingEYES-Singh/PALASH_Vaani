enum SyncStatus {
  pendingOfflineSync,
  syncedWithCRC,
}

class FeedbackRecord {
  final String id;
  final String sourceHindi;
  final String generatedTribal;
  final String correctedTribal;
  final String teacherNotes;
  final String district;
  final String language;
  final SyncStatus status;
  final DateTime createdAt;

  const FeedbackRecord({
    required this.id,
    required this.sourceHindi,
    required this.generatedTribal,
    required this.correctedTribal,
    required this.teacherNotes,
    required this.district,
    required this.language,
    this.status = SyncStatus.pendingOfflineSync,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'sourceHindi': sourceHindi,
    'generatedTribal': generatedTribal,
    'correctedTribal': correctedTribal,
    'teacherNotes': teacherNotes,
    'district': district,
    'language': language,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
  };
}
