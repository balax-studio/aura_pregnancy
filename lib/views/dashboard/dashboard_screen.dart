import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/clay_theme.dart';
import '../../core/constants/weekly_medical_data.dart';
import '../../services/database_helper.dart';
import '../../services/medical_calculator.dart';
import '../widgets/medical_disclaimer_sheet.dart';
import '../../models/profile_model.dart';
import '../../models/daily_log_model.dart';
import '../../utils/date_utils.dart';
import 'widgets/profile_edit_sheet.dart';
import 'widgets/interactive_3d_fetus_widget.dart';
import 'screens/womb_ambience_screen.dart';
import 'widgets/lockscreen_capsule_preview.dart';
import '../../core/widgets/fruit_3d_widget.dart';
import '../../core/widgets/micro_animations.dart';
import '../widgets/emergency_beacon_button.dart';

/// Aura Pregnancy - Awwwards x Claymorphic Sade, Ferah & Romantik Ana Sayfa (Dashboard)
class DashboardScreen extends StatefulWidget {
  final Function(int) onNavigateTab;

  const DashboardScreen({super.key, required this.onNavigateTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ProfileModel? _profile;
  DailyLogModel? _todayLog;
  int _medsTotal = 0;
  int _medsTaken = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    DatabaseHelper.appDataRevision.addListener(_onAppDataChanged);
  }

  void _onAppDataChanged() {
    if (mounted) {
      _loadDashboardData();
    }
  }

  @override
  void dispose() {
    DatabaseHelper.appDataRevision.removeListener(_onAppDataChanged);
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      _profile = await DatabaseHelper.instance.getProfile();
      final today = AppDateUtils.todayIso();
      _todayLog = await DatabaseHelper.instance.getOrCreateDailyLog(today);
      final meds = await DatabaseHelper.instance.getMedications();
      _medsTotal = meds.length;
      _medsTaken = meds.where((m) => m.isTakenOnDate(today)).length;
    } catch (e) {
      debugPrint('Dashboard load error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openProfileEditor() {
    if (_profile == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ProfileEditSheet(
        profile: _profile!,
        onSaved: _loadDashboardData,
      ),
    );
  }

  void _triggerHeartbeatHaptic() {
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 90), () {
      HapticFeedback.lightImpact();
    });
    Future.delayed(const Duration(milliseconds: 440), () {
      HapticFeedback.mediumImpact();
      Future.delayed(const Duration(milliseconds: 90), () {
        HapticFeedback.lightImpact();
      });
    });
  }

