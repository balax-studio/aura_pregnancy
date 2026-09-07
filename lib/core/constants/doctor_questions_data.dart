import '../../models/doctor_question_model.dart';

/// Aura Pregnancy - Trimester Bazlı Önceden Tanımlı Klinik Sorular Kasası
class DoctorQuestionsData {
  static List<DoctorQuestion> getPredefinedQuestions(int trimester, {String lang = 'tr'}) {
    List<DoctorQuestion> baseList;
    switch (trimester) {
      case 1:
        baseList = _trimester1;
        break;
      case 2:
        baseList = _trimester2;
        break;
      case 3:
      default:
        baseList = _trimester3;
        break;
    }

    if (lang == 'en') {
      return baseList
          .map((q) => q.copyWith(question: getLocalizedQuestion(q.question, 'en')))
          .toList();
    }
    return baseList;
  }

  static String getLocalizedQuestion(String question, String lang) {
    if (lang == 'en') {
      return _trToEnMap[question] ?? question;
    }
    return _enToTrMap[question] ?? question;
  }

  static const Map<String, String> _trToEnMap = {
    'Kullandığım folik asit ve vitamin dozu kan değerlerime göre yeterli mi?':
        'Is my dosage of folic acid and prenatal vitamins sufficient based on my blood tests?',
    'İkili tarama testi (veya NIPT/fetal DNA testi) randevumu ne zaman planlamalıyız?':
        'When should we schedule my first-trimester combined screening (or NIPT/fetal DNA test)?',
    'Şiddetli sabah bulantısı ve halsizlik için gebelikte güvenli hangi çözümleri önerirsiniz?':
        'What pregnancy-safe remedies do you recommend for severe morning sickness and fatigue?',
    'Hafif lekelenme veya kasık batması yaşadığımda acil servise hangi durumda başvurmalıyım?':
        'Under what circumstances should I visit the emergency room if I experience mild spotting or pelvic cramping?',
    'Detaylı (ayrıntılı) fetal ultrason için en ideal hafta hangisi ve perinatolog öneriniz var mı?':
        'What is the best week for the detailed fetal anatomy ultrasound, and do you have a perinatologist recommendation?',
    'Bebeğimin tekmelerini ve hareketlerini gün içinde hangi yoğunlukta hissetmem normal?':
        'How often and intensely should I normally feel my baby\'s kicks and movements throughout the day?',
    '24-28. haftalar arasındaki glikoz yükleme (şeker) testi sürecim nasıl ilerleyecek?':
        'How will the glucose tolerance screening between weeks 24 and 28 be conducted?',
    'Gebelikte güvenli seyahat (uçak/araba) ve hamilelik yogası için onayınız var mı?':
        'Do you approve safe travel (flying/driving) and prenatal yoga at this stage?',
    'Doğum çantamı en geç kaçıncı haftada arabaya/kapı önüne hazır koymalıyım?':
        'By which week at the latest should my hospital bag be packed and ready by the door?',
    'Bebek hareketleri sayımında (Kick Count) 2 saatte 10 hareket kuralı benim için geçerli mi?':
        'Does the rule of counting 10 kicks within 2 hours apply to my daily routine?',
    'Yalancı kasılmalar (Braxton Hicks) ile gerçek doğum kasılmasını ayırt eden en belirgin işaret nedir?':
        'What is the clearest distinguishing sign between Braxton Hicks contractions and true labor contractions?',
    'Doğum planımda epidural, ten tene temas (Golden Hour) ve kordon klempleme taleplerimi nasıl uygulayacağız?':
        'How will we accommodate my birth preferences regarding epidural, skin-to-skin (Golden Hour), and delayed cord clamping?',
    'Suyum geldiğinde veya sancım başladığında hangi aşamada (kaç dakikada bir) hastaneye gelmeliyim?':
        'At what contraction frequency (or if my water breaks) should I head directly to the hospital?',
  };

  static final Map<String, String> _enToTrMap = {
    for (final e in _trToEnMap.entries) e.value: e.key,
  };

