import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/constants/app_colors.dart';
import '../../controllers/weekly_panel_controller.dart';
import '../../services/database_helper.dart';
import 'widgets/weekly_timeline_strip.dart';
import 'widgets/pregnancy_journey_tracker.dart';
import 'widgets/baby_growth_card.dart';
import 'widgets/medical_tests_checklist_card.dart';
import 'widgets/ad_reward_dialog.dart';
import '../widgets/medical_disclaimer_sheet.dart';
import '../widgets/clay_native_ad_card.dart';
import '../../core/widgets/micro_animations.dart';

/// Hafta Hafta Tıbbi Bilgilendirme ve Test Takvimi Ekranı
class WeeklyPanelScreen extends StatefulWidget {
  const WeeklyPanelScreen({super.key});

  @override
  State<WeeklyPanelScreen> createState() => _WeeklyPanelScreenState();
}

class _WeeklyPanelScreenState extends State<WeeklyPanelScreen> {
  final WeeklyPanelController _controller = WeeklyPanelController();

  @override
  void initState() {
    super.initState();
    _controller.loadProfileWeek();
    _controller.addListener(() => setState(() {}));
    DatabaseHelper.appDataRevision.addListener(_onAppDataChanged);
  }

  void _onAppDataChanged() {
    if (mounted) {
      _controller.loadProfileWeek();
    }
  }

  @override
  void dispose() {
    DatabaseHelper.appDataRevision.removeListener(_onAppDataChanged);
    _controller.dispose();
    super.dispose();
  }

  void _handleLockedWeekTapped(int week) {
    AdRewardDialog.show(
      context: context,
      title: 'weekly_ad_title'.tr(args: [week.toString()]),
      subtitle: 'weekly_ad_subtitle'.tr(args: [week.toString()]),
      unlockTargetName: 'weekly_guide_title'.tr(args: [week.toString()]),
      onRewardEarned: () {
        _controller.unlockWeek(week);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryPink)),
      );
    }

    final data = _controller.currentWeekData;
    final milestoneTest = data['milestone_test'] as Map<String, dynamic>?;
    final stageIndex = (_controller.selectedWeek - 1).clamp(0, 39);
    final babyDisplayName = _controller.profile?.babyDisplayName;
    final statusText = _controller.selectedWeek <= _controller.actualPregnancyWeek
        ? 'weekly_status_current'.tr()
        : 'weekly_status_future'.tr();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'weekly_guide_title'.tr(args: [_controller.selectedWeek.toString()]),
              style: GoogleFonts.outfit(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'weekly_trimester_status'.tr(args: [_controller.selectedTrimester.toString(), statusText]),
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 14),
            child: MedicalInfoButton(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1-40 Hafta Kaydırılabilir Şerit (Gelecek Haftalar Reklam Kilitli)
            WeeklyTimelineStrip(
              selectedWeek: _controller.selectedWeek,
              currentWeek: _controller.actualPregnancyWeek,
              unlockedWeeks: _controller.unlockedWeeks,
              onWeekSelected: (w) => _controller.selectWeek(w),
              onLockedWeekTapped: (w) => _handleLockedWeekTapped(w),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 3D Claymorphic Fetal Journey Tracker (Gelecek Meyveler Gizli + Soru İşaretli Reklam Kutusu)
                    StaggeredSlideFade(
                      index: 0,
                      child: PregnancyJourneyTracker(
                        currentWeek: _controller.actualPregnancyWeek,
                        initialIndex: stageIndex,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tıbbi Tarama & Test Takip Kartı (Varsa)
                    if (milestoneTest != null) ...[
                      StaggeredSlideFade(
                        index: 1,
                        child: MedicalTestsChecklistCard(
                          milestoneTest: milestoneTest,
                          week: _controller.selectedWeek,
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Bebek Büyüklüğü ve Gelişim Kartı
                    StaggeredSlideFade(
                      index: 2,
                      child: BabyGrowthCard(
                        week: _controller.selectedWeek,
                        weekData: data,
                        babyDisplayName: babyDisplayName,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Kil Temalı Yerel Gelişmiş Reklam Kartı (Sponsorlu Destekçi)
                    const StaggeredSlideFade(
                      index: 3,
                      child: ClayNativeAdCard(
                        cardColor: Color(0xFFFEE6E0),
                        icon: Icons.spa_rounded,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Yasal & Tıbbi Sorumluluk Reddi Bildirimi
                    const StaggeredSlideFade(
                      index: 4,
                      child: MedicalDisclaimerBanner(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
