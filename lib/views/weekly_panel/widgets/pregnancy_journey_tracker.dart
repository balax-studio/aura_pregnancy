import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import '../../../core/theme/inset_box_shadow.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../core/widgets/fruit_3d_widget.dart';
import '../../../core/constants/weekly_medical_data.dart';
import 'ad_reward_dialog.dart';

/// Gebelik Gelişim Aşaması Bilgi Modeli
class JourneyStageData {
  final String title;
  final String fruitComparison;
  final String weekRange;
  final String sizeInfo;
  final String description;
  final IconData icon;
  final Color themeColor;

  const JourneyStageData({
    required this.title,
    required this.fruitComparison,
    required this.weekRange,
    required this.sizeInfo,
    required this.description,
    required this.icon,
    required this.themeColor,
  });
}


/// Dribbble Aesthetic - Claymorphism 3D Fetal Journey Tracker
/// Evre butonları tıklanamaz (serüven göstergesi); daima mevcut haftanın evre bilgisini sunar.
class PregnancyJourneyTracker extends StatefulWidget {
  final int currentWeek;
  final int initialIndex;

  const PregnancyJourneyTracker({
    super.key,
    this.currentWeek = 12,
    this.initialIndex = 3,
  });

  @override
  State<PregnancyJourneyTracker> createState() => _PregnancyJourneyTrackerState();
}

class _PregnancyJourneyTrackerState extends State<PregnancyJourneyTracker> {
  late int _maxUnlockedIndex;
  late ScrollController _scrollController;
  late List<JourneyStageData> stages;

  @override
  void initState() {
    super.initState();
    stages = List.generate(40, (index) {
      final week = index + 1;
      final data = WeeklyMedicalData.getInfoForWeek(week);
      return JourneyStageData(
        title: 'weekly_journey_title'.tr(args: ['$week']),
        fruitComparison: data['fruit_name'] as String,
        weekRange: 'weekly_week_range'.tr(args: ['$week']),
        sizeInfo: '${data['length']} • ${data['weight']}',
        description: data['baby_dev'] as String,
        icon: data['icon'] as IconData,
        themeColor: _getThemeColorForWeek(week),
      );
    });
    
    _maxUnlockedIndex = widget.initialIndex.clamp(0, stages.length - 1);
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToActive());
  }

  Color _getThemeColorForWeek(int week) {
    const colors = [
      AppColors.primaryPink,
      AppColors.secondaryPeach,
      AppColors.accentGold,
      AppColors.lavenderPurple,
      AppColors.primaryDark,
    ];
    return colors[(week - 1) % colors.length];
  }

  void _scrollToActive() {
    if (_scrollController.hasClients) {
      final activeIndex = widget.initialIndex.clamp(0, stages.length - 1);
      final targetOffset = (activeIndex * 84.0) - 60.0;
      _scrollController.animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void didUpdateWidget(covariant PregnancyJourneyTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      if (widget.initialIndex > _maxUnlockedIndex) {
        setState(() {
          _maxUnlockedIndex = widget.initialIndex.clamp(0, stages.length - 1);
        });
      }
      _scrollToActive();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _openMysteryStageAd() {
    final nextIndex = _maxUnlockedIndex + 1;
    if (nextIndex >= stages.length) return;

    final nextStage = stages[nextIndex];

    AdRewardDialog.show(
      context: context,
      title: 'ad_reward_title'.tr(),
      subtitle: 'ad_reward_subtitle'.tr(args: [nextStage.weekRange]),
      unlockTargetName: 'ad_reward_target'.tr(args: [nextStage.weekRange]),
      onRewardEarned: () {
        setState(() {
          _maxUnlockedIndex = nextIndex;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToActive());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeIndex = widget.initialIndex.clamp(0, stages.length - 1);
    final activeStage = stages[activeIndex];
    final hasMysteryBox = _maxUnlockedIndex < stages.length - 1;
    final displayItemCount = (_maxUnlockedIndex + 1) + (hasMysteryBox ? 1 : 0);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: ClayTheme.clayDecoration(
        color: AppColors.clayCardSurface,
        borderRadius: 34,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Üst Başlık & Hafta Aralığı Rozeti
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'tracker_main_title'.tr(),
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'tracker_subtitle'.tr(args: ['${activeIndex + 1}', '${stages.length}']),
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: ClayTheme.clayButtonDecoration(
                    color: AppColors.clayPeach,
                    borderRadius: 16,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(activeStage.icon, size: 14, color: AppColors.primaryDark),
                      const SizedBox(width: 4),
                      Text(
                        activeStage.weekRange,
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Yatay 3D Meyve Serüveni Şeridi (Tıklanamaz - Sadece İzleme & Soru İşareti Reklam Kutusu)
          SizedBox(
            height: 124,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Arka plandaki bağlantı şeridi
                Positioned(
                  top: 36,
                  left: 20,
                  right: 20,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSubtle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Liste
                ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: displayItemCount,
                  itemBuilder: (context, index) {
                    // Eğer son index ve gizem kutusu ise
                    if (hasMysteryBox && index == displayItemCount - 1) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: GestureDetector(
                          onTap: _openMysteryStageAd,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 3D Soru İşareti Küresi (Mystery Clay Box)
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.rewardGoldBg.withValues(alpha: 0.24),
                                      offset: const Offset(0, 8),
                                      blurRadius: 16,
                                    ),
                                  ],
                                  border: Border.all(
                                    color: AppColors.rewardGold,
                                    width: 1.5,
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withValues(alpha: 0.80),
                                      AppColors.rewardGoldLight,
                                      AppColors.clayPeach,
                                    ],
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.help_outline_rounded,
                                    size: 28,
                                    color: AppColors.rewardGoldDark,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'next_size_question'.tr(),
                                style: GoogleFonts.nunito(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.rewardGoldDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Normal Açık Evre (Tıklanamaz, sabit serüven vitrini)
                    final isCurrent = index == activeIndex;
                    final stage = stages[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 3D Meyve Görseli
                          Container(
                            padding: EdgeInsets.all(isCurrent ? 3.0 : 0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: isCurrent
                                  ? Border.all(color: AppColors.primaryPink, width: 2.5)
                                  : null,
                            ),
                            child: Fruit3DWidget(
                              week: index + 1,
                              size: isCurrent ? 64 : 54,
                              borderRadius: isCurrent ? 32 : 27,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Text(
                            stage.fruitComparison,
                            style: GoogleFonts.nunito(
                              fontSize: isCurrent ? 11.5 : 10.0,
                              fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w700,
                              color: isCurrent ? AppColors.primaryDark : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
