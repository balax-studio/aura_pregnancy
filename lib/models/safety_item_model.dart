/// Aura Pregnancy - Besin ve Cilt Bakım Güvenlik Radarı Öğesi
enum SafetyLevel {
  safe,     // Güvenli (Yeşil)
  moderate, // Ölçülü / Şartlı (Sarı)
  unsafe,   // Sakıncalı / Kaçınılmalı (Kırmızı)
}

enum SafetyCategory {
  food,     // Besin & İçecek
  skincare, // Kozmetik & Cilt Bakımı
  herb,     // Bitki Çayı & Takviye
}

class SafetyItem {
  final String id;
  final String title;
  final String? titleEn;
  final SafetyCategory category;
  final SafetyLevel level;
  final String summary;
  final String? summaryEn;
  final String medicalReason;
  final String? medicalReasonEn;
  final String? alternativeSuggestion;
  final String? alternativeSuggestionEn;
  final String emoji;
  final bool isCravingFavorite;

  const SafetyItem({
    required this.id,
    required this.title,
    this.titleEn,
    required this.category,
    required this.level,
    required this.summary,
    this.summaryEn,
    required this.medicalReason,
    this.medicalReasonEn,
    this.alternativeSuggestion,
    this.alternativeSuggestionEn,
    required this.emoji,
    this.isCravingFavorite = false,
  });

  String localizedTitle(String lang) => (lang == 'en' && titleEn != null) ? titleEn! : title;
  String localizedSummary(String lang) => (lang == 'en' && summaryEn != null) ? summaryEn! : summary;
  String localizedMedicalReason(String lang) => (lang == 'en' && medicalReasonEn != null) ? medicalReasonEn! : medicalReason;
  String? localizedAlternative(String lang) => (lang == 'en' && alternativeSuggestionEn != null) ? alternativeSuggestionEn! : alternativeSuggestion;

  SafetyItem copyWith({
    String? id,
    String? title,
    String? titleEn,
    SafetyCategory? category,
    SafetyLevel? level,
    String? summary,
    String? summaryEn,
    String? medicalReason,
    String? medicalReasonEn,
    String? alternativeSuggestion,
    String? alternativeSuggestionEn,
    String? emoji,
    bool? isCravingFavorite,
  }) {
    return SafetyItem(
      id: id ?? this.id,
      title: title ?? this.title,
      titleEn: titleEn ?? this.titleEn,
      category: category ?? this.category,
      level: level ?? this.level,
      summary: summary ?? this.summary,
      summaryEn: summaryEn ?? this.summaryEn,
      medicalReason: medicalReason ?? this.medicalReason,
      medicalReasonEn: medicalReasonEn ?? this.medicalReasonEn,
      alternativeSuggestion: alternativeSuggestion ?? this.alternativeSuggestion,
      alternativeSuggestionEn: alternativeSuggestionEn ?? this.alternativeSuggestionEn,
      emoji: emoji ?? this.emoji,
      isCravingFavorite: isCravingFavorite ?? this.isCravingFavorite,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category.name,
      'level': level.name,
      'summary': summary,
      'medical_reason': medicalReason,
      'alternative_suggestion': alternativeSuggestion,
      'emoji': emoji,
      'is_craving_favorite': isCravingFavorite ? 1 : 0,
    };
  }

  factory SafetyItem.fromMap(Map<String, dynamic> map) {
    return SafetyItem(
      id: map['id'] as String,
      title: map['title'] as String,
      category: SafetyCategory.values.firstWhere(
        (c) => c.name == (map['category'] as String?),
        orElse: () => SafetyCategory.food,
      ),
      level: SafetyLevel.values.firstWhere(
        (l) => l.name == (map['level'] as String?),
        orElse: () => SafetyLevel.safe,
      ),
      summary: map['summary'] as String? ?? '',
      medicalReason: map['medical_reason'] as String? ?? '',
      alternativeSuggestion: map['alternative_suggestion'] as String?,
      emoji: map['emoji'] as String? ?? '🍽️',
      isCravingFavorite: (map['is_craving_favorite'] as int? ?? 0) == 1,
    );
  }
}
