/// Aura Pregnancy - Bebek Burç ve Mizaç Analizi Modeli
class BabyZodiacModel {
  final String signName;
  final String symbol;
  final String element; // 'Ateş', 'Toprak', 'Hava', 'Su'
  final String modality; // 'Öncü', 'Sabit', 'Değişken'
  final String dateRangeStr;
  final String headline;
  final String temperament;
  final String sleepTendency;
  final String emotionalNeeds;
  final String parentingAdvice;
  final bool isCusp;
  final String? cuspNotice;
  final List<String> luckyColors;
  final String gemStone;

  const BabyZodiacModel({
    required this.signName,
    required this.symbol,
    required this.element,
    required this.modality,
    required this.dateRangeStr,
    required this.headline,
    required this.temperament,
    required this.sleepTendency,
    required this.emotionalNeeds,
    required this.parentingAdvice,
    this.isCusp = false,
    this.cuspNotice,
    required this.luckyColors,
    required this.gemStone,
  });

  String get elementEmoji {
    switch (element) {
      case 'Ateş':
        return '🔥';
      case 'Toprak':
        return '🌍';
      case 'Hava':
        return '💨';
      case 'Su':
      default:
        return '💧';
    }
  }
}
