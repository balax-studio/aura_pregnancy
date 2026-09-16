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

  // 12 Burç Bilgi Havuzu - Anti-Slop Derinlikli Psikolojik & Gelişimsel İçerik
  static final Map<String, BabyZodiacModel> _zodiacs = {
    'Koç': const BabyZodiacModel(
      signName: 'Koç',
      symbol: '♈',
      element: 'Ateş',
      modality: 'Öncü',
      dateRangeStr: '21 Mart - 19 Nisan',
      headline: 'Cesur, meraklı, ilk adımı atmaktan korkmayan minik kaşif.',
      temperament: 'Koç bebeği dünyaya büyük bir hayat coşkusu ve öncü bir enerjiyle adım atar. Çevresindeki her nesne onun için keşfedilmeyi bekleyen bir gizemdir. Erken dönemde başını dik tutmaya, emeklemeye ve ayaklarının üzerinde durmaya heveslidir. İradeli ve doğrudan iletişimi sever; ne istediğini net mimikler ve kararlı seslerle belli eder.',
      sensoryPlay: 'Canlı renklere, ritmik ses çıkaran çıngıraklara ve hareket özgürlüğü tanıyan yumuşak oyun minderlerine bayılır. Kendi beden sınırlarını zorlayabileceği tırmanma ve yuvarlanma alanları enerjisini dengeler.',
      sleepTendency: 'Gündüzleri aktif ve keşif odaklı olduğu için gün sonunda sinir sisteminin sakinleşmesi biraz zaman alabilir. Uyku öncesinde ılık bir banyo, loş ışık eşliğinde masaj ve ritmik fısıltılar uykuya geçişi kolaylaştırır.',
      emotionalNeeds: 'Özerklik ve takdir edilme hissi. Kendi başına bir oyuncağa ulaştığında ya da bir engeli aştığında ebeveynlerinin gözlerindeki gururu ve neşeyi görmek onun güven duygusunu perçinler.',
      parentingAdvice: 'Sabırsızlandığında veya öfke nöbeti yaşadığında otoriter baskı yerine şefkatli bir sınır çizin. Ona seçenek sunarak kontrol hissi verin ve macera tutkusunu güvenli alanlarda destekleyin.',
      luckyColors: ['Mercan Kırmızısı', 'Güneş Sarısı', 'Canlı Şeftali'],
      gemStone: 'Kırmızı Akik & Lal Taşı',
    ),
    'Boğa': const BabyZodiacModel(
      signName: 'Boğa',
      symbol: '♉',
      element: 'Toprak',
      modality: 'Sabit',
      dateRangeStr: '20 Nisan - 20 Mayıs',
      headline: 'Huzurlu, dokunarak dünyayı algılayan, sakin ve köklü uykucu.',
      temperament: 'Boğa bebeği hayatı aceleye getirmeden, kendi dingin ritminde deneyimler. Duyuları son derece gelişmiştir; ipeksi bir battaniyenin dokusu, annesinin ten kokusu ve yumuşak tondaki melodiler onun dünyasının temelini oluşturur. Değişimlere karşı temkinlidir, ancak güven hissettiğinde dünyanın en güler yüzlü ve sabırlı bebeğidir.',
      sensoryPlay: 'Farklı dokulardaki kumaşlar, doğal ahşap oyuncaklar ve doğa sesleri içeren melodilerle vakit geçirmeyi sever. Açık havada çimlere dokunmak ve rüzgarı hissetmek onu derinden dinlendirir.',
      sleepTendency: 'Rutinlerine sadık kalındığında deliksiz ve derin uyur. Tanıdık bir uyku tulumu, odanın sabit sıcaklığı ve aynı ninni melodisi onun güvenle rüyalara dalmasını sağlar.',
      emotionalNeeds: 'Fiziksel temas ve istikrar. Kucağa alınmak, uzun uzun göğüste uyutulmak ve beslenme saatlerinin aksamaması onun iç huzurunu korur.',
      parentingAdvice: 'Onu acele ettirmeyin. Yeni bir gıdaya veya ortama geçerken ona alışması için yeterli zaman tanıyın; zorlamak yerine doğal merakını nazikçe uyandırın.',
      luckyColors: ['Adaçayı Yeşili', 'Pudra Pembesi', 'Krem'],
      gemStone: 'Zümrüt & Gül Kuvars',
    ),
    'İkizler': const BabyZodiacModel(
      signName: 'İkizler',
      symbol: '♊',
      element: 'Hava',
      modality: 'Değişken',
      dateRangeStr: '21 Mayıs - 20 Haziran',
      headline: 'Işıltılı gözlerle etrafı süzen, iletişime ve kelimelere aşık zeki melek.',
      temperament: 'İkizler bebeğinin zihni tıpkı bir sünger gibi çevresindeki her görsel ve işitsel uyaranı emer. Çok erken agulamaya başlar; sizinle göz teması kurup uzun uzun sesli diyaloglar yapmaya bayılır. Merakı hiç bitmez, aynı anda iki farklı şeyle ilgilenmek onun doğasında vardır.',
      sensoryPlay: 'Renkli resimli kitaplar, kontrast kartlar, melodik çıngıraklar ve el kuklaları onun dikkatini saatlerce canlı tutar. Ayna karşısında kendi yansımasıyla konuşmaktan büyük keyif alır.',
      sleepTendency: 'Gündüz gördüğü her şeyi zihninde işlemeye devam ettiği için uyku saatlerinde uyarıcıların kapatılması gerekir. Masal anlatmak veya hafif bir mırıltı zihnini sakinleştirir.',
      emotionalNeeds: 'Zihinsel doyum ve karşılıklı iletişim. Onun çıkardığı sesleri taklit etmek ve dünyayı ona anlatmak duygusal bağınızı güçlendirir.',
      parentingAdvice: 'Ona bol bol kitap okuyun, sorularına ilgiyle yanıt verin ve odasını gereksiz eşya kalabalığından arındırarak odaklanmasına yardımcı olun.',
      luckyColors: ['Güneş Işığı Sarısı', 'Gök Mavisi', 'Nane Yeşili'],
      gemStone: 'Sitrin & Mavi Dantelli Akik',
    ),
    'Yengeç': const BabyZodiacModel(
      signName: 'Yengeç',
      symbol: '♋',
      element: 'Su',
      modality: 'Öncü',
      dateRangeStr: '21 Haziran - 22 Temmuz',
      headline: 'Şefkat pınarı, yüksek sezgili, anne kalbinin atışıyla yaşayan melek.',
      temperament: 'Yengeç bebeği dünyanın en derin duygusal duyargalarına sahiptir. Ortamdaki neşeyi de hüznü de henüz sözcükler yokken süzer. Annesinin kokusu ve kalp atışı onun tek sığınağıdır. Aşırı gürültülü veya yabancı ortamlarda biraz içine kapanabilir, ancak güvendiği kucakta sonsuz bir neşe ve sevgi saçar.',
      sensoryPlay: 'Ilık suyla banyo yapmak, anne karnı sesleri dinlemek ve yumuşacık pelüş dokularla sarılmak onun favorisidir. Kanguru içinde taşınmak onu sakinleştirir.',
      sleepTendency: 'Yalnız kalmaktan hoşlanmaz; anneye yakın uyumak, ten tene temas ve emzirme sonrası gelen rehavetle huzur içinde uyur.',
      emotionalNeeds: 'Koşulsuz şefkat ve kesintisiz duygusal güven. Ağladığında hemen yanıt almak onun temel güven duygusunu inşa eder.',
      parentingAdvice: 'Duygusallığını asla bir zayıflık olarak görmeyin; onunla göz hizasında konuşarak duygularını onaylayın ve güvenli bir liman olun.',
      luckyColors: ['İnci Beyazı', 'Deniz Köpüğü Mavisi', 'Gümüş'],
      gemStone: 'Ay Taşı & Selenit',
    ),
    'Aslan': const BabyZodiacModel(
      signName: 'Aslan',
      symbol: '♌',
      element: 'Ateş',
      modality: 'Sabit',
      dateRangeStr: '23 Temmuz - 22 Ağustos',
      headline: 'Işıltılı gülüşüyle girdiği her odayı aydınlatan cömert kalpli güneş.',
      temperament: 'Aslan bebeği doğuştan bir sahne ışığına sahiptir. Mimikleri, coşkulu kahkahaları ve sevimli jestleriyle tüm ailenin ilgi odağı olmayı başarır. Kalbi çok cömerttir; sevdiği insanlara sarılmaktan ve onları güldürmekten keyif alır. Gururlu ve kendine güvenen bir duruşu vardır.',
      sensoryPlay: 'Büyük ve parlak oyuncaklar, alkışlanabileceği müzikli aktiviteler ve kostümlü oyunlar enerjisini açığa çıkarır. Dans etmek ve ritim tutmak doğasında vardır.',
      sleepTendency: 'Günün kahramanı olduktan sonra derin bir kraliyet uykusuna dalar. Rahat, ferah ve geniş bir yatakta uyumayı sever.',
      emotionalNeeds: 'Takdir edilmek, alkışlanmak ve kalpten gelen sıcak bir ilgi. Gülüşünün fark edilmesi onun neşesini katlar.',
      parentingAdvice: 'Özgüvenini içtenlikle destekleyin; ancak sınırları da şefkatle hatırlatarak paylaşma ve empati duygusunu erken yaşta aşılayın.',
      luckyColors: ['Altın Sarısı', 'Sıcak Şeftali', 'Kraliyet Pembesi'],
      gemStone: 'Kehribar & Kaplan Gözü',
    ),
    'Başak': const BabyZodiacModel(
      signName: 'Başak',
      symbol: '♍',
      element: 'Toprak',
      modality: 'Değişken',
      dateRangeStr: '23 Ağustos - 22 Eylül',
      headline: 'Dikkatli gözlemci, ayrıntıları süzen, düzen ve temizlik seven bilge.',
      temperament: 'Başak bebeği sessizce etrafı izler ve her parçanın nasıl çalıştığını anlamaya çalışır. Bebeklikten itibaren temizlik ve düzen konusunda hassastır; ıslak bez veya dağınık bir yatak onu hemen huzursuz edebilir. Sakin, nazik ve çözüm odaklı bir mizacı vardır.',
      sensoryPlay: 'Geometrik şekil yerleştirme kutuları, ince motor becerilerini geliştiren parçalı oyuncaklar ve düzenlenebilir bloklar onun zihnini tatmin eder.',
      sleepTendency: 'Sessiz, iyi havalandırılmış ve temiz nevresimli bir odada son derece huzurlu uyur. Belli bir uyku saatine alışması çok kolaydır.',
      emotionalNeeds: 'Öngörülebilirlik ve düzenli bir günlük akış. Nelerin ne zaman olacağını bilmek kaygı düzeyini sıfırlar.',
      parentingAdvice: 'Günlük programını ani biçimde değiştirmemeye özen gösterin; mükemmeliyetçi eğilimlerini rahatlatacak serbest, kirlenmeli oyunlara da fırsat verin.',
      luckyColors: ['Krem', 'Toprak Yeşili', 'Buğday Sarısı'],
      gemStone: 'Yeşim Taşı & Amazonit',
    ),
    'Terazi': const BabyZodiacModel(
      signName: 'Terazi',
      symbol: '♎',
      element: 'Hava',
      modality: 'Öncü',
      dateRangeStr: '23 Eylül - 22 Ekim',
      headline: 'Güler yüzlü, estetik duygusu yüksek, uyum ve huzur elçisi melek.',
      temperament: 'Terazi bebeği gerginlikten ve yüksek tondaki tartışmalardan derinden etkilenir. Ortamda huzur ve yumuşak müzikler varsa dünyanın en uysal bebeğidir. İnsanları birleştirmeyi, gülümsetmeyi sever; estetik duyarlılığı çok erkenden kendini belli eder.',
      sensoryPlay: 'Pastel tonlardaki estetik mobiller, klasik müzik kutuları ve yumuşak tül kumaşlarla oynamaktan keyif alır. Aynada kendini incelemeye bayılır.',
      sleepTendency: 'Yumuşak tonda bir ninni veya klasik müzik eşliğinde huzurla gözlerini yumar. Loş ve estetik bir gece lambası rahatlatır.',
      emotionalNeeds: 'Denge, nezaket ve huzurlu bir aile ortamı. Sevgi dolu ses tonları onun güven temelidir.',
      parentingAdvice: 'Kararsız kaldığında ona baskı yapmayın; iki seçenek arasından kendi seçimini yapmasına rehberlik edin ve kararını destekleyin.',
      luckyColors: ['Pastel Pembe', 'Lavanta', 'Pudra Mavisi'],
      gemStone: 'Pembe Kuvars & Lapis',
    ),
    'Akrep': const BabyZodiacModel(
      signName: 'Akrep',
      symbol: '♏',
      element: 'Su',
      modality: 'Sabit',
      dateRangeStr: '23 Ekim - 21 Kasım',
      headline: 'Derin ve bilge bakışlı, güçlü sezgilere ve sarsılmaz sadakate sahip savaşçı.',
      temperament: 'Akrep bebeği gözlerinize baktığında ruhunuzu okuyormuş hissi verir. Çok güçlü bir iradesi ve sezgisi vardır. Yüzeysel ilgilerden hoşlanmaz, annesiyle kurduğu bağ adeta görünmez bir iple örülüdür. Gizemli köşeleri keşfetmeyi ve nesneleri saklayıp bulmayı çok sever.',
      sensoryPlay: 'Ce-e (peek-a-boo) oyunları, saklambaç, iç içe geçen gizli kutular ve su oyunları onun merakını derinden doyurur.',
      sleepTendency: 'Loş, korunaklı ve mağara hissi veren sakin köşelerde çok derin uyur. Fazla ışık ve hareket uykusunu bölebilir.',
      emotionalNeeds: 'Dürüstlük ve sarsılmaz bir güven hissi. Annenin duygusal olarak tutarlı olması onun en büyük ihtiyacıdır.',
      parentingAdvice: 'İnatlaştığında güç savaşına girmeyin; sakin ve sağlam bir duruş sergileyerek duygularını özgürce yaşamasına alan açın.',
      luckyColors: ['Bordo', 'Gece Mavisi', 'Koyu Erik'],
      gemStone: 'Obsidyen & Granat (Lal)',
    ),
    'Yay': const BabyZodiacModel(
      signName: 'Yay',
      symbol: '♐',
      element: 'Ateş',
      modality: 'Değişken',
      dateRangeStr: '22 Kasım - 21 Aralık',
      headline: 'Özgür ruhlu, açık havanın ve neşeli kahkahaların küçük gezgini.',
      temperament: 'Yay bebeği dört duvar arasında kalmaktan çabuk sıkılır. Puset gezintileri, doğanın kokusu ve rüzgarın dokunuşu onun ruhunu besler. İnanılmaz derecede iyimser, neşeli ve maceraperesttir. Düştüğünde bile güler yüzle ayağa kalkmaya meyillidir.',
      sensoryPlay: 'Geniş açık alanlar, hayvan figürlü oyuncaklar, farklı dillerde müzikler ve keşif dolu doğa yürüyüşleri onun favorisidir.',
      sleepTendency: 'Gezintide, arabada ya da temiz hava eşliğinde çok kolay uykuya dalar. Uyku ortamının ferah olması önemlidir.',
      emotionalNeeds: 'Hareket özgürlüğü ve kısıtlanmama hissi. Dünyayı kendi hızında tanımasına izin verilmesi mutluluk kaynağıdır.',
      parentingAdvice: 'Onu sık sık doğayla buluşturun; enerjisini atabileceği açık alanlar sağlayın ve keşif merakını kısıtlamayın.',
      luckyColors: ['Turkuaz', 'Kraliyet Mavisi', 'Mor'],
      gemStone: 'Lapis Lazuli & Turkuaz',
    ),
    'Oğlak': const BabyZodiacModel(
      signName: 'Oğlak',
      symbol: '♑',
      element: 'Toprak',
      modality: 'Sabit',
      dateRangeStr: '22 Aralık - 19 Ocak',
      headline: 'Sabırlı, olgun bakışlı, azimli ve kendi ayakları üzerinde duran küçük lider.',
      temperament: 'Oğlak bebeği yaşından çok daha olgun ve bilge bir havaya sahiptir. Bir oyuncağın mekanizmasını çözene kadar bıkmadan dener. Kararlı, sabırlı ve sorumluluk sahibidir. Başarı hissi ve ebeveynlerinin güveni onun içsel motivasyonunu besler.',
      sensoryPlay: 'Ahşap yapı blokları, kuleler, mantık ve eşleştirme kartları onun odaklanmasını güçlendirir. Kendi yaptığı yapıların bozulmamasını ister.',
      sleepTendency: 'Belli bir uyku ritüeline ve saatine sadıktır. Programı korunduğunda düzenli ve sakin uyur.',
      emotionalNeeds: 'Ciddiye alınmak ve saygı görmek. Ona verilen sözlerin tutulması güven duygusunun temel taşıdır.',
      parentingAdvice: 'Onu çocukluğunu yaşaması, şımarması ve tasasızca gülmesi için teşvik edin; her zaman güçlü olması gerekmediğini hissettirin.',
      luckyColors: ['Kömür Grisi', 'Haki Yeşil', 'Toprak Kahvesi'],
      gemStone: 'Oniks & Dumanlı Kuvars',
    ),
    'Kova': const BabyZodiacModel(
      signName: 'Kova',
      symbol: '♒',
      element: 'Hava',
      modality: 'Sabit',
      dateRangeStr: '20 Ocak - 18 Şubat',
      headline: 'Sıra dışı zekalı, özgün fikirli ve yenilikçi küçük mucit.',
      temperament: 'Kova bebeği standart şeylerden çabuk sıkılır; evdeki ilginç aletler, ışık düğmeleri ve farklı nesneler ilgisini daha çok çeker. Bağımsızlığına çok düşkündür. Sosyaldir ancak kendi sınırlarını da titizlikle korur.',
      sensoryPlay: 'Elektronik sesli ve ışıklı interaktif oyuncaklar, uzay ve bilim temalı kitaplar, karmaşık mekanik parçalar zihnini büyüler.',
      sleepTendency: 'Zihni uykuda bile yeni bağlantılar kurduğu için beyaz gürültü veya yumuşak ambient frekanslar uykuya dalmasını kolaylaştırır.',
      emotionalNeeds: 'Bireyselliğine ve özgün tercihlerine saygı duyulması. Onu kalıplara zorlamamak en büyük sevgi dilidir.',
      parentingAdvice: 'Onun yaratıcı ve sıra dışı fikirlerini destekleyin; arkadaş canlısı yaklaşın ve kendi yolunu çizmesine fırsat tanıyın.',
      luckyColors: ['Elektrik Mavisi', 'Gümüş', 'Turkuaz'],
      gemStone: 'Ametist & Florit',
    ),
    'Balık': const BabyZodiacModel(
      signName: 'Balık',
      symbol: '♓',
      element: 'Su',
      modality: 'Değişken',
      dateRangeStr: '19 Şubat - 20 Mart',
      headline: 'Hayalperest, narin kalpli, müzik ve masallarla yaşayan empati ustası.',
      temperament: 'Balık bebeği adeta masal dünyasından gelmiş gibi narin ve sevgi doludur. Müzikle uyur, suyla dans eder ve insanların duygularını doğrudan hisseder. Sert ses tonlarından ve ani hareketlerden hemen etkilenebilir; ona hep yumuşaklıkla yaklaşılmalıdır.',
      sensoryPlay: 'Su havuzu oyunları, sulu boya ve parmak boyaları, yumuşak pelüşler ve rüya gibi masal müzikleri onun ruhunu besler.',
      sleepTendency: 'Su şırıltısı, kalp atışı sesleri ve yumuşak ninniler eşliğinde mışıl mışıl dalar. Rüya dünyası çok renklidir.',
      emotionalNeeds: 'Koşulsuz şefkat, sarılma ve sakin bir atmosfer. Kendini güvende hissettiğinde yaratıcılığı çiçek açar.',
      parentingAdvice: 'Duygusal hassasiyetini kucaklayın; sanat ve müzikle kendini ifade etmesini sağlayın ve onu gerçek dünyanın karmaşasından nazikçe koruyun.',
      luckyColors: ['Deniz Yeşili', 'Lavanta', 'Okyanus Mavisi'],
      gemStone: 'Akuamarin & Ay Taşı',
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
      sensoryPlay: sensoryPlay,
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
