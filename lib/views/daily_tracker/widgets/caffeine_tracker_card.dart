import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/medical_specs.dart';
import '../../../core/theme/clay_theme.dart';

/// Claymorphic Kafein Takip Kartı (200 mg sınırı kontrolü ve görsel alarm)
class CaffeineTrackerCard extends StatelessWidget {
  final int currentCaffeineMg;
  final Function(int) onAddCaffeine;
  final VoidCallback onReset;

  const CaffeineTrackerCard({
    super.key,
    required this.currentCaffeineMg,
    required this.onAddCaffeine,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    const maxLimit = PregnancyMedicalSpecs.maxCaffeineMgPerDay;
    final isOverLimit = currentCaffeineMg > maxLimit;
    final remaining = (maxLimit - currentCaffeineMg).clamp(0, maxLimit.toInt());
    final progress = (currentCaffeineMg / maxLimit).clamp(0.0, 1.0);

    return ClayCard(
      color: isOverLimit ? AppColors.medicalAlertBg : AppColors.clayPeach,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: ClayTheme.clayDecoration(
                      color: isOverLimit ? AppColors.medicalAlertBg : Colors.white,
                      borderRadius: 12,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.local_cafe_rounded,
                        color: isOverLimit ? AppColors.medicalAlertRed : AppColors.secondaryPeach,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'caffeine_tracker_title'.tr(),
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isOverLimit ? AppColors.medicalAlertRed : AppColors.secondaryPeach,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 20, color: AppColors.textSecondary),
                onPressed: onReset,
                tooltip: 'tracker_reset'.tr(),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currentCaffeineMg / ${maxLimit.toInt()} mg',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isOverLimit ? AppColors.medicalAlertRed : AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: ClayTheme.clayButtonDecoration(
                  color: isOverLimit ? AppColors.medicalAlertRed : Colors.white,
                  borderRadius: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isOverLimit) ...[
                      const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      isOverLimit ? 'caffeine_tracker_limit_exceeded'.tr() : 'caffeine_tracker_remaining'.tr(args: [remaining.toString()]),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isOverLimit ? Colors.white : AppColors.secondaryPeach,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Claymorphic İlerleme Çubuğu (Progress Bar)
          Container(
            height: 16,
            padding: const EdgeInsets.all(2),
            decoration: ClayTheme.concaveDecoration(
              color: AppColors.backgroundSubtle,
              borderRadius: 12,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isOverLimit
                        ? const [AppColors.moodTired, AppColors.medicalAlertRed]
                        : const [AppColors.caffeineWarningAmber, AppColors.caffeineAlertOrange],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Aşım Görsel Alarm Kutusu
          if (isOverLimit) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: ClayTheme.clayDecoration(
                color: Colors.white,
                borderRadius: 16,
              ),
              child: Row(
                children: [
                  const Icon(Icons.crisis_alert_rounded, color: AppColors.medicalAlertRed, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'caffeine_tracker_warning'.tr(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.medicalAlertRed,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Hızlı İçecek Ekleme Butonları
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildDrinkButton('caffeine_drink_turkish_coffee'.tr(), '+60 mg', 60),
              _buildDrinkButton('caffeine_drink_filter_coffee'.tr(), '+95 mg', 95),
              _buildDrinkButton('caffeine_drink_black_tea'.tr(), '+40 mg', 40),
              _buildDrinkButton('caffeine_drink_green_tea'.tr(), '+25 mg', 25),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrinkButton(String name, String amountStr, int mg) {
    return ClayButton(
      color: AppColors.clayCardSurface,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      onPressed: () => onAddCaffeine(mg),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(name, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textPrimary)),
          const SizedBox(width: 4),
          Text(amountStr, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 11.5, color: AppColors.secondaryPeach)),
        ],
      ),
    );
  }
}
