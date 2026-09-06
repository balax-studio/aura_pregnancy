import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/clay_theme.dart';
import '../../controllers/emergency_controller.dart';
import 'widgets/medical_id_card_view.dart';
import 'widgets/edit_emergency_card_sheet.dart';
import '../widgets/medical_disclaimer_sheet.dart';

import '../../services/database_helper.dart';

/// Gebelikte Acil Tıbbi Kart ve Hızlı Doktor Arama Ekranı
class EmergencyScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const EmergencyScreen({super.key, this.onBack});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final EmergencyController _controller = EmergencyController();

  @override
  void initState() {
    super.initState();
    _controller.loadEmergencyData();
    _controller.addListener(_onControllerUpdate);
    DatabaseHelper.appDataRevision.addListener(_onAppDataChanged);
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  void _onAppDataChanged() {
    if (mounted) {
      _controller.loadEmergencyData();
    }
  }

  @override
  void dispose() {
    DatabaseHelper.appDataRevision.removeListener(_onAppDataChanged);
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  /// Rehber ve telefon izinlerini isteyip arama ekranını (dialer) açar
  Future<void> _callDoctor() async {
    final card = _controller.card;
    final doctorPhone = card?.doctorPhone.trim() ?? '';

    if (doctorPhone.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('emergency_no_phone_error'.tr()),
          backgroundColor: AppColors.medicalAlertRed,
          action: SnackBarAction(
            label: 'emergency_edit_btn'.tr(),
            textColor: Colors.white,
            onPressed: _openEditSheet,
          ),
        ),
      );
      return;
    }

    // Telefon numarasını temizle ve tel: URI oluştur (Sistem arama ekranını açar, izin gerektirmez)
    final cleanPhone = doctorPhone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');

    try {
      if (await canLaunchUrl(uri)) {
        // launchUrl tel: şeması ile doğrudan aramaz, Android çevirici ekranını açarak son dokunuşu kullanıcıya bırakır
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('emergency_call_failed'.tr()),
            backgroundColor: AppColors.medicalAlertRed,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error launching dialer: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('emergency_call_failed'.tr()),
          backgroundColor: AppColors.medicalAlertRed,
        ),
      );
    }
  }

  void _openEditSheet() {
    if (_controller.card == null) return;
    EditEmergencyCardSheet.show(
      context: context,
      card: _controller.card!,
      onSave: (updated) {
        _controller.updateEmergencyCard(updated);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('emergency_saved_success'.tr()),
            backgroundColor: AppColors.successGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: (widget.onBack != null || Navigator.canPop(context))
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryDark),
                onPressed: () {
                  if (widget.onBack != null) {
                    widget.onBack!();
                  } else if (Navigator.canPop(context)) {
                    Navigator.of(context).pop();
                  }
                },
              )
            : null,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emergency_rounded, color: AppColors.medicalAlertRed, size: 22),
            const SizedBox(width: 8),
            Text(
              'emergency_appbar_title'.tr(),
              style: const TextStyle(
                color: AppColors.medicalAlertRed,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 14),
            child: MedicalInfoButton(),
          ),
        ],
      ),
      body: SafeArea(
        child: _controller.isLoading || _controller.card == null
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPink))
            : Column(
                children: [
                  // Tıbbi Acil Kartı İçeriği
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Column(
                        children: [
                          MedicalIdCardView(card: _controller.card!),
                          const SizedBox(height: 14),
                          const MedicalDisclaimerBanner(),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),

                  // Alt Aksiyon Butonları: "Bilgileri Düzenle" ve "Doktoru Ara"
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Row(
                      children: [
                        // Bilgileri Düzenle Butonu
                        Expanded(
                          flex: 5,
                          child: ClayButton(
                            color: AppColors.clayLavender,
                            height: 54,
                            onPressed: _openEditSheet,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.edit_note_rounded, color: AppColors.primaryDark, size: 22),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'emergency_edit_btn'.tr(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Doktoru Ara Butonu
                        Expanded(
                          flex: 6,
                          child: ClayButton(
                            color: AppColors.medicalAlertRed,
                            height: 54,
                            onPressed: _callDoctor,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 22),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'emergency_call_doctor_btn'.tr(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
