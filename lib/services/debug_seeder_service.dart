import 'dart:math';
import '../models/daily_log_model.dart';
import '../models/diary_model.dart';
import '../models/profile_model.dart';
import '../services/database_helper.dart';

/// Aura Pregnancy - Geliştirici & Test Veri Doldurucu (Debug Seeder) Servisi
class DebugSeederService {
  DebugSeederService._internal();
  static final DebugSeederService instance = DebugSeederService._internal();

  /// 40 Haftalık Eksiksiz Hamilelik Verisi Doldurur
  Future<Map<String, int>> seedFullPregnancyData() async {
    final random = Random(42); // Tutarlı simülasyon için sabit seed

    int insertedLogs = 0;
    int insertedDiaries = 0;

    // Profil Güncelle (40. Hafta veya 28. Hafta test profili)
    final lmp = DateTime.now().subtract(const Duration(days: 196)).toIso8601String().split('T').first;
    final due = DateTime.now().add(const Duration(days: 84)).toIso8601String().split('T').first;

    final existingProfile = await DatabaseHelper.instance.getProfile();
    final mom = existingProfile?.momName ?? 'Elif';
    final baby = existingProfile?.babyName ?? 'Ayşe';
    final gender = existingProfile?.babyGender ?? 'girl';

    final profile = ProfileModel(
      dueDate: due,
      lmpDate: lmp,
      prePregnancyWeight: 58.0,
      height: 168.0,
      vki: 20.5,
      currentWeek: 28,
      momName: mom,
      babyName: baby,
      babyGender: gender,
    );
    await DatabaseHelper.instance.saveProfile(profile);

    // 40 Haftalık Günlük Sağlık Kayıtları (Her haftadan 3-5 kayıt)
    final baseDate = DateTime.parse(lmp);
    double currentWeight = 58.0;

    for (int week = 1; week <= 40; week++) {
      // Kilo artışı IOM standartlarına göre yavaşça artar
      if (week <= 12) {
        currentWeight += 0.12;
      } else if (week <= 27) {
        currentWeight += 0.38;
      } else {
        currentWeight += 0.45;
      }

      // Bu hafta için 4 gün log ekle
      for (int dayOffset = 0; dayOffset < 4; dayOffset++) {
        final logDate = baseDate.add(Duration(days: (week - 1) * 7 + dayOffset * 2));
        final dateStr = logDate.toIso8601String().split('T').first;

        final steps = 3500 + random.nextInt(5000);
        final walkingMins = (steps / 100).round();
        final water = 1750 + (random.nextInt(6) * 250);
        final caffeine = (random.nextInt(3)) * 40;

        await DatabaseHelper.instance.updateDailyLog(
          DailyLogModel(
            date: dateStr,
            waterIntakeMl: water,
            caffeineMg: caffeine,
            stepCount: steps,
            walkingMinutes: walkingMins,
            weightEntry: (currentWeight * 10).round() / 10.0,
            symptomNotes: week % 4 == 0 ? '$week. hafta rutin kontrolü tamamlandı, her şey harika!' : null,
          ),
        );
        insertedLogs++;
      }

      // Dönüm noktası haftalarında fotoğraf ve sesli mektuplu anı ekle
      if (week % 4 == 0 || week == 1 || week == 40) {
        final diaryDate = baseDate.add(Duration(days: (week - 1) * 7 + 2)).toIso8601String().split('T').first;
        final isEvenMilestone = (week / 4).round() % 2 == 0;

        final note = _getMilestoneNote(week);

        await DatabaseHelper.instance.insertDiary(
          DiaryModel(
            pregnancyWeek: week,
            date: diaryDate,
            noteText: note,
            photoPath: isEvenMilestone ? 'assets/images/sample_ultrasound.png' : 'assets/images/aura_logo.png',
            audioPath: 'assets/audio/voice_letter.m4a',
            moodRating: 5,
            isRomanticHighlight: week % 8 == 0,
          ),
        );
        insertedDiaries++;
      }
    }

    return {
      'logs': insertedLogs,
      'diaries': insertedDiaries,
    };
  }

