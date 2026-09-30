import '../services/pregnancy_progress.dart';

/// Aura Pregnancy - Gebelik Profili Modeli (Anne, Bebek İsmi ve Cinsiyet Destekli)
class ProfileModel {
  final int? id;
  final String dueDate; // Tahmini Doğum Tarihi (YYYY-MM-DD)
  final String? lmpDate; // Son Adet Tarihi (SAT) (YYYY-MM-DD)
  final double prePregnancyWeight; // Hamilelik öncesi kilo (kg)
  final double height; // Boy (cm)
  final double vki; // Vücut Kitle İndeksi (Kilo / (Boy/100)^2)
  final int currentWeek; // Mevcut gebelik haftası (1-40)
  final String? momName; // Anne İsmi (Örn: Elif)
  final String? partnerName; // Baba / Eş İsmi (Örn: Emre)
  final String? babyName; // Bebeğin İsmi (Örn: Ayşe, Mehmet, Mavi)
  final String? babyGender; // Bebeğin Cinsiyeti ('girl', 'boy', 'surprise')

  ProfileModel({
    this.id,
    required this.dueDate,
    this.lmpDate,
    required this.prePregnancyWeight,
    required this.height,
    required this.vki,
    required this.currentWeek,
    this.momName,
    this.partnerName,
    this.babyName,
    this.babyGender = 'surprise',
  });

  /// Map'ten Model Üretici (Geriye dönük tam uyumlu)
  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] as int?,
      dueDate: map['due_date'] as String,
      lmpDate: map['lmp_date'] as String?,
      prePregnancyWeight: (map['pre_pregnancy_weight'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      vki: (map['vki'] as num).toDouble(),
      currentWeek: map['current_week'] as int,
      momName: map['mom_name'] as String?,
      partnerName: map['partner_name'] as String?,
      babyName: map['baby_name'] as String?,
      babyGender: (map['baby_gender'] as String?) ?? 'surprise',
    );
  }

  /// Veritabanı için Map Dönüşümü
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'due_date': dueDate,
      'pre_pregnancy_weight': prePregnancyWeight,
      'height': height,
      'vki': vki,
      'current_week': currentWeek,
      'mom_name': momName,
      'partner_name': partnerName,
      'baby_name': babyName,
      'baby_gender': babyGender ?? 'surprise',
    };
    if (id != null) {
      map['id'] = id;
    }
    if (lmpDate != null) {
      map['lmp_date'] = lmpDate;
    }
    return map;
  }

  /// Bebeğin Uygulama İçi Hitap Adı (Örn: "Ayşe Bebek" veya "Bebeğiniz")
  String get babyDisplayName {
    if (babyName != null && babyName!.trim().isNotEmpty) {
      return '${babyName!.trim()} Bebek';
    }
    return 'Bebeğiniz';
  }

  /// Runtime age comes from the saved dates. [currentWeek] remains the stored
  /// snapshot so existing database records keep their original value.
  PregnancyProgress get pregnancyProgress => PregnancyProgress.fromDateStrings(
        lmpDate: lmpDate,
        dueDate: dueDate,
        fallbackWeek: currentWeek,
      );

  int get currentPregnancyWeek => pregnancyProgress.displayWeek;

  /// Bebeğin Sade Adı (Örn: "Ayşe" veya "Bebeğiniz")
  String get babySimpleName {
    if (babyName != null && babyName!.trim().isNotEmpty) {
      return babyName!.trim();
    }
    return 'Bebeğiniz';
  }

  /// Cinsiyet Emojisi
  String get genderEmoji {
    switch (babyGender?.toLowerCase()) {
      case 'girl':
        return '👧';
      case 'boy':
        return '👦';
      default:
        return '💛';
    }
  }

  /// Cinsiyet Başlığı
  String get genderTitle {
    switch (babyGender?.toLowerCase()) {
      case 'girl':
        return 'Kız Bebek 👧';
      case 'boy':
        return 'Erkek Bebek 👦';
      default:
        return 'Sürpriz / Henüz Belli Değil 💛';
    }
  }

  /// VKİ Sınıflandırması
  String get vkiCategoryKey {
    if (vki < 18.5) return 'Underweight';
    if (vki < 25.0) return 'Normal';
    if (vki < 30.0) return 'Overweight';
    return 'Obese';
  }

  /// Trimester follows the current date-derived pregnancy progress.
  int get trimester => pregnancyProgress.trimester;

  ProfileModel copyWith({
    int? id,
    String? dueDate,
    String? lmpDate,
    double? prePregnancyWeight,
    double? height,
    double? vki,
    int? currentWeek,
    String? momName,
    String? partnerName,
    String? babyName,
    String? babyGender,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      dueDate: dueDate ?? this.dueDate,
      lmpDate: lmpDate ?? this.lmpDate,
      prePregnancyWeight: prePregnancyWeight ?? this.prePregnancyWeight,
      height: height ?? this.height,
      vki: vki ?? this.vki,
      currentWeek: currentWeek ?? this.currentWeek,
      momName: momName ?? this.momName,
      partnerName: partnerName ?? this.partnerName,
      babyName: babyName ?? this.babyName,
      babyGender: babyGender ?? this.babyGender,
    );
  }
}
