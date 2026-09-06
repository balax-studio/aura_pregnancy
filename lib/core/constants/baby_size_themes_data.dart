/// Aura Pregnancy - 4 Boyut Teması (Meyve, Sevimli Hayvan, Pastane, Nostaljik Oyuncak)
class BabySizeThemeItem {
  final int week;
  final String title;
  final String emoji;
  final String description;
  final double lengthCm;
  final double weightGrams;

  const BabySizeThemeItem({
    required this.week,
    required this.title,
    required this.emoji,
    required this.description,
    required this.lengthCm,
    required this.weightGrams,
  });
}

enum BabySizeThemeType {
  fruit,    // Doğal Meyve & Sebzeler
  animal,   // Sevimli Yavru Hayvanlar
  pastry,   // Fransız Pastanesi & Tatlılar
  toy,      // Nostaljik Oyuncaklar
}

class BabySizeThemesData {
  static String getThemeTitle(BabySizeThemeType type) {
    switch (type) {
      case BabySizeThemeType.fruit:
        return 'Meyve & Sebze 🥑';
      case BabySizeThemeType.animal:
        return 'Sevimli Hayvanlar 🧸';
      case BabySizeThemeType.pastry:
        return 'Fransız Pastanesi 🥐';
      case BabySizeThemeType.toy:
        return 'Nostaljik Oyuncak 🚂';
    }
  }

  static BabySizeThemeItem getItemForWeek(int week, BabySizeThemeType type) {
    final clampedWeek = week.clamp(1, 40);
    switch (type) {
      case BabySizeThemeType.animal:
        return _animalSizes[clampedWeek] ?? _animalSizes[40]!;
      case BabySizeThemeType.pastry:
        return _pastrySizes[clampedWeek] ?? _pastrySizes[40]!;
      case BabySizeThemeType.toy:
        return _toySizes[clampedWeek] ?? _toySizes[40]!;
      case BabySizeThemeType.fruit:
        return _fruitSizes[clampedWeek] ?? _fruitSizes[40]!;
    }
  }

