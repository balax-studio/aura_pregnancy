import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/clay_theme.dart';
import '../../core/constants/weekly_medical_data.dart';
import '../../core/constants/medical_specs.dart';
import '../../services/database_helper.dart';
import '../../services/medical_calculator.dart';
import '../widgets/medical_disclaimer_sheet.dart';
import '../../models/profile_model.dart';
import '../../utils/date_utils.dart';
import 'widgets/profile_edit_sheet.dart';
import 'widgets/interactive_3d_fetus_widget.dart';
import '../../core/widgets/fruit_3d_widget.dart';
import '../../core/widgets/micro_animations.dart';
import '../baby_names/baby_names_screen.dart';

/// Aura Pregnancy - Sade, Ferah & Romantik Ana Sayfa (Dashboard)
class DashboardScreen extends StatefulWidget {
  final Function(int) onNavigateTab;

  const DashboardScreen({super.key, required this.onNavigateTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ProfileModel? _profile;

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
      await DatabaseHelper.instance.getOrCreateDailyLog(today);
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
    HapticFeedback.lightImpact();
    Future.delayed(const Duration(milliseconds: 120), () {
      HapticFeedback.lightImpact();
    });
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
    final weekData = WeeklyMedicalData.getInfoForWeek(currentWeek);
    final babyName = _profile?.babyDisplayName ?? 'Bebeğiniz';
    final momName = _profile?.momName ?? 'Anne Adayı';

    final fruitName = weekData['fruit_name'] as String? ?? 'Gelişim';

    // Detaylı Yaş Hesaplama (Kaçıncı haftanın kaçıncı gününde)
    DateTime lmpDate;
    if (_profile?.lmpDate != null && _profile!.lmpDate!.isNotEmpty) {
      lmpDate = DateTime.tryParse(_profile!.lmpDate!) ?? DateTime.now().subtract(Duration(days: (currentWeek - 1) * 7));
    } else {
      lmpDate = DateTime.now().subtract(Duration(days: (currentWeek - 1) * 7));
    }
    final detailedAge = MedicalCalculator.getDetailedPregnancyAge(lmpDate);
    final weekNumber = detailedAge['weeks'] ?? currentWeek;
    final dayNumber = (detailedAge['days'] ?? 0) + 1; // 1-7. Gün
    final trimester = MedicalCalculator.getTrimester(weekNumber);

    // Bu Haftanın Tıbbi Testi Var mı? (Yoksa alan tamamen gizlenir)
    final medicalMilestone = PregnancyMedicalSpecs.medicalMilestones[weekNumber];

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
            child: GestureDetector(
              onTap: () => widget.onNavigateTab(5), // Acil Durum sekmesi
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: ClayTheme.clayButtonDecoration(
                  color: AppColors.medicalAlertBg,
                  borderRadius: 16,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emergency_rounded, color: AppColors.medicalAlertRed, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'dashboard_emergency'.tr(),
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.medicalAlertRed,
                      ),
                    ),
                  ],
                ),
              ),
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
                // 1. 360° İNTERAKTİF 3D FETUS & CANLI ANİMASYON KARTI
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
                                decoration: ClayTheme.clayButtonDecoration(
                                  color: AppColors.clayLavender,
                                  borderRadius: 14,
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
                                decoration: ClayTheme.clayButtonDecoration(
                                  color: AppColors.clayRose,
                                  borderRadius: 14,
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
                          ),
                          const SizedBox(height: 18),

                          // Kaçıncı Haftanın Kaçıncı Gününde Başlığı
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

                          // Bebeğin Meyve Büyüklüğü (Güncellenen Format)
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: ClayTheme.clayButtonDecoration(
                              color: AppColors.clayPeach,
                              borderRadius: 18,
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
                            'dashboard_measurements'.tr(args: [weekData['length']?.toString() ?? '~30.0 cm', weekData['weight']?.toString() ?? '~600 gr']),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ),
                const SizedBox(height: 16),

                // 2. HAFTANIN YAPILMASI GEREKEN TIBBİ TESTİ / KONTROLÜ (VARSA GÖSTER, YOKSA GİZLE)
                if (medicalMilestone != null) ...[
                  StaggeredSlideFade(
                    index: 1,
                    child: ClayCard(
                      isGlazed: true,
                      color: const Color(0xFFFFF3E0), // Sıcak uyarı turuncusu
                      padding: const EdgeInsets.all(16),
                      onTap: () => widget.onNavigateTab(1),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: ClayTheme.clayDecoration(
                              color: Colors.white,
                              borderRadius: 14,
                            ),
                            child: const Center(
                              child: Icon(Icons.medical_services_rounded, color: Color(0xFFE65100), size: 22),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: ClayTheme.clayButtonDecoration(
                                        color: const Color(0xFFE65100),
                                        borderRadius: 8,
                                      ),
                                      child: Text(
                                        'dashboard_medical_test_title'.tr(),
                                        style: GoogleFonts.plusJakartaSans(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  medicalMilestone['test'] ?? '',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF5D4037),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  medicalMilestone['desc'] ?? '',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF795548),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFE65100)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 3. HAMİLELİĞİN BU GÜNÜ & DİNGİN GÜNLÜK ÖZET KARTI (Liquid Glass Katmanı)
                StaggeredSlideFade(
                  index: 2,
                  child: ClayCard(
                    isGlazed: true,
                    color: AppColors.clayRose,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome_rounded, color: AppColors.primaryPink, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'dashboard_today_title'.tr(),
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          weekData['summary'] as String? ??
                              'dashboard_today_desc_default'.tr(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ClayButton(
                              color: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              onPressed: () => widget.onNavigateTab(2), // Günlük Takip Sekmesine
                              child: Row(
                                children: [
                                  Text(
                                    'dashboard_view_daily_routines'.tr(),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryPink,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primaryPink),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 4. BEBEK İSİM ÖNERİLERİ & ANLAMLARI KEŞİF KARTI
                StaggeredSlideFade(
                  index: 3,
                  child: ClayCard(
                    isGlazed: true,
                    color: AppColors.clayMint,
                    padding: const EdgeInsets.all(18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BabyNamesScreen()),
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: ClayTheme.clayDecoration(
                            color: Colors.white,
                            borderRadius: 16,
                          ),
                          child: const Center(
                            child: Icon(Icons.stars_rounded, color: Color(0xFF2E6135), size: 28),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'dashboard_baby_names_title'.tr(),
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF1E4624),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'dashboard_baby_names_sub'.tr(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF3B6B43),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.7),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF2E6135), size: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                const StaggeredSlideFade(
                  index: 4,
                  child: MedicalDisclaimerBanner(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
