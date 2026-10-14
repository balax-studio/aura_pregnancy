import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:aura_pregnancy/models/profile_model.dart';
import 'package:aura_pregnancy/services/database_helper.dart';
import 'package:aura_pregnancy/views/more/more_tools_screen.dart';
import 'package:aura_pregnancy/views/journal/widgets/watercolor_portrait_dialog.dart';
import 'package:aura_pregnancy/views/journal/widgets/keepsake_card_dialog.dart';
import 'test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    final now = DateTime.now();
    final lmp = now.subtract(const Duration(days: 25 * 7));
    final due = now.add(const Duration(days: 15 * 7));

    await DatabaseHelper.instance.ensureDefaultProfile();
    await DatabaseHelper.instance.saveProfile(
      ProfileModel(
        id: 1,
        dueDate: '${due.year.toString().padLeft(4, '0')}-${due.month.toString().padLeft(2, '0')}-${due.day.toString().padLeft(2, '0')}',
        lmpDate: '${lmp.year.toString().padLeft(4, '0')}-${lmp.month.toString().padLeft(2, '0')}-${lmp.day.toString().padLeft(2, '0')}',
        prePregnancyWeight: 58.0,
        height: 165.0,
        vki: 21.3,
        currentWeek: 26,
        momName: 'Ayşe',
        babyName: 'Güneş',
        babyGender: 'girl',
      ),
    );
  });

  group('Aura Ultrason Portre ve Hatıra Stüdyosu Testleri', () {
    testWidgets('1. WatercolorPortraitDialog açılır ve kilitli reklam butonunu gösterir', (WidgetTester tester) async {
      await tester.pumpWidget(
        createLocalizedTestWidget(
          child: const WatercolorPortraitDialog(
            initialUltrasoundPath: 'assets/images/sample_ultrasound.png',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('portrait_watercolor_title'.tr()), findsWidgets);
      expect(find.text('portrait_watercolor_badge'.tr()), findsWidgets);
      expect(find.text('portrait_watercolor_btn'.tr()), findsWidgets);
      expect(find.text('studio_change_photo'.tr()), findsOneWidget);
    });

    testWidgets('2. KeepsakeCardDialog profil verilerini ve hatıra kartı şablonunu doğru yükler', (WidgetTester tester) async {
      await tester.pumpWidget(
        createLocalizedTestWidget(
          child: const KeepsakeCardDialog(
            initialUltrasoundPath: 'assets/images/sample_ultrasound.png',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('keepsake_card_title'.tr()), findsWidgets);
      expect(find.text('Güneş'), findsOneWidget);
      expect(find.textContaining('Gebelik Haftası • Tahmini Doğum:'), findsOneWidget);
      expect(find.text('keepsake_card_btn'.tr()), findsWidgets);
    });

    testWidgets('3. MoreToolsScreen üzerinde Mucize Portre Stüdyosu kartları görüntülenir', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 2200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        createLocalizedTestWidget(
          child: const MoreToolsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('more_tool_portrait_title'.tr()), findsOneWidget);
      expect(find.text('more_tool_keepsake_title'.tr()), findsOneWidget);

      // 1. Karta dokunulduğunda WatercolorPortraitDialog açılır
      await tester.ensureVisible(find.text('more_tool_portrait_title'.tr()));
      await tester.tap(find.text('more_tool_portrait_title'.tr()));
      await tester.pumpAndSettle();
      expect(find.byType(WatercolorPortraitDialog), findsOneWidget);

      // Kapat
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // 2. Karta dokunulduğunda KeepsakeCardDialog açılır
      await tester.ensureVisible(find.text('more_tool_keepsake_title'.tr()));
      await tester.tap(find.text('more_tool_keepsake_title'.tr()));
      await tester.pumpAndSettle();
      expect(find.byType(KeepsakeCardDialog), findsOneWidget);
    });

    testWidgets('4. Geçersiz/silinmiş görsel yolunda hata vermeden güvenli fallback çalışır', (WidgetTester tester) async {
      await tester.pumpWidget(
        createLocalizedTestWidget(
          child: const WatercolorPortraitDialog(
            initialUltrasoundPath: '/non_existent_path/broken_photo.jpg',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WatercolorPortraitDialog), findsOneWidget);
      expect(find.text('portrait_watercolor_title'.tr()), findsWidgets);
    });
  });
}