  // 1. Meyve & Sebzeler
  static final Map<int, BabySizeThemeItem> _fruitSizes = {
    1: const BabySizeThemeItem(week: 1, title: 'Henüz Minik Bir Hücre', emoji: '✨', description: 'Mucizevi yolculuk başlıyor.', lengthCm: 0.1, weightGrams: 0.1),
    2: const BabySizeThemeItem(week: 2, title: 'Döllenmiş Hücre', emoji: '🌟', description: 'Genetik kodlar yazılıyor.', lengthCm: 0.15, weightGrams: 0.1),
    3: const BabySizeThemeItem(week: 3, title: 'Küçük Bir Tohum', emoji: '🌱', description: 'Rahme tutunma gerçekleşiyor.', lengthCm: 0.2, weightGrams: 0.2),
    4: const BabySizeThemeItem(week: 4, title: 'Haşhaş Tohumu', emoji: '🌾', description: 'Embriyo katmanları oluşuyor.', lengthCm: 0.36, weightGrams: 0.5),
    5: const BabySizeThemeItem(week: 5, title: 'Susam Tanesi', emoji: '🌰', description: 'Minik kalp tüpü atmaya başladı.', lengthCm: 0.5, weightGrams: 1.0),
    6: const BabySizeThemeItem(week: 6, title: 'Mercimek Tanesi', emoji: '🫘', description: 'Burun ve kulak tomurcukları beliriyor.', lengthCm: 0.8, weightGrams: 1.5),
    7: const BabySizeThemeItem(week: 7, title: 'Yaban Mersini', emoji: '🫐', description: 'Eller ve minik parmak uçları şekilleniyor.', lengthCm: 1.3, weightGrams: 2.0),
    8: const BabySizeThemeItem(week: 8, title: 'Ahududu', emoji: '🍇', description: 'Minik ayak parmakları ve retina beliriyor.', lengthCm: 1.6, weightGrams: 3.0),
    9: const BabySizeThemeItem(week: 9, title: 'Yeşil Zeytin', emoji: '🫒', description: 'Artık embriyo değil, resmi olarak fetus.', lengthCm: 2.3, weightGrams: 4.0),
    10: const BabySizeThemeItem(week: 10, title: 'Kuru Erik', emoji: '🫐', description: 'Tırnak yatakları ve minik eklemler aktif.', lengthCm: 3.1, weightGrams: 7.0),
    11: const BabySizeThemeItem(week: 11, title: 'İncir', emoji: '🪴', description: 'Esneme ve gerinme hareketleri başladı.', lengthCm: 4.1, weightGrams: 14.0),
    12: const BabySizeThemeItem(week: 12, title: 'Misket Limonu', emoji: '🍋', description: 'Refleksler uyanıyor, parmaklar kıvrılıyor.', lengthCm: 5.4, weightGrams: 20.0),
    13: const BabySizeThemeItem(week: 13, title: 'Limon', emoji: '🍋', description: '1. Trimester tamamlandı, ses telleri oluşuyor.', lengthCm: 7.4, weightGrams: 30.0),
    14: const BabySizeThemeItem(week: 14, title: 'Şeftali', emoji: '🍑', description: 'Yüz ifadeleri yapabiliyor, kaş çatabiliyor.', lengthCm: 8.7, weightGrams: 45.0),
    15: const BabySizeThemeItem(week: 15, title: 'Elma', emoji: '🍎', description: 'Kemikleri sertleşiyor, ışığı algılayabiliyor.', lengthCm: 10.1, weightGrams: 70.0),
    16: const BabySizeThemeItem(week: 16, title: 'Avokado', emoji: '🥑', description: 'Kalbi günde 25 litre kan pompalıyor.', lengthCm: 11.6, weightGrams: 100.0),
    17: const BabySizeThemeItem(week: 17, title: 'Nar', emoji: '🫐', description: 'Yağ dokusu (kahverengi yağ) depolanıyor.', lengthCm: 13.0, weightGrams: 140.0),
    18: const BabySizeThemeItem(week: 18, title: 'Enginar', emoji: '🥬', description: 'Kulakları annenin sesini ve nabzını duyuyor.', lengthCm: 14.2, weightGrams: 190.0),
    19: const BabySizeThemeItem(week: 19, title: 'Mango', emoji: '🥭', description: 'Beyninde 5 duyu alanı haritalanıyor.', lengthCm: 15.3, weightGrams: 240.0),
    20: const BabySizeThemeItem(week: 20, title: 'Muz', emoji: '🍌', description: 'Yolun yarısı tamamlandı! Vernix tabakası sarıyor.', lengthCm: 25.6, weightGrams: 300.0),
    21: const BabySizeThemeItem(week: 21, title: 'Büyük Havuç', emoji: '🥕', description: 'Yuttuğu amniyotik sıvının tadını alabiliyor.', lengthCm: 26.7, weightGrams: 360.0),
    22: const BabySizeThemeItem(week: 22, title: 'Hindistan Cevizi', emoji: '🥥', description: 'Dokunma hissi ve minik kavrama refleksi.', lengthCm: 27.8, weightGrams: 430.0),
    23: const BabySizeThemeItem(week: 23, title: 'Greyfurt', emoji: '🍊', description: 'Akciğerlerinde sürfaktan üretimi başladı.', lengthCm: 28.9, weightGrams: 500.0),
    24: const BabySizeThemeItem(week: 24, title: 'Mısır Koçanı', emoji: '🌽', description: 'Yaşama sınırı (viability) aşıldı, minik kirpikler.', lengthCm: 30.0, weightGrams: 600.0),
    25: const BabySizeThemeItem(week: 25, title: 'Karnabahar', emoji: '🥦', description: 'Seslere irkilme refleksiyle yanıt veriyor.', lengthCm: 34.6, weightGrams: 660.0),
    26: const BabySizeThemeItem(week: 26, title: 'Kıvırcık Marul', emoji: '🥬', description: 'Gözlerini ilk kez aralamaya başladı.', lengthCm: 35.6, weightGrams: 760.0),
    27: const BabySizeThemeItem(week: 27, title: 'Brokoli', emoji: '🥦', description: '2. Trimester bitti, hıçkırıkları hissedebilirsiniz.', lengthCm: 36.6, weightGrams: 875.0),
    28: const BabySizeThemeItem(week: 28, title: 'Patlıcan', emoji: '🍆', description: 'Rüya görebiliyor (REM uykusu), çanta hazırlığı.', lengthCm: 37.6, weightGrams: 1000.0),
    29: const BabySizeThemeItem(week: 29, title: 'Balkabağı', emoji: '🎃', description: 'Kemik iliği kırmızı kan hücreleri üretiyor.', lengthCm: 38.6, weightGrams: 1150.0),
    30: const BabySizeThemeItem(week: 30, title: 'Lahana', emoji: '🥬', description: 'Kendi vücut ısısını kontrol etmeye başladı.', lengthCm: 39.9, weightGrams: 1320.0),
    31: const BabySizeThemeItem(week: 31, title: 'Ananas', emoji: '🍍', description: 'Göz bebekleri ışığa göre küçülüp büyüyor.', lengthCm: 41.1, weightGrams: 1500.0),
    32: const BabySizeThemeItem(week: 32, title: 'Kavun', emoji: '🍈', description: 'El ve ayak tırnakları tamamen uzadı.', lengthCm: 42.4, weightGrams: 1700.0),
    33: const BabySizeThemeItem(week: 33, title: 'Kereviz Kökü', emoji: '🥔', description: 'Bağışıklık antikorları anneden bebeğe geçiyor.', lengthCm: 43.7, weightGrams: 1900.0),
    34: const BabySizeThemeItem(week: 34, title: 'Sarı Kavun', emoji: '🍈', description: 'Akciğerleri neredeyse tamamen hazır.', lengthCm: 45.0, weightGrams: 2150.0),
    35: const BabySizeThemeItem(week: 35, title: 'Bal Kabağı Dilimi', emoji: '🎃', description: 'Böbrekleri tamamen olgunlaştı.', lengthCm: 46.2, weightGrams: 2380.0),
    36: const BabySizeThemeItem(week: 36, title: 'Pazı Demeti', emoji: '🥬', description: 'Her gün yaklaşık 30 gram yağ depoluyor.', lengthCm: 47.4, weightGrams: 2600.0),
    37: const BabySizeThemeItem(week: 37, title: 'Karpuz Dilimi', emoji: '🍉', description: 'Erken vadeli (early term) güvenli doğum eşiği.', lengthCm: 48.6, weightGrams: 2850.0),
    38: const BabySizeThemeItem(week: 38, title: 'Kış Kabağı', emoji: '🎃', description: 'Organları bağımsız yaşama tamamen hazır.', lengthCm: 49.8, weightGrams: 3080.0),
    39: const BabySizeThemeItem(week: 39, title: 'Mini Karpuz', emoji: '🍉', description: 'Tam vadeli (full term), kavuşma an meselesi.', lengthCm: 50.7, weightGrams: 3300.0),
    40: const BabySizeThemeItem(week: 40, title: 'Büyük Karpuz', emoji: '🍉', description: 'Kollarına almaya hazırsın, mucize burada!', lengthCm: 51.2, weightGrams: 3460.0),
  };

