import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../core/widgets/fruit_3d_widget.dart';

/// Claymorphic Bebek Büyüklük ve Gelişim Kartı
class BabyGrowthCard extends StatelessWidget {
  final int week;
  final Map<String, dynamic> weekData;
  final String? babyDisplayName;

  const BabyGrowthCard({
    super.key,
    required this.week,
    required this.weekData,
    this.babyDisplayName,
  });

  @override
  Widget build(BuildContext context) {
    final fruitName = weekData['fruit_name'] as String? ?? 'baby_growth_fallback'.tr();
    final length = weekData['length'] as String? ?? '-';
    final weight = weekData['weight'] as String? ?? '-';
    final babyDev = weekData['baby_dev'] as String? ?? '';
    final motherChanges = weekData['mother_changes'] as String? ?? '';
    final babyName = babyDisplayName ?? 'baby_default_name'.tr();

    return Column(
      children: [
        // 1. Bebek Büyüklüğü ve Meyve Kartı
        ClayCard(
          color: AppColors.clayPeach,
          child: Column(
            children: [
              Row(
                children: [
                  // 3D Meyve Görsel Alanı
                  Fruit3DWidget(
                    week: week,
                    size: 68,
                    borderRadius: 20,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'baby_week_name_label'.tr(args: [week.toString(), babyName]),
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondaryPeach,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          fruitName,
                          style: GoogleFonts.outfit(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryDark,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Boy ve Kilo Sayaçları
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: ClayTheme.clayButtonDecoration(
                        color: Colors.white,
                        borderRadius: 16,
                      ),
                      child: Column(
                        children: [
                          Text('baby_est_length'.tr(), style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                          const SizedBox(height: 2),
                          Text(length, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: ClayTheme.clayButtonDecoration(
                        color: Colors.white,
                        borderRadius: 16,
                      ),
                      child: Column(
                        children: [
                          Text('baby_est_weight'.tr(), style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                          const SizedBox(height: 2),
                          Text(weight, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 2. Bebeğin Gelişimi Açıklama Kartı (Liquid Glass Katmanı)
        ClayCard(
          isGlazed: true,
          color: AppColors.clayCardSurface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: ClayTheme.clayDecoration(
                      color: AppColors.clayRose,
                      borderRadius: 10,
                    ),
                    child: const Center(
                      child: Icon(Icons.child_care_rounded, color: AppColors.primaryPink, size: 18),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'baby_dev_status'.tr(args: [babyName]),
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                babyDev,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 3. Annedeki Değişimler Kartı (Liquid Glass Katmanı)
        ClayCard(
          isGlazed: true,
          color: AppColors.clayLavender,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: ClayTheme.clayDecoration(
                      color: AppColors.clayRose,
                      borderRadius: 10,
                    ),
                    child: const Center(
                      child: Icon(Icons.spa_rounded, color: AppColors.lavenderPurple, size: 18),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'baby_mother_changes'.tr(),
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                motherChanges,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 4. Doktor Bilgilendirme ve Tıbbi Feragat Uyarısı
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: ClayTheme.concaveDecoration(
            color: AppColors.backgroundSubtle,
            borderRadius: 16,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.medical_information_outlined, color: AppColors.lavenderPurple, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'disclaimer_weekly'.tr(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
