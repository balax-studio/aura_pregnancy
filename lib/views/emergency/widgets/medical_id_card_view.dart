import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../models/emergency_card_model.dart';
import '../../../utils/date_utils.dart';

/// Claymorphic Acil Servis Tıbbi Not Kartı (Emergency ID Card)
class MedicalIdCardView extends StatelessWidget {
  final EmergencyCardModel card;

  const MedicalIdCardView({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      color: AppColors.clayCardSurface,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Başlık Şeridi
          Container(
            padding: const EdgeInsets.all(12),
            decoration: ClayTheme.clayDecoration(
              color: AppColors.clayRose,
              borderRadius: 18,
            ),
            child: Row(
              children: [
                const Icon(Icons.local_hospital_rounded, color: AppColors.primaryPink, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'medical_card_title'.tr(),
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        'medical_card_sub'.tr(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tıbbi Temel Bilgiler Grid
          _buildInfoRow('medical_card_patient'.tr(), card.patientName.isNotEmpty ? card.patientName : '-'),
          _buildInfoRow('medical_card_blood'.tr(), card.bloodType.isNotEmpty ? card.bloodType : '-', isHighlight: true),
          _buildInfoRow('medical_card_week'.tr(), 'weekly_week_range'.tr(args: [card.currentWeek.toString()])),
          _buildInfoRow('medical_card_lmp'.tr(), card.lmpDate.isNotEmpty ? AppDateUtils.formatDisplay(card.lmpDate) : '-'),
          _buildInfoRow('medical_card_due'.tr(), card.dueDate.isNotEmpty ? AppDateUtils.formatDisplay(card.dueDate) : '-'),
          const Divider(height: 20),

          _buildInfoRow('medical_card_allergies'.tr(), card.allergies.isNotEmpty ? card.allergies : '-', isAlert: card.allergies.isNotEmpty && card.allergies.toLowerCase() != 'yok' && card.allergies.toLowerCase() != 'none'),
          _buildInfoRow('medical_card_chronic'.tr(), card.chronicDiseases.isNotEmpty ? card.chronicDiseases : '-'),
          _buildInfoRow('medical_card_meds'.tr(), card.medications.isNotEmpty ? card.medications : '-'),
          const Divider(height: 20),

          _buildInfoRow('medical_card_doctor'.tr(), card.doctorName.isNotEmpty ? card.doctorName : '-'),
          _buildInfoRow('medical_card_doc_phone'.tr(), card.doctorPhone.isNotEmpty ? card.doctorPhone : '-'),
          _buildInfoRow('medical_card_hospital'.tr(), card.hospitalName.isNotEmpty ? card.hospitalName : '-'),
          _buildInfoRow(
            'medical_card_contact'.tr(),
            card.emergencyContactName.isNotEmpty
                ? '${card.emergencyContactName}${card.emergencyContactPhone.isNotEmpty ? ' (${card.emergencyContactPhone})' : ''}'
                : '-',
          ),
          const Divider(height: 20),

          // Semptom Özeti
          Text(
            'medical_card_symptoms'.tr(),
            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: ClayTheme.concaveDecoration(
              color: AppColors.backgroundSubtle,
              borderRadius: 12,
            ),
            child: Text(
              card.recentSymptoms,
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false, bool isAlert = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isAlert
                    ? AppColors.medicalAlertRed
                    : (isHighlight ? AppColors.primaryPink : AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