  // 2. Sevimli Yavru Hayvanlar
  static final Map<int, BabySizeThemeItem> _animalSizes = {
    4: const BabySizeThemeItem(week: 4, title: 'Uğur Böceği', emoji: '🐞', description: 'Minicik ve çok şanslı bir başlangıç.', lengthCm: 0.36, weightGrams: 0.5),
    8: const BabySizeThemeItem(week: 8, title: 'Yavru Arı', emoji: '🐝', description: 'Kalbi arı kanadı gibi pıt pıt atıyor.', lengthCm: 1.6, weightGrams: 3.0),
    12: const BabySizeThemeItem(week: 12, title: 'Kutup Ayısı Yavrusu Patisi', emoji: '🐾', description: 'Minik parmak uçları dokunmaya hazır.', lengthCm: 5.4, weightGrams: 20.0),
    16: const BabySizeThemeItem(week: 16, title: 'Yavru Sincap', emoji: '🐿️', description: 'Karnında tatlı taklalar atan sevimli sincap.', lengthCm: 11.6, weightGrams: 100.0),
    20: const BabySizeThemeItem(week: 20, title: 'Pamuk Kuyruk Tavşancık', emoji: '🐰', description: 'Kulakları artık anne ve babanın sesini tanıyor.', lengthCm: 25.6, weightGrams: 300.0),
    24: const BabySizeThemeItem(week: 24, title: 'Yavru Kirpi', emoji: '🦔', description: 'Kıvrılıp uyuyan huzurlu bir melek.', lengthCm: 30.0, weightGrams: 600.0),
    28: const BabySizeThemeItem(week: 28, title: 'Deniz Samuru Yavrusu', emoji: '🦦', description: 'Amniyotik suda neşeyle yüzen minik kaşif.', lengthCm: 37.6, weightGrams: 1000.0),
    32: const BabySizeThemeItem(week: 32, title: 'Yavru Koala', emoji: '🐨', description: 'Anneye sarılmak için sabırsızlanan tatlı koala.', lengthCm: 42.4, weightGrams: 1700.0),
    36: const BabySizeThemeItem(week: 36, title: 'Tonton Panda Yavrusu', emoji: '🐼', description: 'Tombul yanakları ve sevimli göbüşü hazır.', lengthCm: 47.4, weightGrams: 2600.0),
    40: const BabySizeThemeItem(week: 40, title: 'Yavru Aslancık', emoji: '🦁', description: 'Cesur, sevgi dolu ve kollarına atılmaya hazır!', lengthCm: 51.2, weightGrams: 3460.0),
  };

