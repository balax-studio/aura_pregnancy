import 'package:flutter_test/flutter_test.dart';
import 'package:aura_pregnancy/models/profile_model.dart';
import 'package:aura_pregnancy/services/medical_calculator.dart';
import 'package:aura_pregnancy/services/pregnancy_progress.dart';
import 'package:aura_pregnancy/services/fruit_asset_sync.dart';
import 'package:aura_pregnancy/utils/date_utils.dart';

void main() {
  group('PregnancyProgress', () {
    test('uses completed weeks and zero-based days at the early boundaries',
        () {
      final expected = <int, List<int>>{
        0: [0, 0, 1],
        6: [0, 6, 1],
        7: [1, 0, 2],
        13: [1, 6, 2],
        14: [2, 0, 3],
      };

      for (final entry in expected.entries) {
        final progress = PregnancyProgress.fromTotalDays(entry.key);
        expect(progress.week, entry.value[0], reason: 'totalDays=${entry.key}');
        expect(progress.day, entry.value[1], reason: 'totalDays=${entry.key}');
        expect(progress.displayWeek, entry.value[2],
            reason: 'totalDays=${entry.key}');
      }
    });

    test('covers 4+6, 5+0, 5+6, 6+0, 6+6, and 7+0 boundaries', () {
      final fourPlusSix = PregnancyProgress.fromTotalDays(4 * 7 + 6);
      final fivePlusZero = PregnancyProgress.fromTotalDays(5 * 7);
      final fivePlusSix = PregnancyProgress.fromTotalDays(5 * 7 + 6);
      final sixPlusZero = PregnancyProgress.fromTotalDays(6 * 7);
      final sixPlusSix = PregnancyProgress.fromTotalDays(6 * 7 + 6);
      final sevenPlusZero = PregnancyProgress.fromTotalDays(7 * 7);

      expect([fourPlusSix.week, fourPlusSix.day], [4, 6]);
      expect([fivePlusZero.week, fivePlusZero.day], [5, 0]);
      expect([fivePlusSix.week, fivePlusSix.day], [5, 6]);
      expect([sixPlusZero.week, sixPlusZero.day], [6, 0]);
      expect([sixPlusSix.week, sixPlusSix.day], [6, 6]);
      expect([sevenPlusZero.week, sevenPlusZero.day], [7, 0]);
      expect(fivePlusSix.displayWeek, 6);
      expect(sixPlusZero.displayWeek, 7);
    });

    test('calendar time does not affect elapsed pregnancy days', () {
      final sameDate = PregnancyProgress.fromLmpDate(
        DateTime(2025, 3, 8, 23, 55),
        currentDate: DateTime(2025, 3, 8, 0, 5),
      );
      final nextCalendarDay = PregnancyProgress.fromLmpDate(
        DateTime(2025, 3, 8, 23, 55),
        currentDate: DateTime(2025, 3, 9, 0, 5),
      );
      final utcDayBoundary = PregnancyProgress.fromLmpDate(
        DateTime.utc(2025, 3, 30, 23, 55),
        currentDate: DateTime.utc(2025, 3, 31, 0, 5),
      );

      expect(sameDate.totalDays, 0);
      expect(nextCalendarDay.totalDays, 1);
      expect(utcDayBoundary.totalDays, 1);
    });

    test('prefers LMP and falls back to due date without time arithmetic', () {
      final asOf = DateTime(2025, 1, 8, 22, 30);
      final fromLmp = PregnancyProgress.fromDateStrings(
        lmpDate: '2025-01-01',
        dueDate: '2025-10-08',
        currentDate: asOf,
      );
      final fromDueDate = PregnancyProgress.fromDateStrings(
        dueDate: '2025-10-08T23:59:00',
        currentDate: asOf,
      );

      expect(fromLmp.totalDays, 7);
      expect(fromDueDate.totalDays, 7);
      expect(fromLmp.displayWeek, 2);
      expect(fromDueDate.displayWeek, 2);
    });

    test('MedicalCalculator delegates to the same week/day calculation', () {
      final lmp = DateTime(2025, 1, 1, 23, 59);
      final currentDate = DateTime(2025, 1, 14, 0, 1);

      expect(
          MedicalCalculator.calculateCurrentWeekFromLmp(lmp, currentDate), 2);
      expect(
        MedicalCalculator.getDetailedPregnancyAge(lmp, currentDate),
        {'weeks': 1, 'days': 6, 'totalDays': 13},
      );
    });

    test('home and weekly content share the same weekly fruit key', () {
      final beforeBoundary = PregnancyProgress.fromTotalDays(5 * 7 + 6);
      final afterBoundary = PregnancyProgress.fromTotalDays(6 * 7);

      expect(beforeBoundary.contentWeek, 6);
      expect(
        Fruit3DAssetManager.getFruitKeyForWeek(beforeBoundary.contentWeek),
        'pea',
      );
      expect(afterBoundary.contentWeek, 7);
      expect(
        Fruit3DAssetManager.getFruitKeyForWeek(afterBoundary.contentWeek),
        'blueberry',
      );
    });

    test('only current and past weeks unlock unless rewarded explicitly', () {
      final currentWeek = PregnancyProgress.fromTotalDays(5 * 7 + 6);
      final nextWeek = PregnancyProgress.fromTotalDays(6 * 7);

      expect(currentWeek.isWeekUnlocked(5), isTrue);
      expect(currentWeek.isWeekUnlocked(6), isTrue);
      expect(currentWeek.isWeekUnlocked(7), isFalse);
      expect(currentWeek.isWeekUnlocked(7, rewardUnlockedWeeks: {7}), isTrue);
      expect(nextWeek.isWeekUnlocked(7), isTrue);
      expect(nextWeek.isWeekUnlocked(8), isFalse);
    });

    test('late pregnancy preserves age while using the available week 40 data',
        () {
      final latePregnancy = PregnancyProgress.fromTotalDays(42 * 7 + 6);

      expect([latePregnancy.week, latePregnancy.day], [42, 6]);
      expect(latePregnancy.displayWeek, 42);
      expect(latePregnancy.contentWeek, 40);
      expect(latePregnancy.daysUntilDueDate, 0);
      expect(latePregnancy.isWeekUnlocked(40), isTrue);
    });

    test(
        'ProfileModel keeps its stored week and derives runtime age from dates',
        () {
      final today = DateTime.now();
      final lmpDate = AppDateUtils.toIso(today);
      final dueDate = AppDateUtils.toIso(
        MedicalCalculator.calculateDueDateFromLmp(today),
      );
      final profile = ProfileModel(
        dueDate: dueDate,
        lmpDate: lmpDate,
        prePregnancyWeight: 60,
        height: 165,
        vki: 22,
        currentWeek: 12,
      );

      final progress = profile.pregnancyProgress;
      expect(profile.currentWeek, 12);
      expect(profile.toMap()['current_week'], 12);
      expect(progress.totalDays, 0);
      expect(profile.currentPregnancyWeek, 1);
    });
  });
}
