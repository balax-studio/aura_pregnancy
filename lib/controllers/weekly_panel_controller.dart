import 'package:flutter/material.dart';
import '../../core/constants/weekly_medical_data.dart';
import '../../models/profile_model.dart';
import '../../services/database_helper.dart';
import '../../services/medical_calculator.dart';
import '../../services/pregnancy_progress.dart';

/// Hafta Hafta Tıbbi Panel Controller'ı (Gelecek Hafta Kilit & Reklam Desteği)
class WeeklyPanelController extends ChangeNotifier {
  int _selectedWeek = 12;
  final Set<int> _unlockedWeeks = {};
  ProfileModel? _profile;
  PregnancyProgress _pregnancyProgress = PregnancyProgress.fromTotalDays(77);
  bool _isLoading = false;

  int get selectedWeek => _selectedWeek;
  int get actualPregnancyWeek => _pregnancyProgress.displayWeek;
  PregnancyProgress get pregnancyProgress => _pregnancyProgress;
  Set<int> get unlockedWeeks => _unlockedWeeks;
  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;

  int get selectedTrimester => MedicalCalculator.getTrimester(_selectedWeek);

  Map<String, dynamic> get currentWeekData {
    return WeeklyMedicalData.getInfoForWeek(_selectedWeek);
  }

  bool isWeekUnlocked(int week) {
    return _pregnancyProgress.isWeekUnlocked(
      week,
      rewardUnlockedWeeks: _unlockedWeeks,
    );
  }

  /// Profil ve güncel haftayı yükle
  Future<void> loadProfileWeek() async {
    _isLoading = true;
    notifyListeners();

    try {
      _profile = await DatabaseHelper.instance.getProfile();
      if (_profile != null) {
        _pregnancyProgress = _profile!.pregnancyProgress;
        _selectedWeek = _pregnancyProgress.contentWeek;
      }
    } catch (e) {
      debugPrint('WeeklyPanelController load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Seçili haftayı değiştir
  void selectWeek(int week) {
    if (week >= 1 && week <= 40 && isWeekUnlocked(week)) {
      _selectedWeek = week;
      notifyListeners();
    }
  }

  /// Reklam izlendikten sonra gelecek haftanın kilidini aç ve seç
  void unlockWeek(int week) {
    if (week >= 1 && week <= 40) {
      _unlockedWeeks.add(week);
      _selectedWeek = week;
      notifyListeners();
    }
  }
}