  String _getMilestoneNote(int week) {
    switch (week) {
      case 1:
      case 4:
        return 'Hamilelik testimiz pozitif çıktı! Kalbimiz sevinçten uçuyor minik bebeğim.';
      case 8:
        return 'Bugün ilk kez minik kalbinin pıt pıt atışlarını duyduk. Dünyanın en güzel melodisiydi.';
      case 12:
        return '1. Trimester bitti! İkili testimiz çok temiz çıktı, ultrasonda el salladın.';
      case 16:
        return 'Kıvrık minik fetüs oldun! İlk hafif kıpırtılarını hissettim sanki bir kelebek kanat çırptı.';
      case 20:
        return 'Ayrıntılı ultrasonda tüm organlarını detaylıca gördük. Yüzün tıpkı babana benziyor.';
      case 24:
        return 'Şeker yükleme testimiz yapıldı, her şey yolunda. Baban karnına şarkılar söylüyor.';
      case 28:
        return '3. Trimester başladı! Beşik ve odan hazırlanıyor, sana kavuşmak için gün sayıyoruz.';
      case 32:
        return 'NST ve büyüme takibimiz harika geçti. Tekmelerin artık dışarıdan bile net görünüyor!';
      case 36:
        return 'Doğum çantamız hazırlandı. Seni kucağımıza alacağımız o büyük güne çok az kaldı.';
      case 40:
        return 'Zaman doldu melek bebeğim! Dünyaya gözlerini açman ve kollarımıza gelmen için seni bekliyoruz.';
      default:
        return '$week. hafta anımız: Birlikte büyüyor, her anın tadını çıkarıyoruz.';
    }
  }

  /// Tüm Veritabanını Sıfırlar
  Future<void> resetAllDatabase() async {
    await DatabaseHelper.instance.clearAllData();
    await DatabaseHelper.instance.ensureDefaultProfile();
  }

  /// Aktif Haftayı Hızlı Değiştirir
  Future<void> jumpToWeek(int targetWeek) async {
    final now = DateTime.now();
    final elapsedDays = (targetWeek - 1) * 7;
    final lmp = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: elapsedDays))
        .toIso8601String()
        .split('T')
        .first;
    final due = DateTime.parse(lmp)
        .add(const Duration(days: 280))
        .toIso8601String()
        .split('T')
        .first;
    final profile = await DatabaseHelper.instance.getProfile();
    if (profile != null) {
      await DatabaseHelper.instance.saveProfile(profile.copyWith(
        currentWeek: targetWeek,
        lmpDate: lmp,
        dueDate: due,
      ));
    } else {
      await DatabaseHelper.instance.updateCurrentWeek(targetWeek);
    }
  }

  /// Veritabanı Canlı İstatistiklerini Getirir
  Future<Map<String, dynamic>> getDatabaseStats() async {
    final logs = await DatabaseHelper.instance.getAllDailyLogs();
    final diaries = await DatabaseHelper.instance.getAllDiaries();
    final profile = await DatabaseHelper.instance.getProfile();

    final totalPhotos = diaries.where((d) => d.photoPath != null && d.photoPath!.isNotEmpty).length;
    final totalAudios = diaries.where((d) => d.audioPath != null && d.audioPath!.isNotEmpty).length;
    final totalSteps = logs.fold(0, (sum, l) => sum + l.stepCount);
    final totalWater = logs.fold(0, (sum, l) => sum + l.waterIntakeMl);

    return {
      'currentWeek': profile?.currentWeek ?? 12,
      'totalLogs': logs.length,
      'totalDiaries': diaries.length,
      'totalPhotos': totalPhotos,
      'totalAudios': totalAudios,
      'totalSteps': totalSteps,
      'totalWaterMl': totalWater,
    };
  }
}
