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
  final SafetyCategory category;
  final SafetyLevel level;
  final String summary;
  final String medicalReason;
  final String? alternativeSuggestion;
  final String emoji;
  final bool isCravingFavorite;

  const SafetyItem({
    required this.id,
    required this.title,
    required this.category,
    required this.level,
    required this.summary,
    required this.medicalReason,
    this.alternativeSuggestion,
    required this.emoji,
    this.isCravingFavorite = false,
  });

  SafetyItem copyWith({
    String? id,
    String? title,
    SafetyCategory? category,
    SafetyLevel? level,
    String? summary,
    String? medicalReason,
    String? alternativeSuggestion,
    String? emoji,
    bool? isCravingFavorite,
  }) {
    return SafetyItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      level: level ?? this.level,
      summary: summary ?? this.summary,
      medicalReason: medicalReason ?? this.medicalReason,
      alternativeSuggestion: alternativeSuggestion ?? this.alternativeSuggestion,
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
