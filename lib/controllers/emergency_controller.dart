import 'package:flutter/material.dart';
import '../../models/emergency_card_model.dart';
import '../../models/profile_model.dart';
import '../../services/database_helper.dart';
import '../../utils/date_utils.dart';

/// Acil Durum & Kırmızı Alarm Controller'ı
class EmergencyController extends ChangeNotifier {
  ProfileModel? _profile;
  EmergencyCardModel? _card;
  bool _isLoading = false;

  ProfileModel? get profile => _profile;
  EmergencyCardModel? get card => _card;
  bool get isLoading => _isLoading;

  /// Profil ve acil durum kartını veritabanından yükle
  Future<void> loadEmergencyData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _profile = await DatabaseHelper.instance.getProfile();
      final lmp = _profile?.lmpDate ?? AppDateUtils.todayIso();
      final due = _profile?.dueDate ?? AppDateUtils.todayIso();
      final week = _profile?.currentPregnancyWeek ?? 12;
      final momName = _profile?.momName?.isNotEmpty == true
          ? _profile!.momName!
          : 'Anne Adayı';

      final savedCard = await DatabaseHelper.instance.getEmergencyCard();
      if (savedCard != null) {
        // Güncel profil haftası ve tarihlerini koru
        _card = savedCard.copyWith(
          lmpDate: savedCard.lmpDate.isNotEmpty ? savedCard.lmpDate : lmp,
          dueDate: savedCard.dueDate.isNotEmpty ? savedCard.dueDate : due,
          currentWeek: week,
        );
      } else {
        _card = EmergencyCardModel(
          patientName: momName,
          bloodType: 'A Rh (+)',
          lmpDate: lmp,
          dueDate: due,
          currentWeek: week,
          allergies: 'İlaç alerjisi bildirilmedi',
          chronicDiseases: 'Yok',
          medications: 'Folik Asit, Magnezyum, Demir Takviyesi',
          emergencyContactName: _profile?.partnerName?.isNotEmpty == true
              ? _profile!.partnerName!
              : 'Acil Yakını (Eş)',
          emergencyContactPhone: '+90 555 000 11 22',
          doctorName: 'Uzm. Dr. Zeynep Kaya (Kadın Hastalıkları ve Doğum)',
          doctorPhone: '+90 532 111 22 33',
          hospitalName: 'Merkez Doğum & Perinatoloji Kliniği',
          recentSymptoms: 'Son kontrolde tansiyon 115/75 mmHg, ödem yok.',
        );
        await DatabaseHelper.instance.saveEmergencyCard(_card!);
      }
    } catch (e) {
      debugPrint('EmergencyController error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Acil durum kartını güncelle ve kaydet
  Future<void> updateEmergencyCard(EmergencyCardModel updatedCard) async {
    _card = updatedCard;
    notifyListeners();
    try {
      await DatabaseHelper.instance.saveEmergencyCard(updatedCard);
    } catch (e) {
      debugPrint('updateEmergencyCard error: $e');
    }
  }
}
