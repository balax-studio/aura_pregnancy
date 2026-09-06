import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';

/// Claymorphic 1-40 Hafta Kaydırılabilir Timeline Şeridi (Gelecek Haftalar Kilitli & Reklam Korumalı)
class WeeklyTimelineStrip extends StatelessWidget {
  final int selectedWeek;
  final int currentWeek;
  final Set<int> unlockedWeeks;
  final Function(int) onWeekSelected;
  final Function(int) onLockedWeekTapped;

  const WeeklyTimelineStrip({
    super.key,
    required this.selectedWeek,
    required this.currentWeek,
    required this.unlockedWeeks,
    required this.onWeekSelected,
    required this.onLockedWeekTapped,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final week = index + 1;
          final isSelected = week == selectedWeek;
          final isCurrent = week == currentWeek;
          final isFuture = week > currentWeek;
          final isUnlocked = !isFuture || unlockedWeeks.contains(week);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
            child: GestureDetector(
              onTap: () {
                if (isUnlocked) {
                  onWeekSelected(week);
                } else {
                  onLockedWeekTapped(week);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 58,
                decoration: ClayTheme.clayDecoration(
                  color: isSelected
                      ? AppColors.clayRose
                      : (isCurrent
                          ? AppColors.clayMint
                          : (isFuture && !isUnlocked ? const Color(0xFFF3ECEE) : AppColors.clayCardSurface)),
                  borderRadius: 22,
                  isPressed: isSelected,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'common_week_label'.tr(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? AppColors.primaryDark
                                : (isFuture && !isUnlocked ? AppColors.textMuted : AppColors.textSecondary),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$week',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? AppColors.primaryDark
                                : (isCurrent
                                    ? AppColors.successGreen
                                    : (isFuture && !isUnlocked ? AppColors.textMuted : AppColors.textPrimary)),
                          ),
                        ),
                        if (isCurrent)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: const BoxDecoration(
                              color: AppColors.successGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    // Gelecek ve Kilitli Hafta İkonu
                    if (isFuture && !isUnlocked)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryPeach.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_rounded,
                            size: 10,
                            color: AppColors.secondaryPeach,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
