import 'package:flutter_test/flutter_test.dart';
import 'package:aura_pregnancy/models/hospital_bag_item.dart';
import 'package:aura_pregnancy/models/doctor_question_model.dart';
import 'package:aura_pregnancy/models/time_capsule_model.dart';
import 'package:aura_pregnancy/models/safety_item_model.dart';
import 'package:aura_pregnancy/core/constants/safety_radar_data.dart';
import 'package:aura_pregnancy/core/constants/baby_zodiac_data.dart';
import 'package:aura_pregnancy/core/constants/baby_size_themes_data.dart';
import 'package:aura_pregnancy/services/database_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await DatabaseHelper.instance.clearAllData();
  });

  group('Aura 11 Yeni Özellik - Veri & Model Birim Testleri', () {
    test('1. HospitalBagItem ve DatabaseHelper CRUD Doğrulaması', () async {
      final db = DatabaseHelper.instance;
      // Varsayılan öğeler otomatik seed edilmeli
      final initialItems = await db.getHospitalBagItems();
      expect(initialItems.isNotEmpty, isTrue);

      final momItems = await db.getHospitalBagItems(category: 'mom');
      expect(momItems.isNotEmpty, isTrue);

      // Özel eşya ekleme
      final newId = await db.insertHospitalBagItem(
        const HospitalBagItem(
          category: 'mom',
          title: 'Özel Lavanta Kokulu Yastık Kılıfı',
          isCustom: true,
        ),
      );
      expect(newId, greaterThan(0));

      // İşaretleme (toggle)
      await db.toggleHospitalBagItem(newId, true);
      final updatedMomItems = await db.getHospitalBagItems(category: 'mom');
      final target = updatedMomItems.firstWhere((i) => i.id == newId);
      expect(target.isPacked, isTrue);

      // Silme
      await db.deleteHospitalBagItem(newId);
      final afterDelete = await db.getHospitalBagItems(category: 'mom');
      expect(afterDelete.any((i) => i.id == newId), isFalse);
    });

    test('2. DoctorQuestions ve Soru Kasası Doğrulaması', () async {
      final db = DatabaseHelper.instance;
      // Trimester 1 soruları
      final t1Questions = await db.getDoctorQuestions(trimester: 1);
      expect(t1Questions.isNotEmpty, isTrue);

      // Soru ekleme
      final qId = await db.insertDoctorQuestion(
        DoctorQuestion(
          pregnancyWeek: 12,
          trimester: 1,
          question: 'Haftada kaç saat yüzebilirim?',
          createdDate: DateTime.now().toIso8601String(),
        ),
      );
      expect(qId, greaterThan(0));

      // Yanıt notu ekleme ve cevaplandı olarak işaretleme
      await db.updateDoctorQuestionAnswer(qId, 'Günde 30 dk hafif tempoda serbest stil önerildi.', true);
      final questions = await db.getDoctorQuestions();
      final updatedQ = questions.firstWhere((q) => q.id == qId);
      expect(updatedQ.isAnswered, isTrue);
      expect(updatedQ.answerNote, contains('serbest stil'));
    });

    test('3. BirthPlanModel Serialization ve Kayıt Doğrulaması', () async {
      final db = DatabaseHelper.instance;
      final defaultPlan = await db.getBirthPlan();
      expect(defaultPlan.dimLights, isTrue);
      expect(defaultPlan.delayedCordClamping, isTrue);

      final customPlan = defaultPlan.copyWith(
        aromatherapy: true,
        specialWishes: 'Doğum salonunda sadece eşim ve ebem bulunsun.',
      );
      await db.saveBirthPlan(customPlan);

      final reloaded = await db.getBirthPlan();
      expect(reloaded.aromatherapy, isTrue);
      expect(reloaded.specialWishes, contains('ebem bulunsun'));
    });

    test('4. TimeCapsuleLetter Mühürlü Gelecek Mektubu Doğrulaması', () async {
      final db = DatabaseHelper.instance;
      final letter = TimeCapsuleLetter(
        unlockMilestone: '18th_birthday',
        title: 'Canım Kızım, 18. Yaşına Hoş Geldin',
        letterText: 'Şu an karnımda 28 haftalıksın ve her tekmende kalbim titriyor...',
        createdDate: DateTime.now().toIso8601String(),
        targetUnlockDate: '2044-09-07',
      );

      final id = await db.insertTimeCapsuleLetter(letter);
      expect(id, greaterThan(0));

      final letters = await db.getTimeCapsuleLetters();
      expect(letters.length, 1);
      expect(letters.first.isSealed, isTrue);
      expect(letters.first.milestoneTitle, contains('18. Yaş'));
    });

    test('5. SafetyRadarData Arama ve Semafor Mantığı Doğrulaması', () {
      // Çiğ köfte araması -> Sakıncalı (Unsafe)
      final rawMeatSearch = SafetyRadarData.search('çiğ');
      expect(rawMeatSearch.isNotEmpty, isTrue);
      expect(rawMeatSearch.any((i) => i.level == SafetyLevel.unsafe), isTrue);

      // Somon araması -> Güvenli (Safe)
      final salmonSearch = SafetyRadarData.search('somon');
      expect(salmonSearch.isNotEmpty, isTrue);
      expect(salmonSearch.any((i) => i.level == SafetyLevel.safe), isTrue);

      // Ton balığı -> Şartlı/Ölçülü (Moderate)
      final tunaSearch = SafetyRadarData.search('ton balığı');
      expect(tunaSearch.isNotEmpty, isTrue);
      expect(tunaSearch.any((i) => i.level == SafetyLevel.moderate), isTrue);
    });

    test('6. BabyZodiacData Burç, Element ve Uyum Motoru Doğrulaması', () {
      // 25 Temmuz -> Aslan (Ateş, Sabit)
      final leoBaby = BabyZodiacData.calculateFromDueDate(DateTime(2026, 7, 25));
      expect(leoBaby.signName, 'Aslan');
      expect(leoBaby.element, 'Ateş');
      expect(leoBaby.symbol, '♌');

      // 20 Kasım -> Akrep (Su, Sabit)
      final scorpioBaby = BabyZodiacData.calculateFromDueDate(DateTime(2026, 11, 20));
      expect(scorpioBaby.signName, 'Akrep');
      expect(scorpioBaby.element, 'Su');

      // Anne Akrep & Bebek Yengeç Uyumu (Su - Su aynı element)
      final compat = BabyZodiacData.calculateMotherBabyCompatibility('Akrep', 'Yengeç');
      expect(compat['score'], greaterThanOrEqualTo(90));
      expect(compat['summary'], contains('Su'));
    });

    test('7. BabySizeThemesData 4 Tema Boyut Doğrulaması', () {
      // 20. Hafta için tüm temaların verileri eksiksiz olmalı
      final fruit = BabySizeThemesData.getItemForWeek(20, BabySizeThemeType.fruit);
      expect(fruit.title, contains('Muz'));

      final animal = BabySizeThemesData.getItemForWeek(20, BabySizeThemeType.animal);
      expect(animal.title, contains('Tavşan'));

      final pastry = BabySizeThemesData.getItemForWeek(20, BabySizeThemeType.pastry);
      expect(pastry.title, contains('Kruvasan'));

      final toy = BabySizeThemesData.getItemForWeek(20, BabySizeThemeType.toy);
      expect(toy.title, contains('Müzik Kutusu'));
    });
  });
}
