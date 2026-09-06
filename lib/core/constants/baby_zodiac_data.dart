import '../../models/baby_zodiac_model.dart';

/// Aura Pregnancy - Bebek Burç, Mizaç ve Anne-Bebek Astrolojik Uyumu Motoru
class BabyZodiacData {
  static const List<String> allZodiacNames = [
    'Koç', 'Boğa', 'İkizler', 'Yengeç',
    'Aslan', 'Başak', 'Terazi', 'Akrep',
    'Yay', 'Oğlak', 'Kova', 'Balık'
  ];

  /// Doğum Tarihine (EDD) Göre Bebek Burcunu ve Mizaç Modelini Hesaplar
  static BabyZodiacModel calculateFromDueDate(DateTime date) {
    final month = date.month;
    final day = date.day;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) {
      final isCusp = (month == 3 && day <= 23) || (month == 4 && day >= 17);
      return _zodiacs['Koç']!.copyWith(
        isCusp: isCusp,
        cuspNotice: isCusp ? 'Balık - Koç veya Koç - Boğa geçiş enerjisi taşır.' : null,
      );
    } else if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
      final isCusp = (month == 4 && day <= 22) || (month == 5 && day >= 18);
      return _zodiacs['Boğa']!.copyWith(
        isCusp: isCusp,
        cuspNotice: isCusp ? 'Koç - Boğa veya Boğa - İkizler geçiş enerjisi taşır.' : null,
      );
    } else if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) {
      final isCusp = (month == 5 && day <= 23) || (month == 6 && day >= 18);
      return _zodiacs['İkizler']!.copyWith(
        isCusp: isCusp,
        cuspNotice: isCusp ? 'Boğa - İkizler veya İkizler - Yengeç geçiş enerjisi taşır.' : null,
      );
    } else if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) {
      final isCusp = (month == 6 && day <= 23) || (month == 7 && day >= 20);
      return _zodiacs['Yengeç']!.copyWith(
        isCusp: isCusp,
        cuspNotice: isCusp ? 'İkizler - Yengeç veya Yengeç - Aslan geçiş enerjisi taşır.' : null,
      );
    } else if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) {
      final isCusp = (month == 7 && day <= 25) || (month == 8 && day >= 20);
      return _zodiacs['Aslan']!.copyWith(
        isCusp: isCusp,
        cuspNotice: isCusp ? 'Yengeç - Aslan veya Aslan - Başak geçiş enerjisi taşır.' : null,
      );
    } else if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) {
      final isCusp = (month == 8 && day <= 25) || (month == 9 && day >= 20);
      return _zodiacs['Başak']!.copyWith(
        isCusp: isCusp,
        cuspNotice: isCusp ? 'Aslan - Başak veya Başak - Terazi geçiş enerjisi taşır.' : null,
      );
    } else if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) {
      final isCusp = (month == 9 && day <= 25) || (month == 10 && day >= 20);
      return _zodiacs['Terazi']!.copyWith(
        isCusp: isCusp,
        cuspNotice: isCusp ? 'Başak - Terazi veya Terazi - Akrep geçiş enerjisi taşır.' : null,
      );
    } else if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
      final isCusp = (month == 10 && day <= 25) || (month == 11 && day >= 19);
      return _zodiacs['Akrep']!.copyWith(
        isCusp: isCusp,
        cuspNotice: isCusp ? 'Terazi - Akrep veya Akrep - Yay geçiş enerjisi taşır.' : null,
      );
    } else if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
      final isCusp = (month == 11 && day <= 24) || (month == 12 && day >= 19);
      return _zodiacs['Yay']!.copyWith(
        isCusp: isCusp,
        cuspNotice: isCusp ? 'Akrep - Yay veya Yay - Oğlak geçiş enerjisi taşır.' : null,
      );
    } else if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
      final isCusp = (month == 12 && day <= 24) || (month == 1 && day >= 17);
      return _zodiacs['Oğlak']!.copyWith(
        isCusp: isCusp,
        cuspNotice: isCusp ? 'Yay - Oğlak veya Oğlak - Kova geçiş enerjisi taşır.' : null,
      );
    } else if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
      final isCusp = (month == 1 && day <= 22) || (month == 2 && day >= 16);
      return _zodiacs['Kova']!.copyWith(
        isCusp: isCusp,
        cuspNotice: isCusp ? 'Oğlak - Kova veya Kova - Balık geçiş enerjisi taşır.' : null,
      );
    } else {
      final isCusp = (month == 2 && day <= 21) || (month == 3 && day >= 18);
      return _zodiacs['Balık']!.copyWith(
        isCusp: isCusp,
        cuspNotice: isCusp ? 'Kova - Balık veya Balık - Koç geçiş enerjisi taşır.' : null,
      );
    }
  }

  /// String Tarihten ('YYYY-MM-DD') Hesaplayıcı
  static BabyZodiacModel calculateFromDueDateString(String dueDateStr) {
    try {
      final parsed = DateTime.parse(dueDateStr);
      return calculateFromDueDate(parsed);
    } catch (_) {
      return _zodiacs['Yengeç']!; // Fallback
    }
  }

  /// Anne ve Bebek Arasındaki Duygusal & Enerjisel Uyum
  static Map<String, dynamic> calculateMotherBabyCompatibility(String momSign, String babySign) {
    final baby = _zodiacs[babySign] ?? _zodiacs['Yengeç']!;
    final mom = _zodiacs[momSign] ?? _zodiacs['Başak']!;

    int score = 85;
    String dynamicComment = 'Birbirinizi sevgiyle besleyecek harika bir anne-bebek bağı!';

    if (mom.element == baby.element) {
      score = 98;
      dynamicComment = '${mom.element} elementinin ortak dili! Anne ve bebek birbirinin ruh halini ve ihtiyaçlarını anında sezecek.';
    } else if ((mom.element == 'Su' && baby.element == 'Toprak') || (mom.element == 'Toprak' && baby.element == 'Su')) {
      score = 96;
      dynamicComment = 'Toprak ve Su bereketi! Anne bebeğe huzurlu ve güvenli bir liman sunarken, bebek anneye derin duygusal şefkat katacak.';
    } else if ((mom.element == 'Ateş' && baby.element == 'Hava') || (mom.element == 'Hava' && baby.element == 'Ateş')) {
      score = 94;
      dynamicComment = 'Ateş ve Hava coşkusu! Neşeli kahkahalar, yaratıcı oyunlar ve merak dolu bir gelişim serüveni sizi bekliyor.';
    } else if ((mom.element == 'Ateş' && baby.element == 'Su') || (mom.element == 'Su' && baby.element == 'Ateş')) {
      score = 88;
      dynamicComment = 'Duygusal derinlik ve enerji dengesi! Annenin sakinleştirici dokunuşu bebeğin ışıltılı enerjisini dengeler.';
    }

    return {
      'score': score,
      'momElement': mom.element,
      'babyElement': baby.element,
      'summary': dynamicComment,
      'parentingKey': 'Bebeğinizin ${baby.modality.toLowerCase()} yapısına saygı duyarak kendi güvenli sınırlarını çizmesine alan tanıyın.',
    };
  }

  // 12 Burç Bilgi Havuzu
  static final Map<String, BabyZodiacModel> _zodiacs = {
    'Koç': const BabyZodiacModel(
      signName: 'Koç',
      symbol: '♈',
      element: 'Ateş',
      modality: 'Öncü',
      dateRangeStr: '21 Mart - 19 Nisan',
      headline: 'Cesur, meraklı ve enerjik küçük bir kaşif!',
      temperament: 'Hayatı büyük bir hevesle kucaklar. Erken emeklemeye, yürümeye ve dünyayı elleriyle keşfetmeye meyillidir.',
      sleepTendency: 'Gündüz enerjisini yüksek harcar, uyku öncesi sakinleştirici rutinlere (ılık banyo, loş ışık) ihtiyaç duyar.',
      emotionalNeeds: 'Özgür hissetmek ve başarma duygusunu tatmak ister. Kendi başına bir şey başardığında coşkuyla alkışlanmayı sever.',
      parentingAdvice: 'Sabırsızlandığında ona yumuşak bir ses tonuyla eşlik edin ve keşif merakını kısıtlamayan güvenli alanlar kurun.',
      luckyColors: ['Mercan Kırmızısı', 'Güneş Sarısı'],
      gemStone: 'Kırmızı Akik',
    ),
    'Boğa': const BabyZodiacModel(
      signName: 'Boğa',
      symbol: '♉',
      element: 'Toprak',
      modality: 'Sabit',
      dateRangeStr: '20 Nisan - 20 Mayıs',
      headline: 'Huzurlu, dokunarak öğrenen ve sakin uykucu.',
      temperament: 'Aceleyi sevmez, kendi ritminde büyür. Yumuşak battaniyelere sarılmaya, ten tene temasa ve müzik dinlemeye bayılır.',
      sleepTendency: 'Rutinleri bozulmadığı sürece deliksiz ve huzurlu uyur. Sıcacık bir yatak ve tanıdık kokular uykusunu derinleştirir.',
      emotionalNeeds: 'Fiziksel temas, sarılma ve güven duygusu en temel ihtiyacıdır. Ani değişikliklerden hoşlanmaz.',
      parentingAdvice: 'Beslenme ve uyku saatlerini düzenli tutun; değişiklikleri acele ettirmeden yumuşak geçişlerle hissettirin.',
      luckyColors: ['Adaçayı Yeşili', 'Pudra Pembesi'],
      gemStone: 'Zümrüt & Gül Kuvars',
    ),
    'İkizler': const BabyZodiacModel(
      signName: 'İkizler',
      symbol: '♊',
      element: 'Hava',
      modality: 'Değişken',
      dateRangeStr: '21 Mayıs - 20 Haziran',
      headline: 'Güler yüzlü, neşeli ve erken konuşmaya hevesli.',
      temperament: 'Gözleri sürekli etraftaki sesleri ve renkleri tarar. Çok erken agulamaya başlar, insanlarla iletişim kurmaya bayılır.',
      sleepTendency: 'Merakı nedeniyle uykuyu kaçırmak isteyebilir. Odasındaki görsel uyarıcıları uyku saatinde azaltmak iyi gelir.',
      emotionalNeeds: 'Sürekli yeni şeyler öğrenmek, onunla konuşulması ve masal dinlemek zihnini sakinleştirir.',
      parentingAdvice: 'Ona bol bol kitap okuyun, şarkı söyleyin ve sorularına sabırla yanıt verin.',
      luckyColors: ['Güneş Işığı Sarısı', 'Gök Mavisi'],
      gemStone: 'Sitrin & Akik',
    ),
    'Yengeç': const BabyZodiacModel(
      signName: 'Yengeç',
      symbol: '♋',
      element: 'Su',
      modality: 'Öncü',
      dateRangeStr: '21 Haziran - 22 Temmuz',
      headline: 'Şefkat küpü, derin sezgili ve anne kalbine bağlı melek.',
      temperament: 'Çok duygusal ve hassastır. Annesinin kalp atışını duyduğunda ve kucağa alındığında anında yatışır.',
      sleepTendency: 'Anne kokusunu aldığı müddetçe huzurla uyur. Ten tene temas ve kanguru kullanımı uykusunu büyüler.',
      emotionalNeeds: 'Duygusal güven ve koşulsuz sevgi. Ortamdaki stres veya yüksek sesleri hemen sezer ve etkilenebilir.',
      parentingAdvice: 'Ağladığında hemen kucağınıza almaktan çekinmeyin; güvenli bağlanma onun hayattaki en büyük gücü olacaktır.',
      luckyColors: ['İnci Beyazı', 'Deniz Köpüğü Mavisi'],
      gemStone: 'Ay Taşı',
    ),
    'Aslan': const BabyZodiacModel(
      signName: 'Aslan',
      symbol: '♌',
      element: 'Ateş',
      modality: 'Sabit',
      dateRangeStr: '23 Temmuz - 22 Ağustos',
      headline: 'Işıltılı gülüşüyle girdiği odayı aydınlatan minik yıldız.',
      temperament: 'İlgi odağı olmayı sever, sevimli mimikleriyle herkesi kendine aşık eder. Cömert kalpli ve neşelidir.',
      sleepTendency: 'Kraliyet uykusunu sever; rahat ve geniş bir alanda uyumaktan keyif alır.',
      emotionalNeeds: 'Takdir edilmek, sevilmek ve önemsendiğini hissetmek. Gülüşüne karşılık verilmesini bekler.',
      parentingAdvice: 'Özgüvenini destekleyin ve başarılarını överken içtenliğini her zaman hissettirin.',
      luckyColors: ['Altın Sarısı', 'Sıcak Şeftali'],
      gemStone: 'Kehribar & Kaplan Gözü',
    ),
    'Başak': const BabyZodiacModel(
      signName: 'Başak',
      symbol: '♍',
      element: 'Toprak',
      modality: 'Değişken',
      dateRangeStr: '23 Ağustos - 22 Eylül',
      headline: 'Dikkatli gözlemci, düzen seven ve sakin mizaçlı.',
      temperament: 'Etrafındaki detayları sessizce inceler. Bezinin temiz olması ve üstünün kuru kalması konusunda çok titizdir.',
      sleepTendency: 'Temiz nevresimler ve sessiz, düzenli bir uyku ortamında çok rahat uyur.',
      emotionalNeeds: 'Öngörülebilirlik ve sakinlik. Dağınık veya gürültülü ortamlar huzursuz edebilir.',
      parentingAdvice: 'Günlük rutinlerine sadık kalın ve ona küçük düzenli sorumluluklar vermekten çekinmeyin.',
      luckyColors: ['Krem', 'Toprak Yeşili'],
      gemStone: 'Yeşim Taşı',
    ),
    'Terazi': const BabyZodiacModel(
      signName: 'Terazi',
      symbol: '♎',
      element: 'Hava',
      modality: 'Öncü',
      dateRangeStr: '23 Eylül - 22 Ekim',
      headline: 'Tatlı dilli, uyumlu ve estetik duygusu yüksek melek.',
      temperament: 'Kavga ve gerginlikten hiç hoşlanmaz. Güler yüzlü, sakin müzikleri seven ve sosyal bir bebektir.',
      sleepTendency: 'Hafif klasik müzik veya yumuşak ninniler eşliğinde huzurla uykuya dalar.',
      emotionalNeeds: 'Denge, huzur ve sevgi dolu bir aile ortamı.',
      parentingAdvice: 'Ona seçim yapma fırsatları tanıyın (örneğin iki tulum arasından seçtirmek) ve kararsız kaldığında destekleyin.',
      luckyColors: ['Pastel Pembe', 'Lavanta'],
      gemStone: 'Pembe Kuvars',
    ),
    'Akrep': const BabyZodiacModel(
      signName: 'Akrep',
      symbol: '♏',
      element: 'Su',
      modality: 'Sabit',
      dateRangeStr: '23 Ekim - 21 Kasım',
      headline: 'Derin bakışlı, güçlü sezgili ve sadık küçük kahraman.',
      temperament: 'Gözlerinin içine baktığınızda yaşından çok daha bilge olduğunu hissedersiniz. Annesine tutkuyla bağlıdır.',
      sleepTendency: 'Loş ve korunaklı köşelerde derin uyur. Fazla aydınlık ortamları sevmez.',
      emotionalNeeds: 'Güvenilirlik ve dürüst sevgi. Annenin duygularını ayna gibi yansıtır.',
      parentingAdvice: 'İnatlaştığında güç savaşına girmeyin; sakin kalarak duygularını isimlendirmesine yardımcı olun.',
      luckyColors: ['Bordo', 'Gece Mavisi'],
      gemStone: 'Obsidyen & Lal Taşı',
    ),
    'Yay': const BabyZodiacModel(
      signName: 'Yay',
      symbol: '♐',
      element: 'Ateş',
      modality: 'Değişken',
      dateRangeStr: '22 Kasım - 21 Aralık',
      headline: 'Gezgin ruhlu, neşeli kahkahaların ve açık havanın aşığı.',
      temperament: 'Pusetle gezmeye, açık havada rüzgarı hissetmeye bayılır. Çok neşeli ve pozitif bir bebektir.',
      sleepTendency: 'Gezintide veya arabada kolayca uyur; temiz hava uykusunu çok derinleştirir.',
      emotionalNeeds: 'Özgürlük ve hareket alanı. Kapalı kalmaktan sıkılabilir.',
      parentingAdvice: 'Onu sık sık doğayla buluşturun ve keşfetme arzusunu destekleyin.',
      luckyColors: ['Turkuaz', 'Kraliyet Mavisi'],
      gemStone: 'Lapis Lazuli',
    ),
    'Oğlak': const BabyZodiacModel(
      signName: 'Oğlak',
      symbol: '♑',
      element: 'Toprak',
      modality: 'Sabit',
      dateRangeStr: '22 Aralık - 19 Ocak',
      headline: 'Sabırlı, olgun bakışlı ve azimli küçük bilge.',
      temperament: 'Bebekken bile olgun bir ciddiyeti vardır. Bir oyuncağı çözene kadar sabırla uğraşır, kararlıdır.',
      sleepTendency: 'Belli bir saatte yatmayı sever, programına bağlıdır.',
      emotionalNeeds: 'Ciddiye alınmak ve saygı görmek. Sözlerin tutulması onun için önemlidir.',
      parentingAdvice: 'Onu çocukluğunu yaşaması, şımarması ve kahkaha atması için bol bol teşvik edin.',
      luckyColors: ['Kömür Grisi', 'Haki Yeşil'],
      gemStone: 'Oniks & Dumanlı Kuvars',
    ),
    'Kova': const BabyZodiacModel(
      signName: 'Kova',
      symbol: '♒',
      element: 'Hava',
      modality: 'Sabit',
      dateRangeStr: '20 Ocak - 18 Şubat',
      headline: 'Özgür ruhlu, yaratıcı ve sıra dışı zekalı mucit.',
      temperament: 'Standart oyuncaklardan çok evdeki ilginç nesnelerle ilgilenir. Bağımsızlığına düşkündür.',
      sleepTendency: 'Uykusunda bile zihni aktif olabilir, beyaz gürültü uykusunu rahatlatır.',
      emotionalNeeds: 'Bireyselliğine saygı duyulması ve merakının engellenmemesi.',
      parentingAdvice: 'Onu kalıplara sokmaya çalışmayın; kendi benzersizliğini ifade etmesine izin verin.',
      luckyColors: ['Elektrik Mavisi', 'Gümüş'],
      gemStone: 'Ametist',
    ),
    'Balık': const BabyZodiacModel(
      signName: 'Balık',
      symbol: '♓',
      element: 'Su',
      modality: 'Değişken',
      dateRangeStr: '19 Şubat - 20 Mart',
      headline: 'Rüya gibi hayalperest, narin kalpli ve empati ustası.',
      temperament: 'Masalsı bir dünyası vardır. Müzikle uyur, suyla oynamaya (banyo saatine) bayılır. Çok hassas ve sevecendir.',
      sleepTendency: 'Ninni ve su şırıltısı eşliğinde mışıl mışıl uyur.',
      emotionalNeeds: 'Şefkat, sarılma ve sakin bir atmosfer. Sert tonlamalardan çabuk incinir.',
      parentingAdvice: 'Duygularını ciddiye alın, sanatsal yönünü ve hayal gücünü besleyin.',
      luckyColors: ['Deniz Yeşili', 'Lavanta'],
      gemStone: 'Akuamarin',
    ),
  };
}

extension _CopyHelper on BabyZodiacModel {
  BabyZodiacModel copyWith({bool? isCusp, String? cuspNotice}) {
    return BabyZodiacModel(
      signName: signName,
      symbol: symbol,
      element: element,
      modality: modality,
      dateRangeStr: dateRangeStr,
      headline: headline,
      temperament: temperament,
      sleepTendency: sleepTendency,
      emotionalNeeds: emotionalNeeds,
      parentingAdvice: parentingAdvice,
      isCusp: isCusp ?? this.isCusp,
      cuspNotice: cuspNotice ?? this.cuspNotice,
      luckyColors: luckyColors,
      gemStone: gemStone,
    );
  }
}
