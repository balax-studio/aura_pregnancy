import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../models/profile_model.dart';
import '../../../models/emergency_card_model.dart';
import '../../../services/database_helper.dart';
import '../../../services/clinical_pdf_service.dart';

/// Aura Pregnancy - Klinik Hekim Raporu & Sağlık Özeti Diyaloğu
/// Hekim randevularında anne adayının klinik verilerini tek tıkla incelemesini ve paylaşmasını sağlar.
class ClinicalSummaryDialog extends StatefulWidget {
  const ClinicalSummaryDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const ClinicalSummaryDialog(),
    );
  }

  @override
  State<ClinicalSummaryDialog> createState() => _ClinicalSummaryDialogState();
}

class _ClinicalSummaryDialogState extends State<ClinicalSummaryDialog> {
  ProfileModel? _profile;
  EmergencyCardModel? _emergencyCard;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prof = await DatabaseHelper.instance.getProfile();
      final eCard = await DatabaseHelper.instance.getEmergencyCard();
      if (mounted) {
        setState(() {
          _profile = prof;
          _emergencyCard = eCard;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('ClinicalSummaryDialog load error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _generateClinicalText() {
    final p = _profile;
    final ec = _emergencyCard;
    final buffer = StringBuffer();

    buffer.writeln('AURA PREGNANCY - KLİNİK HEKİM ÖZETİ');
    buffer.writeln('────────────────────────────────────────');
    buffer.writeln('Hasta (Anne): ${p?.momName ?? ec?.patientName ?? "Belirtilmedi"}');
    buffer.writeln('Bebek: ${p?.babyName ?? "Belirtilmedi"} (${p?.babyGender ?? "-"})');
    buffer.writeln('Gebelik Haftası: ${p?.currentWeek ?? 12}. Hafta');
    buffer.writeln('Kan Grubu: ${ec?.bloodType ?? "Belirtilmedi"}');
    buffer.writeln('Son Adet Tarihi (SAT): ${p?.lmpDate ?? ec?.lmpDate ?? "-"}');
    buffer.writeln('Tahmini Doğum: ${p?.dueDate ?? ec?.dueDate ?? "-"}');
    buffer.writeln('Başlangıç Kilo: ${p?.prePregnancyWeight ?? "-"} kg | Boy: ${p?.height ?? "-"} cm | VKİ: ${p?.vki ?? "-"}');
    if (ec != null && ec.doctorName.isNotEmpty) {
      buffer.writeln('Takip Eden Hekim: ${ec.doctorName} (${ec.doctorPhone})');
    }
    if (ec != null && ec.hospitalName.isNotEmpty) {
      buffer.writeln('Hastane: ${ec.hospitalName}');
    }
    if (ec != null && ec.allergies.isNotEmpty) {
      buffer.writeln('Alerjiler: ${ec.allergies}');
    }
    if (ec != null && ec.chronicDiseases.isNotEmpty) {
      buffer.writeln('Kronik Durumlar: ${ec.chronicDiseases}');
    }
    buffer.writeln('────────────────────────────────────────');
    buffer.writeln('Rapor Tarihi: ${DateTime.now().toLocal().toString().split(" ")[0]}');

    return buffer.toString();
  }

  bool _isGeneratingPdf = false;

  Future<void> _generateAndSharePdf() async {
    setState(() => _isGeneratingPdf = true);
    try {
      await ClinicalPdfService.instance.generateAndShareReport(
        profile: _profile,
        emergencyCard: _emergencyCard,
      );
    } catch (e) {
      debugPrint('Error generating/sharing clinical PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF oluşturulurken bir sorun oluştu: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  void _copyToClipboard() {
    final text = _generateClinicalText();
    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'doctor_report_copied'.tr(),
                style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.clinicalGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        padding: const EdgeInsets.all(22),
        decoration: ClayTheme.clayDecoration(
          color: AppColors.clayCardSurface,
          borderRadius: 32,
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPink))
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Üst Rozet & Başlık
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.clinicalGreenBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Icon(Icons.medical_services_rounded, color: AppColors.clinicalGreen, size: 26),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'doctor_report_title'.tr(),
                              style: GoogleFonts.nunito(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            Text(
                              'doctor_report_sub'.tr(),
                              style: GoogleFonts.quicksand(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // İçerik Listesi (Kaydırılabilir Kartlar)
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSectionTitle('doctor_report_general_info'.tr()),
                          _buildCard([
                            _buildRow('Anne Adayı', _profile?.momName ?? _emergencyCard?.patientName ?? '-'),
                            _buildRow('Bebek İsmi', _profile?.babyName ?? 'Bebeğimiz'),
                            _buildRow('Gebelik Haftası', '${_profile?.currentWeek ?? 12}. Hafta'),
                            _buildRow('SAT', _profile?.lmpDate ?? _emergencyCard?.lmpDate ?? '-'),
                            _buildRow('Tahmini Doğum', _profile?.dueDate ?? _emergencyCard?.dueDate ?? '-'),
                          ]),
                          const SizedBox(height: 12),

                          _buildSectionTitle('doctor_report_health_info'.tr()),
                          _buildCard([
                            _buildRow('Kan Grubu', _emergencyCard?.bloodType ?? '-'),
                            _buildRow('Başlangıç Kilosu', '${_profile?.prePregnancyWeight ?? "-"} kg'),
                            _buildRow('Boy & VKİ', '${_profile?.height ?? "-"} cm  (VKİ: ${_profile?.vki ?? "-"})'),
                          ]),
                          const SizedBox(height: 12),

                          if (_emergencyCard != null && _emergencyCard!.doctorName.isNotEmpty) ...[
                            _buildSectionTitle('doctor_report_emergency_info'.tr()),
                            _buildCard([
                              _buildRow('Doktor', '${_emergencyCard!.doctorName} (${_emergencyCard!.doctorPhone})'),
                              _buildRow('Hastane', _emergencyCard!.hospitalName),
                              if (_emergencyCard!.allergies.isNotEmpty)
                                _buildRow('Alerjiler', _emergencyCard!.allergies),
                            ]),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 1. Ana Eylem: Kadınlara Özel A4 PDF Raporu Oluştur & İndir
                  ClayButton(
                    color: AppColors.clayPeach,
                    height: 52,
                    borderRadius: 16,
                    onPressed: _isGeneratingPdf ? null : _generateAndSharePdf,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isGeneratingPdf) ...[
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryPink),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'doctor_report_pdf_loading'.tr(),
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ] else ...[
                          const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primaryPink, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'doctor_report_pdf_btn'.tr(),
                            style: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 2. İkincil Eylem: Özeti Panoya Kopyala
                  ClayButton(
                    color: AppColors.clinicalGreenBg,
                    height: 46,
                    borderRadius: 16,
                    onPressed: _copyToClipboard,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.copy_rounded, color: AppColors.clinicalGreen, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'doctor_report_copy_btn'.tr(),
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.clinicalGreen,
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Text(
        title,
        style: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
