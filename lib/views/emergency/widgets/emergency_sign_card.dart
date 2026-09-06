import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/inset_box_shadow.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';

/// Claymorphic Acil Tehlike İşareti Kartı
class EmergencySignCard extends StatelessWidget {
  final String title;
  final String detail;
  final String urgency;

  const EmergencySignCard({
    super.key,
    required this.title,
    required this.detail,
    required this.urgency,
  });

  @override
  Widget build(BuildContext context) {
    final isCritical = urgency == 'Kritik' || urgency == 'Critical' || urgency == 'emergency_urgency_critical'.tr();
    final cardBgColor = isCritical ? AppColors.medicalAlertBg : AppColors.clayCardSurface;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: ClayTheme.clayDecoration(
        color: cardBgColor,
        borderRadius: 22,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      isCritical ? Icons.crisis_alert_rounded : Icons.warning_amber_rounded,
                      color: isCritical ? AppColors.medicalAlertRed : AppColors.secondaryPeach,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isCritical ? AppColors.medicalAlertRed : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCritical ? AppColors.medicalAlertRed : AppColors.secondaryPeach,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  urgency,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            detail,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
