import 'package:flutter/material.dart';
import '../../models/profile_model.dart';
import '../../services/medical_calculator.dart';
import '../../services/pregnancy_progress.dart';
import '../../services/database_helper.dart';
import '../../utils/date_utils.dart';

enum DateInputMode { lmp, dueDate }

/// Onboarding ve Profil Oluşturma Durum Yöneticisi (Anne, Bebek İsmi ve Cinsiyet Destekli)
class OnboardingController extends ChangeNotifier {
  DateInputMode inputMode = DateInputMode.lmp;
  DateTime selectedDate = DateTime.now()
      .subtract(const Duration(days: 70)); // Varsayılan ~10. Hafta

  double heightCm = 165.0;
  double prePregnancyWeightKg = 60.0;

  String momName = '';
  String babyName = '';
  String babyGender = 'surprise'; // 'girl', 'boy', 'surprise'

  bool isLoading = false;
  String? errorMessage;

  // Hesaplanan Değerler
  DateTime get calculatedDueDate {
    if (inputMode == DateInputMode.lmp) {
      return MedicalCalculator.calculateDueDateFromLmp(selectedDate);
    }
    return selectedDate;
  }

  DateTime get calculatedLmp {
    if (inputMode == DateInputMode.dueDate) {
      return MedicalCalculator.calculateLmpFromDueDate(selectedDate);
    }
    return selectedDate;
  }

  PregnancyProgress get pregnancyProgress =>
      PregnancyProgress.fromLmpDate(calculatedLmp);

  int get currentWeek => pregnancyProgress.displayWeek;

  int get trimester => pregnancyProgress.trimester;

  double get vki {
    return MedicalCalculator.calculateVki(
      weightKg: prePregnancyWeightKg,
      heightCm: heightCm,
    );
  }

  String get vkiCategoryKey {
    return MedicalCalculator.getVkiCategoryKey(vki);
  }

  Map<String, dynamic> get weightGuideline {
    return MedicalCalculator.getWeightGainGuideline(vki);
  }

  void setDateInputMode(DateInputMode mode) {
    inputMode = mode;
    notifyListeners();
  }

  void setSelectedDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  void setHeight(double height) {
    heightCm = height;
    notifyListeners();
  }

  void setWeight(double weight) {
    prePregnancyWeightKg = weight;
    notifyListeners();
  }

  void setMomName(String name) {
    momName = name;
    notifyListeners();
  }

  void setBabyName(String name) {
    babyName = name;
    notifyListeners();
  }

  void setBabyGender(String gender) {
    babyGender = gender;
    notifyListeners();
  }

  /// Profili SQLite'a Kaydet
  Future<bool> saveProfileToDatabase() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final profile = ProfileModel(
        dueDate: AppDateUtils.toIso(calculatedDueDate),
        lmpDate: AppDateUtils.toIso(calculatedLmp),
        prePregnancyWeight: prePregnancyWeightKg,
        height: heightCm,
        vki: vki,
        currentWeek: currentWeek,
        momName: momName.trim().isEmpty ? null : momName.trim(),
        babyName: babyName.trim().isEmpty ? null : babyName.trim(),
        babyGender: babyGender,
      );

      await DatabaseHelper.instance.saveProfile(profile);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Profil kaydedilirken hata oluştu: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
