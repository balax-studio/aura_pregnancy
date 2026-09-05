import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:aura_pregnancy/main.dart';
import 'package:aura_pregnancy/models/profile_model.dart';
import 'package:aura_pregnancy/models/diary_model.dart';
import 'package:aura_pregnancy/services/database_helper.dart';
import 'package:aura_pregnancy/services/debug_seeder_service.dart';
import 'package:aura_pregnancy/services/video_story_generator_service.dart';
import 'package:aura_pregnancy/views/main_navigation_scaffold.dart';
import 'package:aura_pregnancy/views/weekly_panel/widgets/baby_growth_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('tr_TR', null);
  });

  group('Kalıcı Kayıt & Kişiselleştirilmiş Bebek İsmi / Cinsiyet Testleri', () {
    test('1. ProfileModel isim ve cinsiyet yardımcı fonksiyonları doğru çalışır', () {
      final namedGirl = ProfileModel(
        dueDate: '2026-11-20',
        prePregnancyWeight: 60,
        height: 165,
        vki: 22,
        currentWeek: 16,
        momName: 'Elif',
        babyName: 'Ayşe',
        babyGender: 'girl',
      );

      expect(namedGirl.babyDisplayName, equals('Ayşe Bebek'));
      expect(namedGirl.babySimpleName, equals('Ayşe'));
      expect(namedGirl.genderEmoji, equals('👧'));
      expect(namedGirl.genderTitle, contains('Kız'));

      final namedBoy = ProfileModel(
        dueDate: '2026-11-20',
        prePregnancyWeight: 60,
        height: 165,
        vki: 22,
        currentWeek: 16,
        babyName: 'Mehmet',
        babyGender: 'boy',
      );

      expect(namedBoy.babyDisplayName, equals('Mehmet Bebek'));
      expect(namedBoy.babySimpleName, equals('Mehmet'));
      expect(namedBoy.genderEmoji, equals('👦'));
      expect(namedBoy.genderTitle, contains('Erkek'));

      final unnamedSurprise = ProfileModel(
        dueDate: '2026-11-20',
        prePregnancyWeight: 60,
        height: 165,
        vki: 22,
        currentWeek: 16,
        babyGender: 'surprise',
      );

      expect(unnamedSurprise.babyDisplayName, equals('Bebeğiniz'));
      expect(unnamedSurprise.babySimpleName, equals('Bebeğiniz'));
      expect(unnamedSurprise.genderEmoji, equals('💛'));
    });

    test('2. Profil veritabanına kaydedildiğinde kalıcı olarak okunur', () async {
      final profile = ProfileModel(
        dueDate: '2026-12-01',
        prePregnancyWeight: 57.5,
        height: 170,
        vki: 19.9,
        currentWeek: 18,
        momName: 'Zeynep',
        babyName: 'Mavi',
        babyGender: 'girl',
      );

      await DatabaseHelper.instance.saveProfile(profile);

      final retrieved = await DatabaseHelper.instance.getProfile();
      expect(retrieved, isNotNull);
      expect(retrieved!.babyName, equals('Mavi'));
      expect(retrieved.momName, equals('Zeynep'));
      expect(retrieved.babyDisplayName, equals('Mavi Bebek'));
      expect(retrieved.currentWeek, equals(18));
    });

    test('3. Canlı Reaktivite: Hafta veya veri değiştiğinde appDataRevision tetiklenir', () async {
      int changeCount = 0;
      void listener() {
        changeCount++;
      }

      DatabaseHelper.appDataRevision.addListener(listener);

      // Hafta değiştir
      await DebugSeederService.instance.jumpToWeek(24);
      expect(changeCount, greaterThan(0));

      final prevCount = changeCount;
      // Profil güncelle
      await DatabaseHelper.instance.updateCurrentWeek(25);
      expect(changeCount, greaterThan(prevCount));

      DatabaseHelper.appDataRevision.removeListener(listener);
    });

    test('4. Video Story Generator bebeğin ismini başlık ve alıntılarda kullanır', () async {
      final profile = ProfileModel(
        dueDate: '2026-12-01',
        prePregnancyWeight: 57.5,
        height: 170,
        vki: 19.9,
        currentWeek: 20,
        babyName: 'Mehmet',
        babyGender: 'boy',
      );
      await DatabaseHelper.instance.saveProfile(profile);
      await DatabaseHelper.instance.insertDiary(
        DiaryModel(
          pregnancyWeek: 20,
          date: '2026-08-29',
          noteText: 'Mehmet bebeğimiz tekmeliyor.',
          isRomanticHighlight: true,
        ),
      );

      final frames = await VideoStoryGeneratorService.instance.generateStoryFrames();
      expect(frames, isNotEmpty);
      expect(frames.any((f) => f.title.contains('Mehmet Bebek') || f.quote.contains('Mehmet Bebek')), isTrue);
    });

    testWidgets('5. BabyGrowthCard bebeğin ismiyle özel hitap render eder', (WidgetTester tester) async {
      await tester.pumpWidget(
        createLocalizedTestWidget(
          child: const Scaffold(
            body: BabyGrowthCard(
              week: 16,
              weekData: {
                'fruit': '🥑',
                'fruit_name': 'Avokado',
                'length': '12 cm',
                'weight': '100 gr',
                'baby_dev': 'Bebeğiniz kaşlarını çatabiliyor.',
                'mother_changes': 'Enerjiniz artıyor.',
              },
              babyDisplayName: 'Mehmet Bebek',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('baby_week_name_label'.tr(args: ['16', 'Mehmet Bebek'])), findsOneWidget);
      expect(find.text('baby_dev_status'.tr(args: ['Mehmet Bebek'])), findsOneWidget);
      expect(find.text('Avokado'), findsOneWidget);
    });

    testWidgets('6. Profil var olduğunda RootGateScreen doğrudan MainNavigationScaffold açar', (WidgetTester tester) async {
      await DatabaseHelper.instance.ensureDefaultProfile();

      await tester.pumpWidget(
        createLocalizedTestWidget(
          child: const RootGateScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(MainNavigationScaffold), findsOneWidget);
    });

    test('7. Onboarding ve rehber ayarları kalıcı olarak kaydedilir ve okunur', () async {
      expect(await DatabaseHelper.instance.isOnboardingCompleted(), isTrue);
      
      await DatabaseHelper.instance.setSetting('has_selected_language', 'true');
      await DatabaseHelper.instance.setSetting('has_seen_guide', 'true');
      
      expect(await DatabaseHelper.instance.hasSelectedLanguage(), isTrue);
      expect(await DatabaseHelper.instance.hasSeenGuide(), isTrue);
    });

    testWidgets('8. Bilgileri kayıtlı kullanıcı tekrar dil ve rehber ekranlarını görmez', (WidgetTester tester) async {
      final prof = await DatabaseHelper.instance.getProfile();
      expect(prof, isNotNull);
      expect(await DatabaseHelper.instance.isOnboardingCompleted(), isTrue);

      await tester.pumpWidget(
        createLocalizedTestWidget(
          child: const RootGateScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      // Ana sayfa görünmeli, dil seçimi veya rehber görünmemeli
      expect(find.byType(MainNavigationScaffold), findsOneWidget);
      expect(find.text('Choose Your Language'), findsNothing);
      expect(find.text('Dil Seçiminizi Yapın'), findsNothing);
    });
  });
}
