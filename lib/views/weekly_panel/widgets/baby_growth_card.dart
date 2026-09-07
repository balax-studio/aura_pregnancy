import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/baby_size_themes_data.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../core/widgets/fruit_3d_widget.dart';

/// Claymorphic Bebek Büyüklük ve Gelişim Kartı (4 Farklı Boyut Teması Destekli)
class BabyGrowthCard extends StatefulWidget {
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
  State<BabyGrowthCard> createState() => _BabyGrowthCardState();
}

class _BabyGrowthCardState extends State<BabyGrowthCard> {
  BabySizeThemeType _activeTheme = BabySizeThemeType.fruit;

  @override
  Widget build(BuildContext context) {
    final themeItem = BabySizeThemesData.getItemForWeek(widget.week, _activeTheme);
    final fallbackFruit = widget.weekData['fruit_name'] as String? ?? 'baby_growth_fallback'.tr();
    final displayTitle = _activeTheme == BabySizeThemeType.fruit ? fallbackFruit : themeItem.title;

    final length = widget.weekData['length'] as String? ?? '${themeItem.lengthCm} cm';
    final weight = widget.weekData['weight'] as String? ?? '${themeItem.weightGrams.toInt()} g';
    final babyDev = widget.weekData['baby_dev'] as String? ?? '';
    final motherChanges = widget.weekData['mother_changes'] as String? ?? '';
    final babyName = widget.babyDisplayName ?? 'baby_default_name'.tr();

    return Column(
      children: [
        // 1. Bebek Büyüklüğü ve Tema Kartı
        ClayCard(
          color: AppColors.clayPeach,
          child: Column(
            children: [
              // Tema Seçim Kapsülleri
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Boyut Teması:',
                    style: GoogleFonts.outfit(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Row(
                    children: BabySizeThemeType.values.map((theme) {
                      final isSelected = theme == _activeTheme;
                      String emoji;
                      switch (theme) {
                        case BabySizeThemeType.fruit:
                          emoji = '🥑';
                          break;
                        case BabySizeThemeType.animal:
                          emoji = '🧸';
                          break;
                        case BabySizeThemeType.pastry:
                          emoji = '🥐';
                          break;
                        case BabySizeThemeType.toy:
                          emoji = '🚂';
                          break;
                      }
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _activeTheme = theme);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryPink : Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primaryPink.withValues(alpha: 0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  // 3D Meyve / Tema Görsel Alanı
                  _activeTheme == BabySizeThemeType.fruit
                      ? Fruit3DWidget(
                          week: widget.week,
                          size: 68,
                          borderRadius: 20,
                        )
                      : Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              themeItem.emoji,
                              style: const TextStyle(fontSize: 34),
                            ),
                          ),
                        ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'baby_week_name_label'.tr(args: [widget.week.toString(), babyName]),
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondaryPeach,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          displayTitle,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryDark,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (_activeTheme != BabySizeThemeType.fruit)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              themeItem.description,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
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
                    decoration: BoxDecoration(
                      color: AppColors.clayRose,
                      borderRadius: BorderRadius.circular(10),
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
                    decoration: BoxDecoration(
                      color: AppColors.clayRose,
                      borderRadius: BorderRadius.circular(10),
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
