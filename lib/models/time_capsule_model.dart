/// Aura Pregnancy - 18. Yaş Dijital Zaman Kapsülü Modeli
class TimeCapsuleLetter {
  final int? id;
  final String unlockMilestone; // '1st_birthday', '18th_birthday', 'wedding'
  final String title;
  final String letterText;
  final String? audioPath;
  final String? photoPath;
  final bool isSealed;
  final String createdDate;
  final String targetUnlockDate;

  const TimeCapsuleLetter({
    this.id,
    required this.unlockMilestone,
    required this.title,
    required this.letterText,
    this.audioPath,
    this.photoPath,
    this.isSealed = true,
    required this.createdDate,
    required this.targetUnlockDate,
  });

  TimeCapsuleLetter copyWith({
    int? id,
    String? unlockMilestone,
    String? title,
    String? letterText,
    String? audioPath,
    String? photoPath,
    bool? isSealed,
    String? createdDate,
    String? targetUnlockDate,
  }) {
    return TimeCapsuleLetter(
      id: id ?? this.id,
      unlockMilestone: unlockMilestone ?? this.unlockMilestone,
      title: title ?? this.title,
      letterText: letterText ?? this.letterText,
      audioPath: audioPath ?? this.audioPath,
      photoPath: photoPath ?? this.photoPath,
      isSealed: isSealed ?? this.isSealed,
      createdDate: createdDate ?? this.createdDate,
      targetUnlockDate: targetUnlockDate ?? this.targetUnlockDate,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'unlock_milestone': unlockMilestone,
      'title': title,
      'letter_text': letterText,
      'audio_path': audioPath,
      'photo_path': photoPath,
      'is_sealed': isSealed ? 1 : 0,
      'created_date': createdDate,
      'target_unlock_date': targetUnlockDate,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory TimeCapsuleLetter.fromMap(Map<String, dynamic> map) {
    return TimeCapsuleLetter(
      id: map['id'] as int?,
      unlockMilestone: map['unlock_milestone'] as String? ?? '18th_birthday',
      title: map['title'] as String? ?? '',
      letterText: map['letter_text'] as String? ?? '',
      audioPath: map['audio_path'] as String?,
      photoPath: map['photo_path'] as String?,
      isSealed: (map['is_sealed'] as int? ?? 1) == 1,
      createdDate: map['created_date'] as String? ?? DateTime.now().toIso8601String(),
      targetUnlockDate: map['target_unlock_date'] as String? ?? '',
    );
  }

  String get milestoneTitle {
    switch (unlockMilestone) {
      case '1st_birthday':
        return '1. Yaş Günü 🎂';
      case 'wedding':
        return 'Evlendiği Gün 💍';
      case '18th_birthday':
      default:
        return '18. Yaş Doğum Günü 🎓';
    }
  }
}
