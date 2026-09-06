/// Aura Pregnancy - Doktora Sorulacak Sorular Kasası Modeli
class DoctorQuestion {
  final int? id;
  final int pregnancyWeek;
  final int trimester; // 1, 2, 3
  final String question;
  final String? answerNote;
  final bool isAnswered;
  final bool isPredefined;
  final String createdDate;

  const DoctorQuestion({
    this.id,
    required this.pregnancyWeek,
    required this.trimester,
    required this.question,
    this.answerNote,
    this.isAnswered = false,
    this.isPredefined = false,
    required this.createdDate,
  });

  DoctorQuestion copyWith({
    int? id,
    int? pregnancyWeek,
    int? trimester,
    String? question,
    String? answerNote,
    bool? isAnswered,
    bool? isPredefined,
    String? createdDate,
  }) {
    return DoctorQuestion(
      id: id ?? this.id,
      pregnancyWeek: pregnancyWeek ?? this.pregnancyWeek,
      trimester: trimester ?? this.trimester,
      question: question ?? this.question,
      answerNote: answerNote ?? this.answerNote,
      isAnswered: isAnswered ?? this.isAnswered,
      isPredefined: isPredefined ?? this.isPredefined,
      createdDate: createdDate ?? this.createdDate,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'pregnancy_week': pregnancyWeek,
      'trimester': trimester,
      'question': question,
      'answer_note': answerNote,
      'is_answered': isAnswered ? 1 : 0,
      'is_predefined': isPredefined ? 1 : 0,
      'created_date': createdDate,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory DoctorQuestion.fromMap(Map<String, dynamic> map) {
    return DoctorQuestion(
      id: map['id'] as int?,
      pregnancyWeek: map['pregnancy_week'] as int? ?? 1,
      trimester: map['trimester'] as int? ?? 1,
      question: map['question'] as String,
      answerNote: map['answer_note'] as String?,
      isAnswered: (map['is_answered'] as int? ?? 0) == 1,
      isPredefined: (map['is_predefined'] as int? ?? 0) == 1,
      createdDate: map['created_date'] as String? ?? DateTime.now().toIso8601String(),
    );
  }
}
