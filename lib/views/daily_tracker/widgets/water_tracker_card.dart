import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../core/widgets/micro_animations.dart';

/// Claymorphic Su Takip Kartı (2500 ml hedefli, hızlı ekleme butonları & akışkan mikro animasyonlar)
class WaterTrackerCard extends StatelessWidget {
  final int currentWaterMl;
  final Function(int) onAddWater;
  final VoidCallback onReset;

  const WaterTrackerCard({
    super.key,
    required this.currentWaterMl,
    required this.onAddWater,
    required this.onReset,
  });

  void _handleAddWater(int amount) {
    HapticFeedback.selectionClick();
    onAddWater(amount);
  }

  @override
  Widget build(BuildContext context) {
    const targetMl = 2500;
    final progress = (currentWaterMl / targetMl).clamp(0.0, 1.0);
    final percent = (progress * 100).toInt();

    return ClayCard(
      isGlazed: true,
      color: AppColors.claySky,
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
                      color: Colors.white,
                      borderRadius: 12,
                    ),
                    child: const Center(
                      child: Icon(Icons.water_drop_rounded,
                          color: AppColors.waterBlue, size: 20),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'water_tracker_title'.tr(),
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.waterBlue,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded,
                    size: 20, color: AppColors.textSecondary),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onReset();
                },
                tooltip: 'tracker_reset'.tr(),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  CountingNumberText(
                    value: currentWaterMl,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    ' / $targetMl ml',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '%',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.waterBlue,
                    ),
                  ),
                  CountingNumberText(
                    value: percent,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.waterBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Claymorphic Akışkan İlerleme Çubuğu (TweenAnimationBuilder)
          Container(
            height: 16,
            padding: const EdgeInsets.all(2.5),
            decoration: ClayTheme.concaveDecoration(
              color: AppColors.backgroundSubtle,
              borderRadius: 12,
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: progress),
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeOutCubic,
              builder: (context, animatedProgress, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: animatedProgress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.waterBlueLight, AppColors.waterBlueDark],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.waterBlueDark.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Hızlı Ekleme Butonları (Yaylanan ve Dokunsal Tıklamalı)
          Row(
            children: [
              Expanded(
                child: ClayButton(
                  color: AppColors.clayCardSurface,
                  height: 44,
                  borderRadius: 14,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  onPressed: () => _handleAddWater(250),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_drink_rounded,
                          color: AppColors.waterBlue, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '+250 ml',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: AppColors.waterBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ClayButton(
                  color: AppColors.clayCardSurface,
                  height: 44,
                  borderRadius: 14,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  onPressed: () => _handleAddWater(500),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.water_drop_outlined,
                          color: AppColors.waterBlue, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        '+500 ml',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: AppColors.waterBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
