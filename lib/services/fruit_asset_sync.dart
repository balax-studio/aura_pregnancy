/// Aura Pregnancy - 3D Claymorphic Meyve & Sebze Görsel Eşleştirici
/// %100 Web, Mobil ve Masaüstü Uyumlu (Saf Dart)
class Fruit3DAssetManager {
  /// Haftaya göre 3D meyve anahtarını döndürür
  static String getFruitKeyForWeek(int week) {
    switch (week) {
      case 1: return 'seed';
      case 2: return 'sesame';
      case 3: return 'peppercorn';
      case 4: return 'pomegranate_seed';
      case 5: return 'lentil';
      case 6: return 'pea';
      case 7: return 'blueberry';
      case 8: return 'raspberry';
      case 9: return 'olive';
      case 10: return 'strawberry';
      case 11: return 'lime';
      case 12: return 'plum';
      case 13: return 'lemon';
      case 14: return 'peach';
      case 15: return 'apple';
      case 16: return 'avocado';
      case 17: return 'pear';
      case 18: return 'sweet_potato';
      case 19: return 'mango';
      case 20: return 'banana';
      case 21: return 'carrot';
      case 22: return 'papaya';
      case 23: return 'eggplant';
      case 24: return 'corn';
      case 25: return 'cauliflower';
      case 26: return 'zucchini';
      case 27: return 'broccoli';
      case 28: return 'squash';
      case 29: return 'butternut_squash';
      case 30: return 'cabbage';
      case 31: return 'coconut';
      case 32: return 'bok_choy';
      case 33: return 'pineapple';
      case 34: return 'melon';
      case 35: return 'pumpkin';
      case 36: return 'lettuce';
      case 37: return 'swiss_chard';
      case 38: return 'celery';
      case 39: return 'mini_watermelon';
      case 40: return 'watermelon';
      default: return 'seed';
    }
  }

  /// 11 aşamalı serüven için index'e göre 3D meyve anahtarını döndürür
  static String getFruitKeyForStageIndex(int index) {
    switch (index) {
      case 0: return 'seed';
      case 1: return 'blueberry';
      case 2: return 'strawberry';
      case 3: return 'lemon';
      case 4: return 'avocado';
      case 5: return 'banana';
      case 6: return 'corn';
      case 7: return 'coconut';
      case 8: return 'pineapple';
      case 9: return 'melon';
      case 10: return 'watermelon';
      default: return 'avocado';
    }
  }

  /// Belirtilen meyve anahtarı için 3D görsel dosya yolunu döndürür
  static String getAssetImagePath(String fruitKey) {
    if (fruitKey == 'sweet_potato') {
      return 'assets/images/fruit_carrot.jpg';
    }
    return 'assets/images/fruit_$fruitKey.jpg';
  }
}
