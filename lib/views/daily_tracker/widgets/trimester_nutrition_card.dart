import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';

/// Claymorphic Trimester Beslenme ve Kalori Tavsiye Kartı
class TrimesterNutritionCard extends StatelessWidget {
  final int currentWeek;
  final int trimester;

  const TrimesterNutritionCard({
    super.key,
    required this.currentWeek,
    required this.trimester,
  });

  @override
  Widget build(BuildContext context) {
    String title = '';
    String extraCal = '';
    List<String> foodItems = [];
    Color cardColor = AppColors.clayMint;
    Color accentColor = AppColors.successGreen;

    if (trimester == 1) {
      cardColor = AppColors.clayMint;
      accentColor = AppColors.successGreen;
      title = 'nutrition_t1_title'.tr();
      extraCal = 'nutrition_t1_cal'.tr();
      foodItems = [
        'nutrition_t1_item1'.tr(),
        'nutrition_t1_item2'.tr(),
        'nutrition_t1_item3'.tr(),
        'nutrition_t1_item4'.tr(),
      ];
    } else if (trimester == 2) {
      cardColor = AppColors.clayPeach;
      accentColor = AppColors.secondaryPeach;
      title = 'nutrition_t2_title'.tr();
      extraCal = 'nutrition_t2_cal'.tr();
      foodItems = [
        'nutrition_t2_item1'.tr(),
        'nutrition_t2_item2'.tr(),
        'nutrition_t2_item3'.tr(),
        'nutrition_t2_item4'.tr(),
      ];
    } else {
      cardColor = AppColors.clayRose;
      accentColor = AppColors.primaryPink;
      title = 'nutrition_t3_title'.tr();
      extraCal = 'nutrition_t3_cal'.tr();
      foodItems = [
        'nutrition_t3_item1'.tr(),
        'nutrition_t3_item2'.tr(),
        'nutrition_t3_item3'.tr(),
        'nutrition_t3_item4'.tr(),
      ];
    }

    return ClayCard(
      color: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: ClayTheme.clayDecoration(
                  color: Colors.white,
                  borderRadius: 12,
                ),
                child: Center(
                  child: Icon(Icons.restaurant_rounded, color: accentColor, size: 20),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Kalori Bandı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: ClayTheme.clayDecoration(
              color: Colors.white,
              borderRadius: 16,
              isPressed: true,
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, color: AppColors.accentGold, size: 20),
                const SizedBox(width: 6),
                Text(
                  extraCal,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Maddeler
          ...foodItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 10),

          // Doktor Danışma ve Tıbbi Feragat Uyarısı
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.accentGold, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'disclaimer_nutrition'.tr(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
