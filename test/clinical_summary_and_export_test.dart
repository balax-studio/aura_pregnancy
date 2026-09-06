import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:aura_pregnancy/models/profile_model.dart';
import 'package:aura_pregnancy/models/emergency_card_model.dart';
import 'package:aura_pregnancy/services/database_helper.dart';
import 'package:aura_pregnancy/services/ffmpeg_video_service.dart';
import 'package:aura_pregnancy/services/video_story_generator_service.dart';
import 'package:aura_pregnancy/views/timeline/widgets/clinical_summary_dialog.dart';
import 'test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await DatabaseHelper.instance.ensureDefaultProfile();
    await DatabaseHelper.instance.saveProfile(
      ProfileModel(
        id: 1,
        dueDate: '2026-10-08',
        lmpDate: '2026-01-01',
        prePregnancyWeight: 60.0,
        height: 168.0,
        vki: 21.3,
        currentWeek: 24,
        momName: 'Test Anne Adayı',
        babyName: 'Umut',
        babyGender: 'girl',
      ),
    );
    await DatabaseHelper.instance.saveEmergencyCard(
      EmergencyCardModel(
        patientName: 'Test Anne Adayı',
        bloodType: 'A Rh (+)',
        lmpDate: '2026-01-01',
        dueDate: '2026-10-08',
        currentWeek: 24,
        doctorName: 'Dr. Zeynep Kaya',
        doctorPhone: '05551112233',
        hospitalName: 'Şehir Kadın Doğum Hastanesi',
        allergies: 'Penisilin',
        chronicDiseases: 'Hafif Astım',
      ),
    );
  });

  group('Klinik Hekim Özeti ve Video Export Testleri', () {
    testWidgets('1. ClinicalSummaryDialog tüm hekim klinik verilerini eksiksiz gösterir', (WidgetTester tester) async {
      await tester.pumpWidget(
        createLocalizedTestWidget(
          child: const ClinicalSummaryDialog(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('doctor_report_title'.tr()), findsOneWidget);
      expect(find.text('Test Anne Adayı'), findsOneWidget);
      expect(find.text('doctor_report_copy_btn'.tr()), findsOneWidget);
      expect(find.text('Dr. Zeynep Kaya (05551112233)'), findsOneWidget);
      expect(find.text('Şehir Kadın Doğum Hastanesi'), findsOneWidget);
      expect(find.text('A Rh (+)'), findsOneWidget);
    });

    test('2. FFmpegVideoService.exportAndSaveVideo bozuk MP4 yerine temiz dosya üretir', () async {
      final frames = [
        const VideoStoryFrame(
          week: 12,
          date: '2026-03-20',
          title: '12. Hafta',
          subtitle: 'İkili tarama yapıldı',
          photoPath: 'assets/images/sample_ultrasound.png',
          quote: 'Sağlıkla büyü...',
        ),
      ];

      final path = await FFmpegVideoService.exportAndSaveVideo(
        frames: frames,
        fileName: 'Test_Yolculuk',
      );

      expect(path, isNotNull);
      expect(path!.endsWith('.jpg'), isTrue);
    });
  });
}
