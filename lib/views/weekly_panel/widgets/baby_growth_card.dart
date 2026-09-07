import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../core/widgets/fruit_3d_widget.dart';

/// Claymorphic Bebek Büyüklük ve Gelişim Kartı (4 Farklı Boyut Teması Destekli)
class BabyGrowthCard extends StatefulWidget {
  final int week;
  final Map<String, dynamic> weekData;
  final String? babyDisplayName;

  const BabyGrowthCard({
    super.key,
    required this.week,
    required this.weekData,
    this.babyDisplayName,
  });

  @override
  State<BabyGrowthCard> createState() => _BabyGrowthCardState();
}

class _BabyGrowthCardState extends State<BabyGrowthCard> {
  @override
  Widget build(BuildContext context) {
    final fallbackFruit = widget.weekData['fruit_name'] as String? ?? 'baby_growth_fallback'.tr();
    final length = widget.weekData['length'] as String? ?? '~30.0 cm';
    final weight = widget.weekData['weight'] as String? ?? '~600 g';
    final babyDev = widget.weekData['baby_dev'] as String? ?? '';
    final motherChanges = widget.weekData['mother_changes'] as String? ?? '';
    final babyName = widget.babyDisplayName ?? 'baby_default_name'.tr();

    return Column(
      children: [
        // 1. Birleştirilmiş Hafta Serüveni & Bebeğin Gelişim Kartı
        ClayCard(
          color: AppColors.clayPeach,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık Alanı (X. Hafta Serüveni & Bebek Adı)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'weekly_seruven_title'.tr(args: [widget.week.toString()]),
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.secondaryPeach,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'baby_size_fruit_format'.tr(args: [babyName, fallbackFruit]),
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryDark,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${widget.week}. Hafta',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 3D Meyve ve Boy / Kilo Detayları
              Row(
                children: [
                  Fruit3DWidget(
                    week: widget.week,
                    size: 72,
                    borderRadius: 22,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Row(
                      children: [
                        // Tahmini Boy
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            decoration: ClayTheme.clayButtonDecoration(
                              color: Colors.white,
                              borderRadius: 16,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'baby_est_length'.tr(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  length,
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Tahmini Ağırlık
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            decoration: ClayTheme.clayButtonDecoration(
                              color: Colors.white,
                              borderRadius: 16,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'baby_est_weight'.tr(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  weight,
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Bebeğin Bu Haftaki Detaylı Gelişimi
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.clayRose,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(Icons.auto_awesome_rounded, color: AppColors.primaryPink, size: 16),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'baby_developing_title'.tr(args: [babyName]),
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getEnrichedBabyDev(widget.week, babyDev, babyName),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 3. Annedeki Değişimler Kartı (Liquid Glass Katmanı)
        ClayCard(
          isGlazed: true,
          color: AppColors.clayLavender,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.clayRose,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Icon(Icons.spa_rounded, color: AppColors.lavenderPurple, size: 18),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'baby_mother_changes'.tr(),
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                motherChanges,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 4. Doktor Bilgilendirme ve Tıbbi Feragat Uyarısı
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: ClayTheme.concaveDecoration(
            color: AppColors.backgroundSubtle,
            borderRadius: 16,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.medical_information_outlined, color: AppColors.lavenderPurple, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'disclaimer_weekly'.tr(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Haftalık bebeğin gelişimini daha detaylı ve bilgilendirici kılan medikal rehber
  String _getEnrichedBabyDev(int week, String rawDev, String babyName) {
    final isEn = context.locale.languageCode == 'en';

    final Map<int, String> weeklyDetailsTr = {
      1: 'Hücresel düzeyde mucizevi yolculuk başlıyor. Genetik şifreler belirleniyor ve rahme yerleşme hazırlıkları yapılıyor.',
      2: 'Döllenen yumurta hızla bölünerek blastosist evresine ulaşıyor. Hücreler bebeği ve plasentayı oluşturmak üzere ayrışıyor.',
      3: 'İmplantasyon (yerleşme) gerçekleşiyor. İlkel amniyon kesesi ve plasenta tabakası besin transferi için şekilleniyor.',
      4: 'Nöral tüp (beyin ve omurilik temeli) hızla gelişiyor. Kalp taslağı oluşmaya ve ilk minik ritimlerini atmaya hazırlanıyor.',
      5: 'Bebeğin kalbi düzenli atmaya başladı! Beyin lobları, minik kol ve bacak tomurcukları belirginleşiyor.',
      6: 'Gözler, burun delikleri ve iç kulak yapıları şekilleniyor. Kalp atışı dakikada 100-160 atım hızında ultrasonla duyulabilir.',
      7: 'Beyin her dakika binlerce yeni nöron üretiyor. El ve ayak parmak taslakları belirginleşiyor, karaciğer kan hücresi üretiyor.',
      8: 'Göz kapakları ve burun ucu seçilebiliyor. Minik parmaklar perdeli de olsa uzuyor, bebek rahim içinde minik hareketler yapıyor.',
      9: 'Artık embriyo evresinden fetüs evresine geçildi! Tüm hayati organlar yerli yerinde ve hızla olgunlaşma sürecinde.',
      10: 'Hayati organlar işlev kazanmaya başladı; böbrekler idrar üretiyor, tırnak yatakları ve saç kökleri oluşuyor.',
      11: 'Minik kemikler sertleşiyor, diyafram geliştikçe bebek yutkunma ve hıçkırma denemeleri yapıyor. Parmaklar tek tek ayrıştı ve esneme hareketleri yapıyor.',
      12: 'Refleksler canlandı; bebek parmaklarını açıp kapatabilir, ayaklarını kıvırabilir. Yüz hatları tamamen insansı bir profil kazandı.',
      13: 'İkinci trimestere hoş geldiniz! Ses telleri gelişiyor, bebeğinizin kendine özgü parmak izi oluşmaya başladı.',
      14: 'Bebeğiniz yüz mimikleri yapabiliyor; kaş çatabilir, gülümseyebilir. Vücudu koruyucu ince ayva tüyleri (lanugo) ile kaplanıyor.',
      15: 'Işığa karşı duyarlılık başladı. Kemik iliği kan üretimine katılıyor, bacaklar kollardan daha uzun hale geliyor.',
      16: 'Gözleri kapalıyken bile ışığı algılayabilir. Kalp her gün yaklaşık 28 litre kan pompalayarak muhteşem bir dolaşım sağlıyor.',
      17: 'İskelet kıkırdaktan sert kemiğe dönüşüyor. Göbek bağı kalınlaşıp güçleniyor, bebek yağı depolamaya başlıyor.',
      18: 'Kulakları artık dış dünyayı duyabilecek olgunlukta! Anne kalp atışlarını, kan akışını ve sizin sesinizi dinliyor.',
      19: 'Bebeğin cildini koruyan kremsi verniks kazeoza tabakası oluştu. Beyinde tat, koku, işitme ve görme merkezleri hızla özelleşiyor.',
      20: 'Yarı yolu tamamladınız! Bebeğin tekmeleri ve taklaları artık dışarıdan da hissedilebilir kıvama geliyor.',
      21: 'Sindirim sistemi amniyon sıvısını emebiliyor. Kemik iliği artık ana kan üretim merkezi haline geldi.',
      22: 'Dokunma duyusu çok gelişti; elleriyle yüzüne, göbek kordonuna dokunuyor ve kavrama refleksini keşfediyor.',
      23: 'Akciğerlerde kan damarları gelişiyor. Hızlı göz hareketleri (REM uykusu) evresi başladı; bebeğiniz rüya görüyor olabilir!',
      24: 'Akciğer kesecikleri nefes alıp vermeyi sağlayan sürfaktan maddesini üretmeye başlıyor. Denge mekanizması gelişti.',
      25: 'Bebeğiniz tanıdık seslere minik hareketlerle yanıt verebilir. Cilt altındaki kılcal damarlar genişleyerek pembe rengi veriyor.',
      26: 'Göz kapakları artık aralanabiliyor! Işığa tepki olarak gözlerini kırpıştırıyor ve uyku döngüleri belirginleşiyor.',
      27: 'İkinci trimesterin son haftası! Akciğerler ritmik solunum antrenmanları yapıyor, beyin dalgaları yeni doğan bebeğe benziyor.',
      28: 'Üçüncü trimestere adım attınız! Gözlerini tamamen açıp kapatabiliyor, kirpikleri uzadı ve vücut yağı artıyor.',
      29: 'Beyin milyarlarca nöronla hızla büyüyor. Kemiklerin sertleşmesi için kalsiyum transferi zirve noktasına ulaştı.',
      30: 'Bebeğiniz çevresini net bir şekilde algılıyor. Beyin kıvrımları hızla artarak zihinsel kapasiteyi genişletiyor.',
      31: 'Beş duyusu da aktif! Işığa dönebilir, tatları ayırt edebilir ve annesinin ses tonuna göre sakinleşebilir.',
      32: 'Tırnakları parmak uçlarına kadar uzadı. Günün büyük kısmını derin ve hafif uykuda dinlenerek geçiriyor.',
      33: 'Bağışıklık sistemi güçleniyor; anne antikorları plasenta yoluyla bebeğe aktarılarak onu koruma kalkanına alıyor.',
      34: 'Merkezi sinir sistemi ve akciğerler neredeyse tamamen olgunlaştı. Cildi pürüzsüzleşiyor ve bebek dolgunlaşıyor.',
      35: 'Böbrekler tamamen gelişti, karaciğer bazı atıkları işleyebiliyor. Rahim içi daraldıkça güçlü gerinme hareketleri yapıyor.',
      36: 'Bebeğiniz genellikle doğum pozisyonunu (baş aşağı) almıştır. Kemikleri sertleşti ancak doğum kanalından geçiş için kafa kemikleri esnek kalır.',
      37: 'Bebeğiniz artık erken doğum sınırını aştı (erken miad). Emiş refleksi ve solunum koordinasyonu mükemmel çalışıyor.',
      38: 'Tüm organ sistemleri dış dünyada yaşamaya hazır. Kavrama refleksi o kadar güçlü ki elleriyle sıkıca tutunabilir.',
      39: 'Göğüs kafesi dolgunlaştı, vücut yağı ısı dengesini koruyacak seviyede. Her an kavuşma heyecanı kapıda!',
      40: 'Büyük gün geldi! Bebeğiniz hazır, dünyayla tanışmak ve anne kucağına kavuşmak için sabırsızlanıyor.',
    };

    final Map<int, String> weeklyDetailsEn = {
      1: 'The miraculous journey begins at the cellular level. Genetic code is set and implantation preparations begin in the uterus.',
      2: 'The fertilized egg divides rapidly to form a blastocyst. Cells specialize to form the baby and the placenta.',
      3: 'Implantation takes place. The primitive amniotic sac and placental barrier form for nutrient and oxygen transfer.',
      4: 'The neural tube (the foundation for brain and spinal cord) develops rapidly. The heart outline forms and prepares its earliest beats.',
      5: 'Your baby’s heart is now beating regularly! Brain hemispheres and tiny limb buds are emerging.',
      6: 'Eyes, nostrils, and inner ear structures take shape. Heartbeats (100-160 BPM) can now often be detected via ultrasound.',
      7: 'The brain generates thousands of new neurons every minute. Tiny hand and foot plates form, and liver produces blood cells.',
      8: 'Eyelids and tip of the nose are distinguishable. Fingers elongate, and baby begins gentle involuntary movements in the womb.',
      9: 'Transition from embryo to fetus! All essential organs are present and entering rapid maturation.',
      10: 'Vital organs start functioning; kidneys produce urine, while nail beds and hair follicles begin to develop.',
      11: 'Tiny bones are hardening, and as the diaphragm strengthens, baby practices swallowing and hiccuping. Fingers have separated.',
      12: 'Reflexes are active; baby can curl toes and grasp. Facial features have gained a distinct, human profile.',
      13: 'Welcome to the second trimester! Vocal cords are developing, and your baby’s unique fingerprints are forming.',
      14: 'Your baby can make facial expressions—frowning and smiling. Fine lanugo hair covers the skin for protection.',
      15: 'Light sensitivity begins. Bone marrow joins blood cell production, and legs grow longer than arms.',
      16: 'Baby can perceive light through closed eyelids. The heart pumps about 28 liters of blood daily through a thriving circulatory system.',
      17: 'Cartilage skeleton is hardening into sturdy bone. The umbilical cord thickens and baby begins storing adipose fat.',
      18: 'Ears can now pick up outside sounds! Baby listens to maternal heartbeats, rushing blood flow, and your soothing voice.',
      19: 'A protective layer of creamy vernix caseosa covers the skin. Sensory brain centers for taste, smell, and hearing specialize.',
      20: 'Halfway milestone reached! Baby’s kicks and somersaults can now be felt noticeably from the outside.',
      21: 'Digestive system absorbs small amounts of amniotic fluid. Bone marrow becomes the principal blood-forming center.',
      22: 'Sense of touch is remarkably keen; baby explores its face and cord with tiny fingers, exercising grasping reflexes.',
      23: 'Vascular branches proliferate in the lungs. REM sleep cycles begin; your little one may already be dreaming!',
      24: 'Lung air sacs begin producing surfactant for postnatal respiration. Inner ear balance mechanisms are well developed.',
      25: 'Baby responds to familiar voices with gentle nudges. Capillaries beneath the skin give it a healthy pink glow.',
      26: 'Eyelids can now open! Baby blinks in response to light, and sleep-wake cycles become more structured.',
      27: 'End of the second trimester! Rhythmic breathing movements practice lung expansion, and brain waves mirror a newborn.',
      28: 'Step into the third trimester! Baby can open and close eyes freely, eyelashes have grown, and body fat increases steadily.',
      29: 'The brain continues expanding with billions of neurons. Calcium transfer peaks to strengthen and calcify bones.',
      30: 'Baby perceives its surroundings clearly. Brain surface folds deepen, enhancing cognitive and neural capacity.',
      31: 'All five senses are active! Baby turns toward light, tastes flavors in amniotic fluid, and calms to mom’s voice.',
      32: 'Fingernails reach the tips of tiny fingers. Most of the day is spent resting in deep and light sleep.',
      33: 'The immune system receives maternal antibodies through the placenta, building an essential protective shield.',
      34: 'Central nervous system and lungs are nearly mature. Skin softens and baby plumps up with healthy protective fat.',
      35: 'Kidneys are fully matured, and liver processes metabolic products. Baby performs strong stretching movements in cozy quarters.',
      36: 'Baby typically settles into the head-down birth position. Bones are firm, while cranial skull bones stay flexible for labor.',
      37: 'Baby reaches early term! Sucking reflex and breathing coordination are refined and ready for the outside world.',
      38: 'All organ systems are prepared for independent life. Grasping reflex is strong enough to hold on firmly.',
      39: 'Chest is rounded and subcutaneous fat regulates post-birth temperature. The joyous meeting is just around the corner!',
      40: 'The big day has arrived! Your baby is fully grown, healthy, and eagerly waiting to be held in your loving arms.',
    };

    final pool = isEn ? weeklyDetailsEn : weeklyDetailsTr;
    final enriched = pool[week] ?? '';

    if (rawDev.isNotEmpty && !rawDev.startsWith('week_')) {
      return '$rawDev\n\n$enriched';
    }
    return enriched.isNotEmpty
        ? enriched
        : (isEn
            ? '$babyName continues to grow rapidly this week, strengthening muscles and nerves for birth.'
            : '$babyName bu hafta hızla büyümeye, kas ve sinir sistemini güçlendirerek doğum yolculuğuna hazırlanmaya devam ediyor.');
  }
}
