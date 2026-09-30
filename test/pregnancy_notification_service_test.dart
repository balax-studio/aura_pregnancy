import 'package:flutter_test/flutter_test.dart';
import 'package:aura_pregnancy/services/pregnancy_notification_service.dart';

void main() {
  group('PregnancyNotificationService & Quiet Hours Testleri', () {
    test('1. Gündüz saatlerinde (ör. 14:00) 1 saat sonrası güvenli kabul edilir', () {
      final afternoonTime = DateTime(2026, 10, 1, 14, 0);
      final safeTime =
          PregnancyNotificationService.calculateSafeNotificationTime(afternoonTime);

      expect(safeTime.day, 1);
      expect(safeTime.hour, 15);
      expect(safeTime.minute, 0);
    });

    test('2. Gece 23:30 çıkışında anneyi uyandırmamak için ertesi sabah 09:30 saatine ötelenir', () {
      final nightTime = DateTime(2026, 10, 1, 23, 30);
      final safeTime =
          PregnancyNotificationService.calculateSafeNotificationTime(nightTime);

      expect(safeTime.day, 2); // Ertesi gün
      expect(safeTime.hour, 9);
      expect(safeTime.minute, 30);
    });

    test('3. Gece 01:00 çıkışında sabah 09:30 saatine ötelenir', () {
      final lateNightTime = DateTime(2026, 10, 1, 1, 0);
      final safeTime =
          PregnancyNotificationService.calculateSafeNotificationTime(lateNightTime);

      expect(safeTime.day, 1);
      expect(safeTime.hour, 9);
      expect(safeTime.minute, 30);
    });

    test('4. Akşam 21:15 çıkışında 22:15 sessiz saate girdiği için ertesi sabaha ötelenir', () {
      final eveningBorderTime = DateTime(2026, 10, 1, 21, 15);
      final safeTime =
          PregnancyNotificationService.calculateSafeNotificationTime(eveningBorderTime);

      expect(safeTime.day, 2);
      expect(safeTime.hour, 9);
      expect(safeTime.minute, 30);
    });

    test('5. shouldRescheduleDaily aynı gün ve dilde tekrar planlamayı engeller', () {
      final service = PregnancyNotificationService.instance;
      // Başlangıçta henüz planlanmamışsa true döner
      expect(service.shouldRescheduleDaily(languageCode: 'tr'), isTrue);
    });
  });
}
