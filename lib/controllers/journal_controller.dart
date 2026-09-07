import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/diary_model.dart';
import '../../models/profile_model.dart';
import '../../services/database_helper.dart';
import '../../utils/date_utils.dart';

/// Aura Journal (Romantik Anı Günlüğü) Controller'ı
class JournalController extends ChangeNotifier {
  List<DiaryModel> _entries = [];
  ProfileModel? _profile;
  bool _isLoading = false;

  List<DiaryModel> get entries => _entries;
  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;

  int get currentWeek => _profile?.currentWeek ?? 12;

  List<DiaryModel> get highlightEntries =>
      _entries.where((e) => e.isRomanticHighlight).toList();

  /// Günlükleri ve profili yükle
  Future<void> loadDiaries() async {
    _isLoading = true;
    notifyListeners();

    try {
      _profile = await DatabaseHelper.instance.getProfile();
      _entries = await DatabaseHelper.instance.getAllDiaries();

      // Eğer henüz kayıt yoksa kullanıcının gerçek takvimine göre örnek anılar oluştur
      if (_entries.isEmpty) {
        final calculatedDates = _calculateAccurateMilestoneDates(_profile);

        final sample1 = DiaryModel(
          pregnancyWeek: 12,
          date: calculatedDates['week12'] ?? AppDateUtils.todayIso(),
          noteText: 'sample_diary_note_1'.tr(),
          photoPath: 'assets/images/sample_ultrasound.png',
          moodRating: 5,
          isRomanticHighlight: true,
        );
        
        final sample2 = DiaryModel(
          pregnancyWeek: 8,
          date: calculatedDates['week8'] ?? AppDateUtils.toIso(DateTime.now().subtract(const Duration(days: 28))),
          noteText: 'sample_diary_note_2'.tr(),
          audioPath: 'assets/audio/voice_letter.m4a',
          moodRating: 5,
          isRomanticHighlight: true,
        );

        await DatabaseHelper.instance.insertDiary(sample1);
        await DatabaseHelper.instance.insertDiary(sample2);
        _entries = await DatabaseHelper.instance.getAllDiaries();
      }
    } catch (e) {
      debugPrint('JournalController load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Kullanıcının SAT (LMP) veya Tahmini Doğum Tarihine göre haftalık kesin tarihleri hesaplar
  Map<String, String> _calculateAccurateMilestoneDates(ProfileModel? prof) {
    DateTime? lmp;

    if (prof?.lmpDate != null && prof!.lmpDate!.isNotEmpty) {
      try {
        lmp = DateTime.parse(prof.lmpDate!);
      } catch (_) {}
    }

    if (lmp == null && prof?.dueDate != null && prof!.dueDate.isNotEmpty) {
      try {
        final due = DateTime.parse(prof.dueDate);
        lmp = due.subtract(const Duration(days: 280));
      } catch (_) {}
    }

    // Eğer profilde SAT veya Due yoksa mevcut haftaya göre lmp kestir
    if (lmp == null) {
      final curWeek = prof?.currentWeek ?? 12;
      lmp = DateTime.now().subtract(Duration(days: (curWeek - 1) * 7));
    }

    // 8. Hafta: 7 hafta + 3 gün (52. gün)
    final dateWeek8 = lmp.add(const Duration(days: 7 * 7 + 3));
    // 12. Hafta: 11 hafta + 3 gün (80. gün)
    final dateWeek12 = lmp.add(const Duration(days: 11 * 7 + 3));

    return {
      'week8': AppDateUtils.toIso(dateWeek8),
      'week12': AppDateUtils.toIso(dateWeek12),
    };
  }

  /// Yeni Anı Günlüğü Kaydet
  Future<bool> addEntry(DiaryModel entry) async {
    try {
      await DatabaseHelper.instance.insertDiary(entry);
      await loadDiaries();
      return true;
    } catch (e) {
      debugPrint('JournalController add error: $e');
      return false;
    }
  }

  /// Anı Sil
  Future<void> deleteEntry(int id) async {
    await DatabaseHelper.instance.deleteDiary(id);
    await loadDiaries();
  }
}