  // 3. Fransız Pastanesi & Tatlılar
  static final Map<int, BabySizeThemeItem> _pastrySizes = {
    4: const BabySizeThemeItem(week: 4, title: 'Pasta Süsü İncisi', emoji: '🧁', description: 'Minik tatlı bir lezzet tanesi.', lengthCm: 0.36, weightGrams: 0.5),
    8: const BabySizeThemeItem(week: 8, title: 'Fıstıklı Draje', emoji: '🍬', description: 'Draje gibi tatlı ve narin kalpli.', lengthCm: 1.6, weightGrams: 3.0),
    12: const BabySizeThemeItem(week: 12, title: 'Renkli Makaron', emoji: '🥮', description: 'Dışı çıtır içi yumuşacık bir makaron boyutu.', lengthCm: 5.4, weightGrams: 20.0),
    16: const BabySizeThemeItem(week: 16, title: 'Kremalı Profiterol', emoji: '🍮', description: 'Karnında tatlı tatlı büyüyen lezzet küpü.', lengthCm: 11.6, weightGrams: 100.0),
    20: const BabySizeThemeItem(week: 20, title: 'Tereyağlı Kruvasan', emoji: '🥐', description: 'Kıvrılmış pofuduk bir kruvasan gibi dinleniyor.', lengthCm: 25.6, weightGrams: 300.0),
    24: const BabySizeThemeItem(week: 24, title: 'Çilekli Tart', emoji: '🥧', description: 'Aşkla mayalanan tatlı mı tatlı bir meyveli tart.', lengthCm: 30.0, weightGrams: 600.0),
    28: const BabySizeThemeItem(week: 28, title: 'Fırından Taze Baget', emoji: '🥖', description: 'Upuzun ve çıtır bir Paris bageti boyutu.', lengthCm: 37.6, weightGrams: 1000.0),
    32: const BabySizeThemeItem(week: 32, title: 'Kraliyet Pavlova Pastası', emoji: '🍰', description: 'Hafif, kabarık ve bulut gibi beze pastası.', lengthCm: 42.4, weightGrams: 1700.0),
    36: const BabySizeThemeItem(week: 36, title: 'Çikolatalı Brioche Ekmeği', emoji: '🍞', description: 'Kabarık, yumuşacık ve sıcacık bir ekmek gibi.', lengthCm: 47.4, weightGrams: 2600.0),
    40: const BabySizeThemeItem(week: 40, title: '3 Katlı Kutlama Pastası', emoji: '🎂', description: 'Hayatının en büyük ve tatlı kutlaması hazır!', lengthCm: 51.2, weightGrams: 3460.0),
  };

  // 4. Nostaljik Oyuncaklar
  static final Map<int, BabySizeThemeItem> _toySizes = {
    4: const BabySizeThemeItem(week: 4, title: 'Cam Misket', emoji: '🔮', description: 'Avuç içinde saklanan parlak bir rüya misketi.', lengthCm: 0.36, weightGrams: 0.5),
    8: const BabySizeThemeItem(week: 8, title: 'Ahşap Zar', emoji: '🎲', description: 'Şansın ve sevginin en güzel zarı.', lengthCm: 1.6, weightGrams: 3.0),
    12: const BabySizeThemeItem(week: 12, title: 'Rengarenk Yoyo', emoji: '🪀', description: 'Yaylanan ve neşeyle dönen bir oyuncak.', lengthCm: 5.4, weightGrams: 20.0),
    16: const BabySizeThemeItem(week: 16, title: 'Kurmalı Teneke Araba', emoji: '🚗', description: 'Merakla keşfe çıkan minik nostaljik araba.', lengthCm: 11.6, weightGrams: 100.0),
    20: const BabySizeThemeItem(week: 20, title: 'Nostaljik Müzik Kutusu', emoji: '📻', description: 'Kapağı açıldığında ninni çalan sihirli kutu.', lengthCm: 25.6, weightGrams: 300.0),
    24: const BabySizeThemeItem(week: 24, title: 'Ahşap Tren Lokomotifi', emoji: '🚂', description: 'Çuf çuf atan ritmik ve güçlü kalbiyle yolda.', lengthCm: 30.0, weightGrams: 600.0),
    28: const BabySizeThemeItem(week: 28, title: 'Bez Bebek', emoji: '🎎', description: 'Kollarında sevgiyle sarılacağın el emeği bebek.', lengthCm: 37.6, weightGrams: 1000.0),
    32: const BabySizeThemeItem(week: 32, title: 'Sallanan Ahşap At', emoji: '🎠', description: 'Rüyalarında neşeyle dörtnala koşan süvari.', lengthCm: 42.4, weightGrams: 1700.0),
    36: const BabySizeThemeItem(week: 36, title: 'Nostaljik Peluş Ayıcık', emoji: '🧸', description: 'Pofuduk, sıcacık ve kucaklanmaya hazır dost.', lengthCm: 47.4, weightGrams: 2600.0),
    40: const BabySizeThemeItem(week: 40, title: 'Kocaman Sarılma Ayısı', emoji: '🧸', description: 'Ömür boyu en yakın arkadaşın artık yanında!', lengthCm: 51.2, weightGrams: 3460.0),
  };
}