  Future<void> _quickAddWater() async {
    HapticFeedback.lightImpact();
    final today = AppDateUtils.todayIso();
    final current = _todayLog ?? await DatabaseHelper.instance.getOrCreateDailyLog(today);
    final updated = current.copyWith(waterIntakeMl: current.waterIntakeMl + 250);
    setState(() {
      _todayLog = updated;
    });
    await DatabaseHelper.instance.updateDailyLog(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('+250 ml su kaydedildi (${((updated.waterIntakeMl) / 250).floor()}/8 bardak)'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _quickToggleMedications() async {
    HapticFeedback.lightImpact();
    final today = AppDateUtils.todayIso();
    final meds = await DatabaseHelper.instance.getMedications();
    if (meds.isEmpty) {
      widget.onNavigateTab(2);
      return;
    }
    final untaken = meds.where((m) => !m.isTakenOnDate(today)).toList();
    if (untaken.isNotEmpty) {
      final targetMed = untaken.first;
      await DatabaseHelper.instance.toggleMedicationTaken(targetMed.id!, today, true);
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${targetMed.name} alındı olarak işaretlendi.'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tüm günlük vitamin ve ilaçlarınız tamamlandı!'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryPink)),
      );
    }

    final currentWeek = _profile?.currentWeek ?? 12;
    final dueDateStr = _profile?.dueDate ?? '2026-10-15';
    final daysRemaining = AppDateUtils.daysUntil(dueDateStr);
    final weeksRemaining = daysRemaining > 0
        ? ((daysRemaining + 6) ~/ 7).clamp(0, 40)
        : (40 - currentWeek).clamp(0, 40);
    final babyName = _profile?.babyDisplayName ?? 'Bebeğiniz';
    final momName = _profile?.momName ?? 'Anne Adayı';

    // Detaylı Yaş Hesaplama (Kaçıncı haftanın kaçıncı gününde)
    DateTime lmpDate;
    if (_profile?.lmpDate != null && _profile!.lmpDate!.isNotEmpty) {
      lmpDate = DateTime.tryParse(_profile!.lmpDate!) ?? DateTime.now().subtract(Duration(days: (currentWeek - 1) * 7));
    } else {
      lmpDate = DateTime.now().subtract(Duration(days: (currentWeek - 1) * 7));
    }
    final detailedAge = MedicalCalculator.getDetailedPregnancyAge(lmpDate);
    final weekNumber = (detailedAge['weeks'] ?? currentWeek).clamp(1, 40);
    final dayNumber = (detailedAge['days'] ?? 0) + 1; // 1-7. Gün
    final trimester = MedicalCalculator.getTrimester(weekNumber);

    // Hafta verisi ve meyve adı gösterilen weekNumber ile %100 senkronize
    final weekData = WeeklyMedicalData.getInfoForWeek(weekNumber);
    final fruitName = weekData['fruit_name'] as String? ?? 'Gelişim';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite_rounded, color: AppColors.primaryPink, size: 16),
                const SizedBox(width: 6),
                Text(
                  'dashboard_welcome'.tr(args: [momName]),
                  style: GoogleFonts.outfit(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            Text(
              AppDateUtils.formatToday(),
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
        actions: [
          const MedicalInfoButton(),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'dashboard_profile_settings'.tr(),
            icon: const Icon(Icons.settings_suggest_rounded, color: AppColors.primaryDark),
            onPressed: _openProfileEditor,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: EmergencyBeaconButton(
              onTap: () => widget.onNavigateTab(5), // Acil Durum ekranı (Index 5)
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          color: AppColors.primaryPink,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. 360° İNTERAKTİF 3D FETUS & CANLI ANİMASYON HEYKELSİ SAHNE
                StaggeredSlideFade(
                  index: 0,
                  child: ClayCard(
                    color: AppColors.clayCardSurface,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    onTap: () {
                      _triggerHeartbeatHaptic();
                      widget.onNavigateTab(1); // Haftalık Detay sekmesine
                    },
                    child: Column(
                      children: [
                        // Üst Trimester ve Doğuma Kalan Rozetleri
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.lavenderPurple.withValues(alpha: 0.25),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'dashboard_trimester'.tr(args: [trimester.toString()]),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.lavenderPurple,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.primaryPink.withValues(alpha: 0.25),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.hourglass_top_rounded, size: 13, color: AppColors.primaryDark),
                                  const SizedBox(width: 5),
                                  Text(
                                    'dashboard_weeks_left'.tr(args: [weeksRemaining.toString()]),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 360° İnteraktif 3D Fetus Modeli
                        Interactive3DFetusWidget(
                          currentWeek: weekNumber,
                          currentDay: dayNumber,
                          babyName: babyName,
                          eddDate: dueDateStr,
                          onTap: () {
                            _triggerHeartbeatHaptic();
                            widget.onNavigateTab(1); // Haftalık Detay sekmesine
                          },
                        ),
                        const SizedBox(height: 16),

                        // Hafta ve Gün Başlığı
                        Text(
                          'dashboard_week_day'.tr(args: [weekNumber.toString(), dayNumber.toString()]),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Bebeğin Meyve Büyüklüğü
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: AppColors.secondaryPeach.withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Fruit3DWidget(
                                week: weekNumber,
                                size: 34,
                                borderRadius: 10,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'dashboard_fruit_size'.tr(args: [fruitName]),
                                  style: GoogleFonts.outfit(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Boy & Kilo Detayı
                        Text(
                          'dashboard_measurements'.tr(args: [
                            weekData['length']?.toString() ?? '~30.0 cm',
                            weekData['weight']?.toString() ?? '~600 gr',
                          ]),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Aura İnovatif Kapsüller: Sakinleşme Çanı & Kilit Ekranı
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Sakinleşme Çanı
                            InkWell(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                WombAmbienceScreen.open(context);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: AppColors.clayLavender,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white, width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('🔔', style: TextStyle(fontSize: 14)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'dashboard_womb_bell'.tr(),
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Canlı Kilit Ekranı
                            InkWell(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                LockscreenCapsulePreview.show(context, profile: _profile);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: AppColors.clayMint,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white, width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('📱', style: TextStyle(fontSize: 14)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'dashboard_lock_screen'.tr(),
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryDark,
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
                  ),
                ),
                const SizedBox(height: 16),

                // 2. BUGÜNÜN CANLILIK NABZI (Daily Pulse Hub)
                StaggeredSlideFade(
                  index: 1,
                  child: ClayCard(
                    isGlazed: true,
                    color: AppColors.clayCardSurface,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    onTap: () => widget.onNavigateTab(2), // Günlük Takip Sekmesine
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryPink.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.favorite_rounded, color: AppColors.primaryPink, size: 14),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'dashboard_daily_pulse'.tr(),
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'dashboard_view_daily_routines'.tr(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryPink,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.primaryPink),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // 3 Yatay Canlılık Kapsülü (Doğrudan Hızlı Kayıt & Etkileşim)
                        Row(
                          children: [
                            // Su Kapsülü (Doğrudan +250ml dokunmatik ekleme)
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _quickAddWater,
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.claySky,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.water_drop_rounded, color: AppColors.waterBlue, size: 16),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'dashboard_pulse_water'.tr(),
                                                style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                              ),
                                              Text(
                                                '${((_todayLog?.waterIntakeMl ?? 0) / 250).floor()}/8',
                                                style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            color: AppColors.waterBlue.withValues(alpha: 0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.add_rounded, size: 13, color: AppColors.waterBlue),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // İlaç / Vitamin Kapsülü (Hızlı Alındı İşareti)
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _quickToggleMedications,
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.clayLavender,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.medication_rounded, color: AppColors.lavenderPurple, size: 16),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'dashboard_pulse_vitamin'.tr(),
                                                style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                              ),
                                              Text(
                                                _medsTotal > 0 ? '$_medsTaken/$_medsTotal' : 'dashboard_pulse_add'.tr(),
                                                style: GoogleFonts.outfit(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w800,
                                                  color: (_medsTotal > 0 && _medsTaken == _medsTotal) ? AppColors.successGreen : AppColors.primaryDark,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            color: (_medsTotal > 0 && _medsTaken == _medsTotal)
                                                ? AppColors.successGreen.withValues(alpha: 0.18)
                                                : AppColors.lavenderPurple.withValues(alpha: 0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            (_medsTotal > 0 && _medsTaken == _medsTotal) ? Icons.check_rounded : Icons.check_circle_outline_rounded,
                                            size: 13,
                                            color: (_medsTotal > 0 && _medsTaken == _medsTotal) ? AppColors.successGreen : AppColors.lavenderPurple,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Adım Kapsülü (Günlük Takip Detayına Açılır)
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => widget.onNavigateTab(2),
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.clayRose,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.directions_walk_rounded, color: AppColors.secondaryPeach, size: 16),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'dashboard_pulse_steps'.tr(),
                                                style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                              ),
                                              Text(
                                                '${_todayLog?.stepCount ?? 0}',
                                                style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.textMuted),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const SizedBox(height: 16),
                const StaggeredSlideFade(
                  index: 2,
                  child: MedicalDisclaimerBanner(),
                ),
                const SizedBox(height: 84),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

