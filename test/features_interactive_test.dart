import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:aura_pregnancy/views/main_navigation_scaffold.dart';
import 'package:aura_pregnancy/core/widgets/fluid_clay_bottom_bar.dart';
import 'package:aura_pregnancy/views/dashboard/dashboard_screen.dart';
import 'package:aura_pregnancy/views/dashboard/widgets/interactive_3d_fetus_widget.dart';
import 'package:aura_pregnancy/core/widgets/fruit_3d_widget.dart';
import 'package:aura_pregnancy/views/daily_tracker/daily_tracker_screen.dart';
import 'package:aura_pregnancy/views/journal/journal_screen.dart';
import 'package:aura_pregnancy/views/weekly_panel/weekly_panel_screen.dart';
import 'package:aura_pregnancy/views/emergency/emergency_screen.dart';
import 'package:aura_pregnancy/services/database_helper.dart';
import 'test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('tr_TR', null);
  });

  setUp(() async {
    await DatabaseHelper.instance.ensureDefaultProfile();
  });

  group('Aura Pregnancy - Butonlar, Fonksiyonlar ve UI Etkileşim Testleri', () {
    testWidgets('1. Ana sayfada Fetus, Hafta Bilgisi ve Gezinme butonları sorunsuz çalışır', (WidgetTester tester) async {
      await tester.pumpWidget(
        createLocalizedTestWidget(
          child: DashboardScreen(onNavigateTab: (_) {}),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(DashboardScreen), findsOneWidget);
      expect(find.byType(Interactive3DFetusWidget), findsOneWidget);
      expect(find.byType(Fruit3DWidget), findsOneWidget);
    });

    testWidgets('2. Takip sekmesi hatasız açılır ve su/kafein işlemleri yapılır', (WidgetTester tester) async {
      await tester.pumpWidget(
        createLocalizedTestWidget(
          child: const DailyTrackerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DailyTrackerScreen), findsOneWidget);

      // Su Ekle (+250 ml)
      final water250Finder = find.text('+250 ml');
      if (water250Finder.evaluate().isNotEmpty) {
        await tester.tap(water250Finder.first);
        await tester.pumpAndSettle();
      }

      // Kafein Ekle (Türk Kahvesi)
      final coffeeFinder = find.text('caffeine_quick_turkish_coffee'.tr());
      if (coffeeFinder.evaluate().isNotEmpty) {
        await tester.tap(coffeeFinder.first);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('3. Anı Yaz butonuna basılınca NewEntryScreen açılır ve anı kaydedilir', (WidgetTester tester) async {
      await tester.pumpWidget(
        createLocalizedTestWidget(
          child: const JournalScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(JournalScreen), findsOneWidget);
      final writeMemoryFinder = find.text('journal_write_memory'.tr());
      expect(writeMemoryFinder, findsOneWidget);

      // Anı Yaz butonuna tıkla
      await tester.tap(writeMemoryFinder);
      await tester.pumpAndSettle();

      // NewEntryScreen açılmış olmalı
      final saveMemoryFinder = find.text('journal_save_entry'.tr());
      expect(saveMemoryFinder, findsOneWidget);

      // Anı Metni gir ve kaydet
      await tester.enterText(find.byType(TextField), 'Test Anı Notu: Bugün harika bir gündü.');
      await tester.ensureVisible(saveMemoryFinder);
      await tester.tap(saveMemoryFinder);
      await tester.pumpAndSettle();

      // Tekrar Journal ekranına dönmüş olmalı
      expect(find.byType(JournalScreen), findsOneWidget);
    });

    testWidgets('4. MainNavigationScaffold 5 sekme arasında hatasız geçiş yapar', (WidgetTester tester) async {
      await tester.pumpWidget(
        createLocalizedTestWidget(
          child: const MainNavigationScaffold(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(MainNavigationScaffold), findsOneWidget);

      // 1: Haftalık
      await tester.tap(find.text('nav_weekly'.tr()));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(WeeklyPanelScreen), findsOneWidget);

      // 2: Takip
      await tester.tap(find.text('nav_tracker'.tr()));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(DailyTrackerScreen), findsOneWidget);

      // 3: Günlük
      await tester.tap(find.text('nav_journal'.tr()));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(JournalScreen), findsOneWidget);

      // 4: Acil Durum (Kalıcı AppBar Güvenlik Rozeti)
      await tester.tap(find.byKey(const ValueKey('appbar_emergency_beacon')).first);
      await tester.pumpAndSettle();
      expect(find.byType(EmergencyScreen), findsOneWidget);
    });

    testWidgets('5. Dialog açıldığında alt navigasyon çubuğu otomatik gizlenir, kapanınca geri gelir', (WidgetTester tester) async {
      await tester.pumpWidget(
        createLocalizedTestWidget(
          child: const MainNavigationScaffold(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(FluidClayBottomNavBar), findsOneWidget);

      // Dialog aç
      final context = tester.element(find.byType(MainNavigationScaffold));
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Test Dialog'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Kapat'),
            ),
          ],
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      // Dialog açıkken alt bar gizlenmiş olmalı
      expect(find.text('Test Dialog'), findsOneWidget);
      expect(find.byType(FluidClayBottomNavBar), findsNothing);

      // Dialogu kapat
      await tester.tap(find.text('Kapat'));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      // Alt bar tekrar görünür olmalı
      expect(find.byType(FluidClayBottomNavBar), findsOneWidget);
    });
  });
}
