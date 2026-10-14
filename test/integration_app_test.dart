import 'package:flutter_test/flutter_test.dart';
import 'package:aura_pregnancy/core/constants/medical_specs.dart';
import 'package:aura_pregnancy/core/constants/weekly_medical_data.dart';
import 'package:aura_pregnancy/services/medical_calculator.dart';
import 'package:aura_pregnancy/services/ffmpeg_video_service.dart';
import 'package:aura_pregnancy/models/profile_model.dart';
import 'package:aura_pregnancy/models/diary_model.dart';
import 'package:aura_pregnancy/models/daily_log_model.dart';
import 'package:aura_pregnancy/models/emergency_card_model.dart';

void main() {
  group('Aura Pregnancy Bütüncül Entegrasyon Testleri (MVP)', () {
    test('1. Onboarding ve VKİ hesaplama senaryosu', () {
      final now = DateTime.now();
      final lmp = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 11 * 7));
      final dueDate = MedicalCalculator.calculateDueDateFromLmp(lmp);
      final week = MedicalCalculator.calculateCurrentWeekFromLmp(lmp, now); // 12. Hafta civarı

      final vki = MedicalCalculator.calculateVki(weightKg: 55.0, heightCm: 162.0); // ~20.95 -> 21.0
      expect(vki, equals(21.0));

      final guideline = MedicalCalculator.getWeightGainGuideline(vki);
      expect(guideline['range'], equals('11.5 - 16.0 kg'));
      expect(guideline['weekly'], equals(0.42));

      final profile = ProfileModel(
        dueDate: dueDate.toIso8601String().split('T')[0],
        lmpDate: lmp.toIso8601String().split('T')[0],
        prePregnancyWeight: 55.0,
        height: 162.0,
        vki: vki,
        currentWeek: week,
      );

      expect(profile.trimester, equals(1));
    });

    test('2. Günlük Takip su ve 200mg kafein alarm senaryosu', () {
      var log = DailyLogModel(date: '2026-08-27', waterIntakeMl: 1500, caffeineMg: 155);
      expect(log.isCaffeineOverLimit, isFalse);
      expect(log.remainingSafeCaffeineMg, equals(45));

      // 60 mg Türk Kahvesi eklendi -> Toplam 215 mg
      log = log.copyWith(caffeineMg: log.caffeineMg + 60);
      expect(log.isCaffeineOverLimit, isTrue);
      expect(log.remainingSafeCaffeineMg, equals(0));
    });

    test('3. Hafta hafta tıbbi tarama testleri ve 1-40 hafta verisi', () {
      final week10 = WeeklyMedicalData.getInfoForWeek(10);
      expect(week10['milestone_test']['code'], equals('NIPT'));

      final week12 = WeeklyMedicalData.getInfoForWeek(12);
      expect(week12['milestone_test']['code'], equals('DOUBLE_TEST'));

      final week20 = WeeklyMedicalData.getInfoForWeek(20);
      expect(week20['milestone_test']['code'], equals('DETAILED_USG'));

      final week24 = WeeklyMedicalData.getInfoForWeek(24);
      expect(week24['milestone_test']['code'], equals('OGTT_DIABETES'));

      final week28 = WeeklyMedicalData.getInfoForWeek(28);
      expect(week28['milestone_test']['code'], equals('ANTI_D_NST'));
    });

    test('4. Acil durum kırmızı alarm ve acil tıbbi kart verisi', () {
      final card = EmergencyCardModel(
        lmpDate: '2026-01-15',
        dueDate: '2026-10-22',
        currentWeek: 24,
      );

      expect(card.bloodType, equals('A Rh (+)'));
      expect(PregnancyMedicalSpecs.redFlagEmergencySigns.length, equals(8));
      expect(PregnancyMedicalSpecs.emergencyFeverCelsius, equals(38.0));
    });

    test('5. Aura Journal ve FFmpeg video ön-işlemci matrisi', () {
      final highlights = [
        DiaryModel(
          pregnancyWeek: 8,
          date: '2026-03-12',
          noteText: 'İlk kalp atışı',
          isRomanticHighlight: true,
        ),
        DiaryModel(
          pregnancyWeek: 12,
          date: '2026-04-09',
          noteText: 'İlk el sallama',
          isRomanticHighlight: true,
        ),
      ];

      final matrix = FFmpegVideoService.generateVideoAssetMatrix(
        highlightEntries: highlights,
      );

      expect(matrix['slides'].length, equals(2));
      expect(matrix['music_track'], equals('Aura_Lullaby.mp3'));
      expect(matrix['total_duration_sec'], equals(8));
    });
  });
}
