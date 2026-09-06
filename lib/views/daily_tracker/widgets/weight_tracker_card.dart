import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../models/profile_model.dart';
import '../../../services/medical_calculator.dart';

/// Claymorphic Günlük Kilo Takibi ve IOM Hedef Kıyaslama Kartı
class WeightTrackerCard extends StatefulWidget {
  final double? currentWeightEntry;
  final ProfileModel? profile;
  final Function(double) onSaveWeight;

  const WeightTrackerCard({
    super.key,
    required this.currentWeightEntry,
    required this.profile,
    required this.onSaveWeight,
  });

  @override
  State<WeightTrackerCard> createState() => _WeightTrackerCardState();
}

class _WeightTrackerCardState extends State<WeightTrackerCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final val = widget.currentWeightEntry ?? widget.profile?.prePregnancyWeight ?? 60.0;
    _controller = TextEditingController(text: val.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preWeight = widget.profile?.prePregnancyWeight ?? 60.0;
    final currentWeight = double.tryParse(_controller.text) ?? widget.currentWeightEntry ?? preWeight;
    final vki = widget.profile?.vki ?? 22.0;
    final week = widget.profile?.currentWeek ?? 12;

    final targetInfo = MedicalCalculator.calculateTargetWeightForWeek(
      prePregnancyWeight: preWeight,
      vki: vki,
      week: week,
    );

    final targetWeight = targetInfo['target_weight']!;
    final diff = currentWeight - preWeight;

    return ClayCard(
      color: AppColors.clayLavender,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  child: Icon(Icons.monitor_weight_rounded, color: AppColors.primaryDark, size: 20),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'weight_tracker_title'.tr(),
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Container(
                  height: 52,
                  decoration: ClayTheme.concaveDecoration(
                    color: Colors.white,
                    borderRadius: 16,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'weight_hint'.tr(),
                            hintStyle: GoogleFonts.plusJakartaSans(
                              color: AppColors.textMuted,
                              fontSize: 14,
                            ),
                          ),
                          onSubmitted: (val) {
                            final parsed = double.tryParse(val);
                            if (parsed != null) widget.onSaveWeight(parsed);
                          },
                        ),
                      ),
                      Text(
                        'kg',
                        style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ClayButton(
                color: AppColors.clayRose,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                onPressed: () {
                  final parsed = double.tryParse(_controller.text);
                  if (parsed != null) {
                    widget.onSaveWeight(parsed);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('weight_updated_toast'.tr())),
                    );
                  }
                },
                child: Text(
                  'common_save'.tr(),
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Karşılaştırma Durumu
          Container(
            padding: const EdgeInsets.all(12),
            decoration: ClayTheme.clayDecoration(
              color: Colors.white,
              borderRadius: 18,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('weight_start_label'.tr(), style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    Text('${preWeight.toStringAsFixed(1)} kg', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('weight_target_label'.tr(args: [week.toString()]), style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    Text('${targetWeight.toStringAsFixed(1)} kg', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.successGreen)),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('weight_total_gain_label'.tr(), style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
                    Text(
                      '${diff >= 0 ? "+" : ""}${diff.toStringAsFixed(1)} kg',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: diff > 5.0 ? AppColors.secondaryPeach : AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

