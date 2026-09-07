import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/clay_theme.dart';
import '../../controllers/daily_tracker_controller.dart';
import '../../models/daily_log_model.dart';
import '../../utils/date_utils.dart';
import 'widgets/medication_tracker_card.dart';
import 'widgets/water_tracker_card.dart';
import 'widgets/caffeine_tracker_card.dart';
import 'widgets/walking_tracker_card.dart';
import 'widgets/trimester_nutrition_card.dart';
import 'widgets/weight_tracker_card.dart';
import 'screens/safety_radar_screen.dart';
import 'screens/doctor_vault_screen.dart';
import '../widgets/medical_disclaimer_sheet.dart';
import '../widgets/emergency_beacon_button.dart';
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
  int _selectedFilterIndex = 0; // 0: Tümü, 1: Sıvı & Beslenme, 2: Beden & Adım

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

  Widget _buildVitalitySummaryBar(DailyLogModel log) {
    final waterProgress = (log.waterIntakeMl / 2500.0).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: ClayTheme.clayDecoration(
        color: AppColors.clayLavender,
        borderRadius: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.spa_rounded, color: AppColors.lavenderPurple, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'daily_vitality_balance'.tr(),
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'daily_vitality_fluid_target'.tr(args: [(waterProgress * 100).toInt().toString()]),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.lavenderPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: waterProgress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.6),
              color: AppColors.waterBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = [
      {'label': 'daily_filter_all'.tr(), 'icon': Icons.dashboard_customize_rounded},
      {'label': 'daily_filter_nutrition'.tr(), 'icon': Icons.local_dining_rounded},
      {'label': 'daily_filter_body'.tr(), 'icon': Icons.directions_walk_rounded},
    ];

    return Container(
      height: 42,
      margin: const EdgeInsets.only(bottom: 14),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedFilterIndex == index;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedFilterIndex = index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: isSelected
                  ? ClayTheme.clayButtonDecoration(
                      color: AppColors.primaryPink,
                      borderRadius: 16,
                      isPressed: true,
                    )
                  : ClayTheme.clayDecoration(
                      color: AppColors.clayCardSurface,
                      borderRadius: 16,
                    ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filters[index]['icon'] as IconData,
                    size: 15,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    filters[index]['label'] as String,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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

    final log = _controller.currentLog;

    // Filtreleme mantığı
    final showNutrition = _selectedFilterIndex == 0 || _selectedFilterIndex == 1;
    final showBody = _selectedFilterIndex == 0 || _selectedFilterIndex == 2;

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
              AppDateUtils.formatToday(locale: context.locale.languageCode),
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: const [
          MedicalInfoButton(),
          SizedBox(width: 4),
          Padding(
            padding: EdgeInsets.only(right: 14),
            child: EmergencyBeaconButton(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Üst Canlılık Göstergesi
              _buildVitalitySummaryBar(log),

              // Aura İnovatif Araçlar: Güvenlik Radarı & Doktora Sorulacaklar
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        SafetyRadarScreen.open(
                          context,
                          partnerName: _controller.profile?.partnerName,
                          babyName: _controller.profile?.babyName,
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: ClayCard(
                        color: AppColors.clayMint,
                        borderRadius: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Row(
                          children: [
                            const Text('🔍', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'daily_safety_radar'.tr(),
                                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                                  ),
                                  Text(
                                    'daily_safety_radar_sub'.tr(),
                                    style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        DoctorVaultScreen.open(
                          context,
                          currentWeek: _controller.profile?.currentWeek ?? 1,
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: ClayCard(
                        color: AppColors.clayLavender,
                        borderRadius: 20,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Row(
                          children: [
                            const Text('🩺', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'daily_doctor_vault'.tr(),
                                    style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                                  ),
                                  Text(
                                    'daily_doctor_vault_sub'.tr(),
                                    style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Segmentli Kategori Filtre Butonları
              _buildFilterBar(),

              // 1. İlaç & Vitamin Takip Modülü
              if (showNutrition) ...[
                const StaggeredSlideFade(
                  index: 0,
                  child: MedicationTrackerCard(),
                ),
                const SizedBox(height: 16),
              ],

              // 2. Kilo Takip Modülü
              if (showBody) ...[
                StaggeredSlideFade(
                  index: 1,
                  child: WeightTrackerCard(
                    currentWeightEntry: log.weightEntry,
                    profile: _controller.profile,
                    onSaveWeight: (w) => _controller.setWeightEntry(w),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 3. Su Takip Modülü
              if (showNutrition) ...[
                StaggeredSlideFade(
                  index: 2,
                  child: WaterTrackerCard(
                    currentWaterMl: log.waterIntakeMl,
                    onAddWater: (ml) => _controller.addWater(ml),
                    onReset: () => _controller.resetWater(),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 4. Yürüyüş & Adım Takip Modülü
              if (showBody) ...[
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
              ],

              // 5. Kafein Takip Modülü (200 mg sınırı)
              if (showNutrition) ...[
                StaggeredSlideFade(
                  index: 4,
                  child: CaffeineTrackerCard(
                    currentCaffeineMg: log.caffeineMg,
                    onAddCaffeine: (mg) => _controller.addCaffeine(mg),
                    onReset: () => _controller.resetCaffeine(),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 6. Trimester Beslenme ve Kalori Rehberi
              if (showNutrition) ...[
                StaggeredSlideFade(
                  index: 5,
                  child: TrimesterNutritionCard(
                    currentWeek: _controller.currentWeek,
                    trimester: _controller.trimester,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Yasal & Tıbbi Sorumluluk Reddi Bildirimi
              const StaggeredSlideFade(
                index: 6,
                child: MedicalDisclaimerBanner(),
              ),
              const SizedBox(height: 84),
            ],
          ),
        ),
      ),
    );
  }
}

