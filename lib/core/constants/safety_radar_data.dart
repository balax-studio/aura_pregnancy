import '../../models/safety_item_model.dart';

/// Aura Pregnancy - Besin, Kozmetik ve Bitkisel Güvenlik Radarı Veritabanı
class SafetyRadarData {
  static const List<SafetyItem> items = [
    // --- GIDALAR: GÜVENLİ (YEŞİL) ---
    SafetyItem(
      id: 'food_cooked_salmon',
      title: 'İyi Pişmiş Somon',
      category: SafetyCategory.food,
      level: SafetyLevel.safe,
      summary: 'Gönül rahatlığıyla haftada 2-3 porsiyon tüketilebilir.',
      medicalReason: 'Yüksek Omega-3 (DHA/EPA) bebeğin beyin ve retina gelişimini destekler. Düşük cıvalı balıktır.',
      alternativeSuggestion: 'Fırında zeytinyağlı ve limonlu pişirebilirsiniz.',
      emoji: '🐟',
    ),
    SafetyItem(
      id: 'food_pasteurized_cheese',
      title: 'Pastörize Beyaz Peynir / Kaşar',
      category: SafetyCategory.food,
      level: SafetyLevel.safe,
      summary: 'Pastörize sütten üretildiği sürece güvenlidir.',
      medicalReason: 'Kalsiyum ve protein deposudur. Pastörizasyon listeria bakterisi riskini sıfırlar.',
      emoji: '🧀',
    ),
    SafetyItem(
      id: 'food_pasteurized_yogurt',
      title: 'Yoğurt & Kefir',
      category: SafetyCategory.food,
      level: SafetyLevel.safe,
      summary: 'Mükemmel probiyotik ve kalsiyum kaynağıdır.',
      medicalReason: 'Gebelikte bağırsak mikrobiyotasını korur, kabızlığı önler.',
      emoji: '🥣',
    ),
    SafetyItem(
      id: 'food_hard_boiled_egg',
      title: 'Tam Pişmiş Yumurta',
      category: SafetyCategory.food,
      level: SafetyLevel.safe,
      summary: 'Sarısı ve beyazı katılaşana kadar pişirilmelidir.',
      medicalReason: 'Zengin kolin içeriği fetal nöral tüp ve beyin gelişiminde kilit rol oynar.',
      emoji: '🥚',
    ),
    SafetyItem(
      id: 'food_avocado',
      title: 'Avokado',
      category: SafetyCategory.food,
      level: SafetyLevel.safe,
      summary: 'Sağlıklı yağlar ve folat açısından süper besindir.',
      medicalReason: 'Potasyum içeriği bacak kramplarını azaltmaya yardımcı olur.',
      emoji: '🥑',
    ),
    SafetyItem(
      id: 'food_oats',
      title: 'Yulaf Ezmesi',
      category: SafetyCategory.food,
      level: SafetyLevel.safe,
      summary: 'Kompleks karbonhidrat ve lif zenginidir.',
      medicalReason: 'Kan şekerini dengeler, gebelik şekeri (gestasyonel diyabet) riskini azaltır.',
      emoji: '🌾',
    ),

    // --- GIDALAR: ÖLÇÜLÜ / ŞARTLI (SARI) ---
    SafetyItem(
      id: 'food_canned_tuna',
      title: 'Konserve Ton Balığı',
      category: SafetyCategory.food,
      level: SafetyLevel.moderate,
      summary: 'Haftada en fazla 140-170 gram (1 küçük kutu) ile sınırlandırın.',
      medicalReason: 'Hafif cıva birikimi riski taşır. Açık renkli (light) ton balığı tercih edin.',
      alternativeSuggestion: 'Taze hamsi, sardalya veya somon tercih edebilirsiniz.',
      emoji: '🥫',
    ),
    SafetyItem(
      id: 'food_coffee',
      title: 'Kahve & Kafein',
      category: SafetyCategory.food,
      level: SafetyLevel.moderate,
      summary: 'Günlük kafein tüketimi 200 mg altında kalmalıdır (1 kupa filtre kahve veya 1 fincan Türk kahvesi).',
      medicalReason: 'Aşırı kafein plasentayı geçerek fetal kalp ritmini hızlandırabilir ve demir emilimini azaltır.',
      alternativeSuggestion: 'Kafeinsiz (Decaf) kahve veya ılık ballı süt tercih edin.',
      emoji: '☕',
    ),
    SafetyItem(
      id: 'food_green_tea',
      title: 'Yeşil Çay',
      category: SafetyCategory.food,
      level: SafetyLevel.moderate,
      summary: 'Günde en fazla 1 fincan içilmelidir.',
      medicalReason: 'İçerdiği EGCG kateşini folik asit emilimini kısmen baskılayabilir.',
      alternativeSuggestion: 'Ihlamur veya rooibos çayı güvenlidir.',
      emoji: '🍵',
    ),
    SafetyItem(
      id: 'food_parsley',
      title: 'Maydanoz (Çiğ Salata)',
      category: SafetyCategory.food,
      level: SafetyLevel.moderate,
      summary: 'Yemek ve salatalarda süsleme olarak güvenlidir; kaynatıp suyunu içmekten kaçının.',
      medicalReason: 'Yoğun maydanoz suyu konsantresi apiole maddesi nedeniyle rahim kasılmalarını tetikleyebilir.',
      emoji: '🌿',
    ),

    // --- GIDALAR: SAKINCALI (KIRMIZI) ---
    SafetyItem(
      id: 'food_raw_meat_cigkofte',
      title: 'Çiğ Köfte / Çiğ Et',
      category: SafetyCategory.food,
      level: SafetyLevel.unsafe,
      summary: 'Etli çiğ köfte, tartar ve az pişmiş biftek kesinlikle tüketilmemelidir.',
      medicalReason: 'Toksoplazmozis ve Salmonella enfeksiyonu riski taşır; bebekte görme ve beyin hasarına yol açabilir.',
      alternativeSuggestion: 'Etsiz cevizli çiğ köfte veya iyi pişmiş köfte güvenle tüketilebilir.',
      emoji: '🥩',
    ),
    SafetyItem(
      id: 'food_sushi_raw_fish',
      title: 'Çiğ Suşi / Çiğ Deniz Ürünleri',
      category: SafetyCategory.food,
      level: SafetyLevel.unsafe,
      summary: 'Çiğ somon, ton balığı, midye dolma ve istiridye tüketilmemelidir.',
      medicalReason: 'Listeria monocytogenes bakterisi ve parazit riski düşüğe ve erken doğuma neden olabilir.',
      alternativeSuggestion: 'Pişmiş karidesli sushi roll veya sebzeli sushi (Avocado Roll) tercih edebilirsiniz.',
      emoji: '🍣',
    ),
    SafetyItem(
      id: 'food_unpasteurized_cheese',
      title: 'Pastörize Edilmemiş Peynirler (Rokfor, Brie, Köy Peyniri)',
      category: SafetyCategory.food,
      level: SafetyLevel.unsafe,
      summary: 'Çiğ sütten yapılan yumuşak küflü peynirlerden kaçınılmalıdır.',
      medicalReason: 'Pastörize edilmemiş süt listerioz enfeksiyonunun bir numaralı kaynağıdır.',
      alternativeSuggestion: 'Paketli pastörize kaşar veya sert gouda peyniri tüketin.',
      emoji: '🧀',
    ),
    SafetyItem(
      id: 'food_deli_meat',
      title: 'Çiğ Şarküteri (Salam, Sosis, Çiğ Sucuk)',
      category: SafetyCategory.food,
      level: SafetyLevel.unsafe,
      summary: 'İyice kızartılmadan (en az 75°C) çiğ veya soğuk sandviç içinde yenmemelidir.',
      medicalReason: 'İşlenmiş etler listeria bakterisi ve yüksek nitrit içerir.',
      alternativeSuggestion: 'Tavada tamamen pişmiş sucuk veya haşlanmış hindi göğsü yiyebilirsiniz.',
      emoji: '🥓',
    ),

    // --- BİTKİ ÇAYLARI VE TAKVİYELER ---
    SafetyItem(
      id: 'herb_linden',
      title: 'Ihlamur & Melisa Çayı',
      category: SafetyCategory.herb,
      level: SafetyLevel.safe,
      summary: 'Günde 1-2 fincan ılık olarak güvenle içilebilir.',
      medicalReason: 'Mideyi yatıştırır, doğal sakinlik verir ve boğazı yumuşatır.',
      emoji: '🌼',
    ),
    SafetyItem(
      id: 'herb_ginger',
      title: 'Taze Zencefil Çayı',
      category: SafetyCategory.herb,
      level: SafetyLevel.safe,
      summary: 'Günde 1 fincan ılık zencefil limon çayı güvenlidir.',
      medicalReason: 'Sabah bulantılarını (morning sickness) hafifletmede klinik olarak kanıtlanmıştır.',
      emoji: '🫚',
    ),
    SafetyItem(
      id: 'herb_sage',
      title: 'Adaçayı (Sage)',
      category: SafetyCategory.herb,
      level: SafetyLevel.unsafe,
      summary: 'Hamilelik süresince adaçayı içilmemelidir.',
      medicalReason: 'Tujon (thujone) bileşiği içerir; rahim kasılmalarını uyarabilir ve tansiyonu yükseltebilir.',
      alternativeSuggestion: 'Papatya veya ıhlamur çayı içiniz.',
      emoji: '🌱',
    ),
    SafetyItem(
      id: 'herb_senna',
      title: 'Sinameki Çayı',
      category: SafetyCategory.herb,
      level: SafetyLevel.unsafe,
      summary: 'Zayıflama ve form çaylarında sık bulunan sinamekiden uzak durun.',
      medicalReason: 'Şiddetli bağırsak kramplarına ve rahim kasılmalarına sebep olabilir.',
      alternativeSuggestion: 'Kabızlık için kuru erik hoşafı ve bol su tüketin.',
      emoji: '🍂',
    ),

    // --- CİLT BAKIMI & KOZMETİK: GÜVENLİ (YEŞİL) ---
    SafetyItem(
      id: 'skin_hyaluronic_acid',
      title: 'Hyaluronik Asit',
      category: SafetyCategory.skincare,
      level: SafetyLevel.safe,
      summary: 'Gebelikte %100 güvenlidir, nem bariyerini güçlendirir.',
      medicalReason: 'Vücutta doğal olarak bulunan bir moleküldür, sistemik emilim göstermez.',
      emoji: '💧',
    ),
    SafetyItem(
      id: 'skin_vitamin_c',
      title: 'C Vitamini Serumu',
      category: SafetyCategory.skincare,
      level: SafetyLevel.safe,
      summary: 'Leke oluşumunu önlemede güvenli ve etkilidir.',
      medicalReason: 'Hamilelik maskesi (melazma) oluşumuna karşı güçlü ve güvenli antioksidandır.',
      emoji: '🍊',
    ),
    SafetyItem(
      id: 'skin_mineral_sunscreen',
      title: 'Mineral Güneş Koruyucu (Çinko Oksit / Titanyum Dioksit)',
      category: SafetyCategory.skincare,
      level: SafetyLevel.safe,
      summary: 'Fiziksel filtreli koruyucular hamilelikte altın standarttır.',
      medicalReason: 'Deri altına emilmez, ayna gibi ışığı yansıtarak melazmayı engeller.',
      emoji: '☀️',
    ),
    SafetyItem(
      id: 'skin_bakuchiol',
      title: 'Bakuchiol (Bitkisel Retinol Alternatifi)',
      category: SafetyCategory.skincare,
      level: SafetyLevel.safe,
      summary: 'Retinoid yerine kullanabileceğiniz güvenli bitkisel alternatiftir.',
      medicalReason: 'Hücre yenilenmesini uyarır ancak fetal gelişim üzerinde toksik etkisi yoktur.',
      emoji: '🌸',
    ),

    // --- CİLT BAKIMI: ÖLÇÜLÜ / ŞARTLI (SARI) ---
    SafetyItem(
      id: 'skin_salicylic_acid',
      title: 'Salisilik Asit (BHA)',
      category: SafetyCategory.skincare,
      level: SafetyLevel.moderate,
      summary: '%2 veya daha düşük konsantrasyonda lokal bölgesel kullanım genellikle güvenlidir.',
      medicalReason: 'Yüksek doz oral veya geniş alan vücut peelingleri aspirin türevi olduğu için riskli olabilir.',
      alternativeSuggestion: 'Laktik asit veya Azelaik asit (%10) daha güvenli bir eksfoliyandır.',
      emoji: '🧴',
    ),
    SafetyItem(
      id: 'skin_glycolic_acid',
      title: 'Glikolik Asit (AHA)',
      category: SafetyCategory.skincare,
      level: SafetyLevel.moderate,
      summary: '%7 ve altındaki düşük konsantrasyonlu tonikler ölçülü kullanılabilir.',
      medicalReason: 'Cilt bariyeri hassaslaştığı için lekelenmeyi artırabilir, güneşe dikkat edilmelidir.',
      emoji: '✨',
    ),

    // --- CİLT BAKIMI: SAKINCALI (KIRMIZI) ---
    SafetyItem(
      id: 'skin_retinoids',
      title: 'Retinol / Tretinoin / A Vitamini Türevleri',
      category: SafetyCategory.skincare,
      level: SafetyLevel.unsafe,
      summary: 'Krem, serum ve hap formu gebelikte KESİNLİKLE bırakılmalıdır.',
      medicalReason: 'Yüksek doz A vitamini türevleri fetal malformasyon (teratojenik etki) ile doğrudan ilişkilidir.',
      alternativeSuggestion: 'Bakuchiol, Niasinamid (%5) veya Hyaluronik asit kullanabilirsiniz.',
      emoji: '🚫',
    ),
    SafetyItem(
      id: 'skin_hydroquinone',
      title: 'Hidrokinon (Leke Kremi)',
      category: SafetyCategory.skincare,
      level: SafetyLevel.unsafe,
      summary: 'Leke açıcı kremlerde bulunan hidrokinondan kaçınılmalıdır.',
      medicalReason: 'Ciltten yüksek oranda (%35-45) sistemik dolaşıma geçer.',
      alternativeSuggestion: 'C Vitamini ve Azelaik asit leke için güvenlidir.',
      emoji: '⚠️',
    ),
    SafetyItem(
      id: 'skin_chemical_sunscreen',
      title: 'Oksibenzon (Kimyasal Güneş Filtresi)',
      category: SafetyCategory.skincare,
      level: SafetyLevel.unsafe,
      summary: 'Oxybenzone içeren kimyasal filtreli güneş kremleri yerine mineral filtre tercih edilmelidir.',
      medicalReason: 'Hormonal dengeyi ve plasental dolaşımı etkileyebilecek moleküler yapıya sahiptir.',
      alternativeSuggestion: 'Çinko oksit (Zinc Oxide) bazlı mineral kremler kullanın.',
      emoji: '🏖️',
    ),
  ];

  static List<SafetyItem> search(String query, {SafetyCategory? category, SafetyLevel? level}) {
    final cleanQuery = query.trim().toLowerCase();
    return items.where((item) {
      if (category != null && item.category != category) return false;
      if (level != null && item.level != level) return false;
      if (cleanQuery.isEmpty) return true;
      return item.title.toLowerCase().contains(cleanQuery) ||
          item.summary.toLowerCase().contains(cleanQuery) ||
          item.medicalReason.toLowerCase().contains(cleanQuery) ||
          (item.alternativeSuggestion?.toLowerCase().contains(cleanQuery) ?? false);
    }).toList();
  }
}