  static const List<DoctorQuestion> _trimester1 = [
    DoctorQuestion(
      pregnancyWeek: 8,
      trimester: 1,
      question: 'Kullandığım folik asit ve vitamin dozu kan değerlerime göre yeterli mi?',
      isPredefined: true,
      createdDate: '2026-01-01',
    ),
    DoctorQuestion(
      pregnancyWeek: 11,
      trimester: 1,
      question: 'İkili tarama testi (veya NIPT/fetal DNA testi) randevumu ne zaman planlamalıyız?',
      isPredefined: true,
      createdDate: '2026-01-01',
    ),
    DoctorQuestion(
      pregnancyWeek: 7,
      trimester: 1,
      question: 'Şiddetli sabah bulantısı ve halsizlik için gebelikte güvenli hangi çözümleri önerirsiniz?',
      isPredefined: true,
      createdDate: '2026-01-01',
    ),
    DoctorQuestion(
      pregnancyWeek: 10,
      trimester: 1,
      question: 'Hafif lekelenme veya kasık batması yaşadığımda acil servise hangi durumda başvurmalıyım?',
      isPredefined: true,
      createdDate: '2026-01-01',
    ),
  ];

  static const List<DoctorQuestion> _trimester2 = [
    DoctorQuestion(
      pregnancyWeek: 19,
      trimester: 2,
      question: 'Detaylı (ayrıntılı) fetal ultrason için en ideal hafta hangisi ve perinatolog öneriniz var mı?',
      isPredefined: true,
      createdDate: '2026-01-01',
    ),
    DoctorQuestion(
      pregnancyWeek: 20,
      trimester: 2,
      question: 'Bebeğimin tekmelerini ve hareketlerini gün içinde hangi yoğunlukta hissetmem normal?',
      isPredefined: true,
      createdDate: '2026-01-01',
    ),
    DoctorQuestion(
      pregnancyWeek: 24,
      trimester: 2,
      question: '24-28. haftalar arasındaki glikoz yükleme (şeker) testi sürecim nasıl ilerleyecek?',
      isPredefined: true,
      createdDate: '2026-01-01',
    ),
    DoctorQuestion(
      pregnancyWeek: 22,
      trimester: 2,
      question: 'Gebelikte güvenli seyahat (uçak/araba) ve hamilelik yogası için onayınız var mı?',
      isPredefined: true,
      createdDate: '2026-01-01',
    ),
  ];

  static const List<DoctorQuestion> _trimester3 = [
    DoctorQuestion(
      pregnancyWeek: 29,
      trimester: 3,
      question: 'Doğum çantamı en geç kaçıncı haftada arabaya/kapı önüne hazır koymalıyım?',
      isPredefined: true,
      createdDate: '2026-01-01',
    ),
    DoctorQuestion(
      pregnancyWeek: 32,
      trimester: 3,
      question: 'Bebek hareketleri sayımında (Kick Count) 2 saatte 10 hareket kuralı benim için geçerli mi?',
      isPredefined: true,
      createdDate: '2026-01-01',
    ),
    DoctorQuestion(
      pregnancyWeek: 34,
      trimester: 3,
      question: 'Yalancı kasılmalar (Braxton Hicks) ile gerçek doğum kasılmasını ayırt eden en belirgin işaret nedir?',
      isPredefined: true,
      createdDate: '2026-01-01',
    ),
    DoctorQuestion(
      pregnancyWeek: 36,
      trimester: 3,
      question: 'Doğum planımda epidural, ten tene temas (Golden Hour) ve kordon klempleme taleplerimi nasıl uygulayacağız?',
      isPredefined: true,
      createdDate: '2026-01-01',
    ),
    DoctorQuestion(
      pregnancyWeek: 37,
      trimester: 3,
      question: 'Suyum geldiğinde veya sancım başladığında hangi aşamada (kaç dakikada bir) hastaneye gelmeliyim?',
      isPredefined: true,
      createdDate: '2026-01-01',
    ),
  ];
}
