import '../../models/doctor_question_model.dart';

/// Aura Pregnancy - Trimester Bazlı Önceden Tanımlı Klinik Sorular Kasası
class DoctorQuestionsData {
  static List<DoctorQuestion> getPredefinedQuestions(int trimester) {
    switch (trimester) {
      case 1:
        return _trimester1;
      case 2:
        return _trimester2;
      case 3:
      default:
        return _trimester3;
    }
  }

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
