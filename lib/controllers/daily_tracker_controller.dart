import 'package:flutter/material.dart';
import '../../models/daily_log_model.dart';
import '../../models/profile_model.dart';
import '../../services/database_helper.dart';
import '../../services/medical_calculator.dart';
import '../../utils/date_utils.dart';

/// Günlük Takip ve Beslenme Ekranı Controller'ı
class DailyTrackerController extends ChangeNotifier {
  DailyLogModel _currentLog = DailyLogModel(date: AppDateUtils.todayIso());
  ProfileModel? _profile;
  bool _isLoading = false;

  DailyLogModel get currentLog => _currentLog;
  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;

  int get currentWeek => _profile?.currentPregnancyWeek ?? 12;
  int get trimester =>
      _profile?.pregnancyProgress.trimester ??
      MedicalCalculator.getTrimester(currentWeek);

  /// Başlangıç verilerini veritabanından yükle
  Future<void> loadTodayData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _profile = await DatabaseHelper.instance.getProfile();
      final today = AppDateUtils.todayIso();
      _currentLog = await DatabaseHelper.instance.getOrCreateDailyLog(today);
    } catch (e) {
      debugPrint('DailyTracker load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Su Ekle (+ml)
  Future<void> addWater(int amountMl) async {
    final updated = _currentLog.copyWith(
      waterIntakeMl: _currentLog.waterIntakeMl + amountMl,
    );
    _currentLog = updated;
    notifyListeners();
    await DatabaseHelper.instance.updateDailyLog(updated);
  }

  /// Su Miktarını Sıfırla
  Future<void> resetWater() async {
    final updated = _currentLog.copyWith(waterIntakeMl: 0);
    _currentLog = updated;
    notifyListeners();
    await DatabaseHelper.instance.updateDailyLog(updated);
  }

  /// Kafein Ekle (+mg)
  Future<void> addCaffeine(int amountMg) async {
    final updated = _currentLog.copyWith(
      caffeineMg: _currentLog.caffeineMg + amountMg,
    );
    _currentLog = updated;
    notifyListeners();
    await DatabaseHelper.instance.updateDailyLog(updated);
  }

  /// Kafein Sıfırla
  Future<void> resetCaffeine() async {
    final updated = _currentLog.copyWith(caffeineMg: 0);
    _currentLog = updated;
    notifyListeners();
    await DatabaseHelper.instance.updateDailyLog(updated);
  }

  /// Adım Ekle (+adım, +dakika)
  Future<void> addSteps(int steps, {int minutes = 0}) async {
    final updated = _currentLog.copyWith(
      stepCount: _currentLog.stepCount + steps,
      walkingMinutes: _currentLog.walkingMinutes + minutes,
    );
    _currentLog = updated;
    notifyListeners();
    await DatabaseHelper.instance.updateDailyLog(updated);
  }

  /// Adım ve Yürüyüş Verisini Sıfırla
  Future<void> resetSteps() async {
    final updated = _currentLog.copyWith(stepCount: 0, walkingMinutes: 0);
    _currentLog = updated;
    notifyListeners();
    await DatabaseHelper.instance.updateDailyLog(updated);
  }

  /// Günlük Kilo Girişi Kaydet
  Future<void> setWeightEntry(double weight) async {
    final updated = _currentLog.copyWith(weightEntry: weight);
    _currentLog = updated;
    notifyListeners();
    await DatabaseHelper.instance.updateDailyLog(updated);
  }

  /// Günlük Semptom Notu Kaydet
  Future<void> setSymptomNotes(String notes) async {
    final updated = _currentLog.copyWith(symptomNotes: notes);
    _currentLog = updated;
    notifyListeners();
    await DatabaseHelper.instance.updateDailyLog(updated);
  }
}
