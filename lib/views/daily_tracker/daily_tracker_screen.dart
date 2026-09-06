import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/constants/app_colors.dart';
import '../../controllers/daily_tracker_controller.dart';
import '../../utils/date_utils.dart';
import 'widgets/medication_tracker_card.dart';
import 'widgets/water_tracker_card.dart';
import 'widgets/caffeine_tracker_card.dart';
import 'widgets/walking_tracker_card.dart';
import 'widgets/trimester_nutrition_card.dart';
import 'widgets/weight_tracker_card.dart';
import '../widgets/medical_disclaimer_sheet.dart';
import '../../services/database_helper.dart';
import '../../core/widgets/micro_animations.dart';

/// Claymorphic Günlük Takip & Rutin Yönetim Ekranı (Daily Tracker)
class DailyTrackerScreen extends StatefulWidget {
  const DailyTrackerScreen({super.key});

  @override
  State<DailyTrackerScreen> createState() => _DailyTrackerScreenState();
}

class _DailyTrackerScreenState extends State<DailyTrackerScreen> {
  final DailyTrackerController _controller = DailyTrackerController();

  @override
  void initState() {
    super.initState();
    _controller.loadTodayData();
    _controller.addListener(() => setState(() {}));
    DatabaseHelper.appDataRevision.addListener(_onAppDataChanged);
  }

  void _onAppDataChanged() {
    if (mounted) {
      _controller.loadTodayData();
    }
  }

  @override
  void dispose() {
    DatabaseHelper.appDataRevision.removeListener(_onAppDataChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryPink)),
      );
    }

    final log = _controller.currentLog;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'daily_tracker_title'.tr(),
              style: GoogleFonts.outfit(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              AppDateUtils.formatToday(),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. İlaç & Vitamin Takip Modülü (WhatsApp İsteği)
              const StaggeredSlideFade(
                index: 0,
                child: MedicationTrackerCard(),
              ),
              const SizedBox(height: 16),

              // 2. Kilo Takip Modülü (WhatsApp İsteği)
              StaggeredSlideFade(
                index: 1,
                child: WeightTrackerCard(
                  currentWeightEntry: log.weightEntry,
                  profile: _controller.profile,
                  onSaveWeight: (w) => _controller.setWeightEntry(w),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Su Takip Modülü
              StaggeredSlideFade(
                index: 2,
                child: WaterTrackerCard(
                  currentWaterMl: log.waterIntakeMl,
                  onAddWater: (ml) => _controller.addWater(ml),
                  onReset: () => _controller.resetWater(),
                ),
              ),
              const SizedBox(height: 16),

              // 4. Yürüyüş & Adım Takip Modülü
              StaggeredSlideFade(
                index: 3,
                child: WalkingTrackerCard(
                  stepCount: log.stepCount,
                  walkingMinutes: log.walkingMinutes,
                  currentWeek: _controller.currentWeek,
                  onAddSteps: (steps, {minutes = 0}) => _controller.addSteps(steps, minutes: minutes),
                  onReset: () => _controller.resetSteps(),
                ),
              ),
              const SizedBox(height: 16),

              // 5. Kafein Takip Modülü (200 mg sınırı ve alarmı)
              StaggeredSlideFade(
                index: 4,
                child: CaffeineTrackerCard(
                  currentCaffeineMg: log.caffeineMg,
                  onAddCaffeine: (mg) => _controller.addCaffeine(mg),
                  onReset: () => _controller.resetCaffeine(),
                ),
              ),
              const SizedBox(height: 16),

              // 6. Trimester Beslenme ve Kalori Rehberi
              StaggeredSlideFade(
                index: 5,
                child: TrimesterNutritionCard(
                  currentWeek: _controller.currentWeek,
                  trimester: _controller.trimester,
                ),
              ),
              const SizedBox(height: 16),

              // Yasal & Tıbbi Sorumluluk Reddi Bildirimi
              const StaggeredSlideFade(
                index: 6,
                child: MedicalDisclaimerBanner(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
