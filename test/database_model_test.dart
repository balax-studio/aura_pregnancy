import 'package:flutter_test/flutter_test.dart';
import 'package:aura_pregnancy/models/profile_model.dart';
import 'package:aura_pregnancy/models/diary_model.dart';
import 'package:aura_pregnancy/models/daily_log_model.dart';
import 'package:aura_pregnancy/models/notification_model.dart';

void main() {
  group('SQLite Veri Modelleri & Map Serialization Testi', () {
    test('ProfileModel toMap ve fromMap dönüşümü', () {
      final lmp = DateTime.now().subtract(const Duration(days: 23 * 7));
      final due = lmp.add(const Duration(days: 280));
      final lmpStr = lmp.toIso8601String().substring(0, 10);
      final dueStr = due.toIso8601String().substring(0, 10);

      final profile = ProfileModel(
        id: 1,
        dueDate: dueStr,
        lmpDate: lmpStr,
        prePregnancyWeight: 58.5,
        height: 168.0,
        vki: 20.7,
        currentWeek: 24,
      );

      final map = profile.toMap();
      expect(map['due_date'], equals(dueStr));
      expect(map['pre_pregnancy_weight'], equals(58.5));
      expect(map['vki'], equals(20.7));
      expect(map['current_week'], equals(24));

      final fromDb = ProfileModel.fromMap(map);
      expect(fromDb.dueDate, equals(profile.dueDate));
      expect(fromDb.vkiCategoryKey, equals('Normal'));
      expect(fromDb.trimester, equals(2));
    });

    test('DiaryModel toMap ve fromMap dönüşümü', () {
      final diary = DiaryModel(
        id: 10,
        pregnancyWeek: 18,
        date: '2026-08-27',
        noteText: 'Bebeğimin ilk tekmesini hissettim!',
        photoPath: 'uploads/ultrasound_18w.jpg',
        audioPath: 'audio/heartbeat_18w.m4a',
        moodRating: 5,
        isRomanticHighlight: true,
      );

      final map = diary.toMap();
      expect(map['pregnancy_week'], equals(18));
      expect(map['is_romantic_highlight'], equals(1));

      final fromDb = DiaryModel.fromMap(map);
      expect(fromDb.isRomanticHighlight, isTrue);
      expect(fromDb.noteText, equals('Bebeğimin ilk tekmesini hissettim!'));
    });

    test('DailyLogModel toMap ve fromMap dönüşümü', () {
      final log = DailyLogModel(
        id: 5,
        date: '2026-08-27',
        waterIntakeMl: 2000,
        caffeineMg: 90,
        weightEntry: 61.2,
        symptomNotes: 'Hafif bel ağrısı, enerji yüksek.',
      );

      final map = log.toMap();
      expect(map['water_intake_ml'], equals(2000));
      expect(map['caffeine_mg'], equals(90));
      expect(map['weight_entry'], equals(61.2));

      final fromDb = DailyLogModel.fromMap(map);
      expect(fromDb.waterProgressRatio, equals(0.8));
      expect(fromDb.isCaffeineOverLimit, isFalse);
    });

    test('NotificationModel toMap ve fromMap dönüşümü', () {
      final notif = NotificationModel(
        id: 1,
        week: 20,
        triggerTime: '2026-08-27T09:00:00',
        title: 'Ayrıntılı Ultrason Zamanı',
        body: 'Bu hafta ikinci trimester morfoloji taramanızı yaptırınız.',
        isRead: false,
        type: 'medical',
      );

      final map = notif.toMap();
      expect(map['week'], equals(20));
      expect(map['is_read'], equals(0));

      final fromDb = NotificationModel.fromMap(map);
      expect(fromDb.isRead, isFalse);
      expect(fromDb.type, equals('medical'));
    });
  });
}
