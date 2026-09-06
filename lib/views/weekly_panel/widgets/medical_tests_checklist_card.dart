import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';

/// Claymorphic Tıbbi Tarama & Test Takip Kartı
class MedicalTestsChecklistCard extends StatefulWidget {
  final Map<String, dynamic>? milestoneTest;
  final int week;

  const MedicalTestsChecklistCard({
    super.key,
    required this.milestoneTest,
    required this.week,
  });

  @override
  State<MedicalTestsChecklistCard> createState() => _MedicalTestsChecklistCardState();
}

class _MedicalTestsChecklistCardState extends State<MedicalTestsChecklistCard> {
  bool _isCompleted = false;

  @override
  Widget build(BuildContext context) {
    if (widget.milestoneTest == null) {
      return const SizedBox.shrink();
    }

    final test = widget.milestoneTest!;
    final title = test['title'] as String? ?? 'test_critical_screening'.tr();
    final desc = test['desc'] as String? ?? '';
    final action = test['action'] as String? ?? '';

    return ClayCard(
      color: _isCompleted ? AppColors.clayMint : AppColors.claySky,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _isCompleted ? AppColors.successGreen : AppColors.waterBlue,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _isCompleted = !_isCompleted),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: ClayTheme.clayDecoration(
                    color: _isCompleted ? AppColors.clayMint : Colors.white,
                    borderRadius: 14,
                    isPressed: _isCompleted,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        size: 16,
                        color: _isCompleted ? AppColors.successGreen : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isCompleted ? 'test_completed'.tr() : 'test_to_do'.tr(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: _isCompleted ? AppColors.successGreen : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Text(
            desc,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: ClayTheme.concaveDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: 14,
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.accentGold),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    action,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
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
