import 'package:flutter_test/flutter_test.dart';
import 'package:aura_pregnancy/models/daily_log_model.dart';
import 'package:aura_pregnancy/models/diary_model.dart';
import 'package:aura_pregnancy/services/database_helper.dart';
import 'package:aura_pregnancy/views/timeline/timeline_screen.dart';
import 'package:aura_pregnancy/views/main_navigation_scaffold.dart';
import 'package:easy_localization/easy_localization.dart';
import 'test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await DatabaseHelper.instance.ensureDefaultProfile();
    await DatabaseHelper.instance.updateDailyLog(
      DailyLogModel(
        date: '2026-08-29',
        waterIntakeMl: 2000,
        caffeineMg: 60,
        stepCount: 4500,
        walkingMinutes: 25,
        weightEntry: 63.5,
      ),
    );
    await DatabaseHelper.instance.insertDiary(
      DiaryModel(
        pregnancyWeek: 16,
        date: '2026-08-29',
        noteText: 'Zaman tüneli için test anısı.',
        photoPath: 'assets/images/sample_ultrasound.png',
        audioPath: 'assets/audio/voice_letter.m4a',
        moodRating: 5,
        isRomanticHighlight: true,
      ),
    );
  });

  group('Zaman Tüneli (Timeline) Testleri', () {
    testWidgets('1. TimelineScreen genel istatistikleri ve gün kartını gösterir', (WidgetTester tester) async {
      await tester.pumpWidget(
        createLocalizedTestWidget(
          child: const TimelineScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('timeline_appbar_title'.tr()), findsOneWidget);
      expect(find.text('timeline_summary_title'.tr()), findsOneWidget);
      expect(find.text('Zaman tüneli için test anısı.'), findsWidgets);
    });

    testWidgets('2. Filtre butonları filtrelemeyi doğru yapar', (WidgetTester tester) async {
      await tester.pumpWidget(
        createLocalizedTestWidget(
          child: const TimelineScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('filter_all'.tr()), findsOneWidget);
      expect(find.text('filter_diaries'.tr()), findsOneWidget);
      expect(find.text('filter_steps'.tr()), findsOneWidget);

      // Anılar & Sesler filtresini seç
      await tester.tap(find.text('filter_diaries'.tr()));
      await tester.pumpAndSettle();
      expect(find.text('Zaman tüneli için test anısı.'), findsWidgets);

      // Yürüyüş & Adım filtresini seç
      await tester.tap(find.text('filter_steps'.tr()));
      await tester.pumpAndSettle();
      expect(find.byType(TimelineScreen), findsOneWidget);
    });

    testWidgets('3. MainNavigationScaffold ile Yolculuk sekmesine geçiş yapılır', (WidgetTester tester) async {
      await tester.pumpWidget(
        createLocalizedTestWidget(
          child: const MainNavigationScaffold(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // 1. Haftalık & Yolculuk ana sekmesine tıkla
      await tester.tap(find.text('nav_weekly'.tr()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // 2. Zaman Tüneli / Yolculuk alt sekmesine tıkla
      await tester.tap(find.text('nav_journey'.tr()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(TimelineScreen), findsOneWidget);
      expect(find.text('timeline_appbar_title'.tr()), findsOneWidget);
    });
  });
}
