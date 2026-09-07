import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/clay_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../controllers/onboarding_controller.dart';
import '../../utils/date_utils.dart';
import '../widgets/medical_disclaimer_sheet.dart';
import '../main_navigation_scaffold.dart';
import '../../services/database_helper.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onCompleted;

  const OnboardingScreen({super.key, this.onCompleted});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final OnboardingController _controller = OnboardingController();
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;

  final TextEditingController _momNameController = TextEditingController();
  final TextEditingController _babyNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerUpdated);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdated);
    _momNameController.dispose();
    _babyNameController.dispose();
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onControllerUpdated() {
    if (mounted) setState(() {});
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'onboarding_title'.tr(),
          style: GoogleFonts.outfit(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.primaryDark),
                onPressed: _prevPage,
              )
            : null,
      ),
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Claymorphic İlerleme Adımları (4 Adım)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: List.generate(_totalPages, (index) {
                    final isActive = index <= _currentPage;
                    return Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: isActive
                            ? ClayTheme.clayButtonDecoration(
                                color: AppColors.primaryPink,
                                borderRadius: 6,
                              )
                            : ClayTheme.concaveDecoration(
                                color: AppColors.backgroundSubtle,
                                borderRadius: 6,
                              ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  children: [
                    _buildDateSelectionStep(),
                    _buildBmiStep(),
                    _buildBabyAndMomInfoStep(),
                    _buildSummaryStep(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Adım 1: SAT veya Doğum Tarihi Seçimi
  Widget _buildDateSelectionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClayCard(
            color: AppColors.clayRose,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded,
                        color: AppColors.primaryPink, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'onboarding_step1_title'.tr(),
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'onboarding_step1_desc'.tr(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Seçim Modu Değiştirici (Concave Yuvalı Clay Switcher)
          Container(
            padding: const EdgeInsets.all(5),
            decoration: ClayTheme.concaveDecoration(
              color: AppColors.backgroundSubtle,
              borderRadius: 22,
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        _controller.setDateInputMode(DateInputMode.lmp),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: _controller.inputMode == DateInputMode.lmp
                          ? ClayTheme.clayButtonDecoration(
                              color: Colors.white,
                              borderRadius: 18,
                            )
                          : null,
                      child: Center(
                        child: Text(
                          'onboarding_step1_lmp'.tr(),
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight:
                                _controller.inputMode == DateInputMode.lmp
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                            fontSize: 13,
                            color: _controller.inputMode == DateInputMode.lmp
                                ? AppColors.primaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        _controller.setDateInputMode(DateInputMode.dueDate),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: _controller.inputMode == DateInputMode.dueDate
                          ? ClayTheme.clayButtonDecoration(
                              color: Colors.white,
                              borderRadius: 18,
                            )
                          : null,
                      child: Center(
                        child: Text(
                          'onboarding_step1_due_date'.tr(),
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight:
                                _controller.inputMode == DateInputMode.dueDate
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                            fontSize: 13,
                            color:
                                _controller.inputMode == DateInputMode.dueDate
                                    ? AppColors.primaryDark
                                    : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tarih Seçici Kartı
          ClayCard(
            color: AppColors.clayCardSurface,
            child: Column(
              children: [
                Text(
                  _controller.inputMode == DateInputMode.lmp
                      ? 'onboarding_step1_selected_lmp'.tr()
                      : 'onboarding_step1_selected_due_date'.tr(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppDateUtils.formatDisplay(
                      AppDateUtils.toIso(_controller.selectedDate),
                      locale: context.locale.languageCode),
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 14),
                ClayButton(
                  color: AppColors.clayPeach,
                  height: 44,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      locale: context.locale,
                      initialDate: _controller.selectedDate,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 300)),
                      lastDate: DateTime.now().add(const Duration(days: 300)),
                    );
                    if (picked != null) {
                      _controller.setSelectedDate(picked);
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_month_rounded,
                          color: AppColors.primaryDark, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'onboarding_step1_change_date'.tr(),
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Anlık Hesaplanan Hafta Göstergesi
          ClayCard(
            color: AppColors.clayMint,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'onboarding_step1_calc_preg'.tr(),
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'onboarding_step1_week'.tr(args: [
                        _controller.currentWeek.toString(),
                        _controller.trimester.toString()
                      ]),
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.successGreen,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: ClayTheme.clayButtonDecoration(
                    color: Colors.white,
                    borderRadius: 14,
                  ),
                  child: Text(
                    'onboarding_step1_days_left'.tr(args: [
                      AppDateUtils.daysUntil(
                              AppDateUtils.toIso(_controller.calculatedDueDate))
                          .toString()
                    ]),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          ClayButton(
            color: AppColors.clayRose,
            height: 52,
            onPressed: _nextPage,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'onboarding_continue'.tr(),
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_rounded,
                    color: AppColors.primaryDark, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Adım 2: Boy, Kilo ve VKİ Analizi
  Widget _buildBmiStep() {
    final guideline = _controller.weightGuideline;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClayCard(
            color: AppColors.clayPeach,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.monitor_weight_rounded,
                        color: AppColors.secondaryPeach, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'onboarding_step2_title'.tr(),
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.secondaryPeach,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'onboarding_step2_desc'.tr(),
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Boy Ayarlayıcı
          ClayCard(
            color: AppColors.clayCardSurface,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('onboarding_step2_height'.tr(),
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text(
                      '${_controller.heightCm.toInt()} cm',
                      style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark),
                    ),
                  ],
                ),
                Slider(
                  value: _controller.heightCm,
                  min: 140,
                  max: 200,
                  divisions: 60,
                  activeColor: AppColors.primaryPink,
                  inactiveColor: AppColors.backgroundSubtle,
                  onChanged: (val) => _controller.setHeight(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Kilo Ayarlayıcı
          ClayCard(
            color: AppColors.clayCardSurface,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('onboarding_step2_weight'.tr(),
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text(
                      '${_controller.prePregnancyWeightKg.toStringAsFixed(1)} kg',
                      style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.secondaryPeach),
                    ),
                  ],
                ),
                Slider(
                  value: _controller.prePregnancyWeightKg,
                  min: 40,
                  max: 140,
                  divisions: 200,
                  activeColor: AppColors.secondaryPeach,
                  inactiveColor: AppColors.backgroundSubtle,
                  onChanged: (val) => _controller.setWeight(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // VKİ ve IOM Hedef Kartı
          ClayCard(
            color: AppColors.claySky,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'onboarding_step2_bmi'.tr(args: [
                        _controller.vki.toStringAsFixed(1),
                        guideline['category_tr']
                      ]),
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.waterBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'onboarding_step2_ideal_weight'
                      .tr(args: [guideline['range']]),
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'onboarding_step2_weekly_desc'
                      .tr(args: [guideline['weekly_desc']]),
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          ClayButton(
            color: AppColors.clayRose,
            onPressed: _nextPage,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'onboarding_step2_next'.tr(),
                  style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_rounded,
                    color: AppColors.primaryDark, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Adım 3: Anne & Bebek İsmi ve Cinsiyet Bilgileri
  Widget _buildBabyAndMomInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClayCard(
            color: AppColors.clayLavender,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.child_care_rounded,
                        color: AppColors.primaryDark, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'onboarding_step3_title'.tr(),
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'onboarding_step3_desc'.tr(),
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 1. Anne İsmi
          ClayCard(
            color: AppColors.clayCardSurface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.face_rounded,
                        size: 16, color: AppColors.primaryPink),
                    const SizedBox(width: 6),
                    Text('onboarding_step3_mom_label'.tr(),
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark)),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _momNameController,
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  onChanged: (val) => _controller.setMomName(val),
                  decoration: InputDecoration(
                    hintText: 'onboarding_step3_mom_hint'.tr(),
                    hintStyle:
                        GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 13),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.clayOuterDrop.withValues(alpha: 0.15), width: 1)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.clayOuterDrop.withValues(alpha: 0.15), width: 1)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primaryPink, width: 1.5)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Bebeğin İsmi
          ClayCard(
            color: AppColors.clayCardSurface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.child_friendly_rounded,
                        size: 16, color: AppColors.primaryPink),
                    const SizedBox(width: 6),
                    Text('onboarding_step3_baby_label'.tr(),
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('onboarding_step3_baby_desc'.tr(),
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                TextField(
                  controller: _babyNameController,
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  onChanged: (val) => _controller.setBabyName(val),
                  decoration: InputDecoration(
                    hintText: 'onboarding_step3_baby_hint'.tr(),
                    hintStyle:
                        GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 13),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.clayOuterDrop.withValues(alpha: 0.15), width: 1)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppColors.clayOuterDrop.withValues(alpha: 0.15), width: 1)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primaryPink, width: 1.5)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3. Bebeğin Cinsiyeti
          ClayCard(
            color: AppColors.clayCardSurface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.stars_rounded,
                        size: 16, color: AppColors.secondaryPeach),
                    const SizedBox(width: 6),
                    Text('onboarding_step3_gender_label'.tr(),
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildGenderOption(
                        'onboarding_step3_gender_girl'.tr(),
                        'girl',
                        Icons.female_rounded,
                        AppColors.clayRose,
                        AppColors.primaryPink),
                    const SizedBox(width: 8),
                    _buildGenderOption(
                        'onboarding_step3_gender_boy'.tr(),
                        'boy',
                        Icons.male_rounded,
                        AppColors.claySky,
                        AppColors.waterBlue),
                    const SizedBox(width: 8),
                    _buildGenderOption(
                        'onboarding_step3_gender_surprise'.tr(),
                        'surprise',
                        Icons.help_outline_rounded,
                        AppColors.clayCream,
                        AppColors.accentGold),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          ClayButton(
            color: AppColors.clayRose,
            onPressed: _nextPage,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'onboarding_step3_next'.tr(),
                  style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_rounded,
                    color: AppColors.primaryDark, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String label, String value, IconData icon,
      Color bgColor, Color activeColor) {
    final isSelected = _controller.babyGender == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => _controller.setBabyGender(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: isSelected
              ? ClayTheme.clayButtonDecoration(
                  color: activeColor,
                  borderRadius: 16,
                )
              : ClayTheme.concaveDecoration(
                  color: bgColor.withValues(alpha: 0.7),
                  borderRadius: 16,
                ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: isSelected ? Colors.white : AppColors.textPrimary),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Adım 4: Özet ve SQLite Profil Kaydı
  Widget _buildSummaryStep() {
    final guideline = _controller.weightGuideline;
    final babyNameText = _controller.babyName.trim().isNotEmpty
        ? 'onboarding_step4_summary_baby_name_format'
            .tr(args: [_controller.babyName.trim()])
        : 'onboarding_step4_summary_baby_name_default'.tr();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClayCard(
            color: AppColors.clayLavender,
            child: Column(
              children: [
                const Icon(Icons.celebration_rounded,
                    size: 36, color: AppColors.primaryPink),
                const SizedBox(height: 8),
                Text(
                  'onboarding_step4_title'.tr(),
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'onboarding_step4_desc'.tr(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          ClayCard(
            color: AppColors.clayCardSurface,
            child: Column(
              children: [
                _buildSummaryRow(
                    'onboarding_step4_summary_baby_name_label'.tr(),
                    babyNameText),
                const Divider(height: 18),
                _buildSummaryRow(
                  'onboarding_step4_summary_gender_label'.tr(),
                  _controller.babyGender == 'girl'
                      ? 'onboarding_step3_gender_girl'.tr()
                      : _controller.babyGender == 'boy'
                          ? 'onboarding_step3_gender_boy'.tr()
                          : 'onboarding_step3_gender_surprise'.tr(),
                ),
                const Divider(height: 18),
                _buildSummaryRow(
                    'onboarding_step4_summary_week_label'.tr(),
                    'onboarding_step4_summary_week_val'
                        .tr(args: [_controller.currentWeek.toString()])),
                const Divider(height: 18),
                _buildSummaryRow(
                    'onboarding_step4_summary_due_date_label'.tr(),
                    AppDateUtils.formatDisplay(
                        AppDateUtils.toIso(_controller.calculatedDueDate))),
                const Divider(height: 18),
                _buildSummaryRow(
                    'onboarding_step4_summary_bmi_label'.tr(),
                    'onboarding_step4_summary_bmi_val'.tr(args: [
                      _controller.vki.toString(),
                      _controller.vkiCategoryKey
                    ])),
                const Divider(height: 18),
                _buildSummaryRow('onboarding_step4_summary_weight_label'.tr(),
                    '${guideline['range']}'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tıbbi & Yasal Sorumluluk Reddi Onay & Bilgilendirme Kutusu
          InkWell(
            onTap: () => MedicalDisclaimerSheet.show(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.clayLavender.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.primaryPink.withValues(alpha: 0.3),
                    width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_outlined,
                      size: 18, color: AppColors.primaryPink),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'onboarding_disclaimer_notice'.tr(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.35,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.info_outline_rounded,
                      size: 16, color: AppColors.primaryPink),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (_controller.errorMessage != null) ...[
            Text(
              _controller.errorMessage!,
              style: GoogleFonts.plusJakartaSans(
                  color: AppColors.medicalAlertRed,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
          ],

          ClayButton(
            color: AppColors.clayMint,
            height: 52,
            onPressed: _controller.isLoading ? null : _saveAndContinue,
            child: _controller.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: AppColors.successGreen),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.successGreen, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'onboarding_step4_save'.tr(),
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.successGreen,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAndContinue() async {
    final success = await _controller.saveProfileToDatabase();
    if (!mounted) return;

    if (success) {
      await DatabaseHelper.instance.setOnboardingCompleted(true);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('onboarding_success_toast'.tr()),
          backgroundColor: AppColors.successGreen,
          duration: const Duration(seconds: 2),
        ),
      );

      if (widget.onCompleted != null) {
        try {
          widget.onCompleted!();
        } catch (e) {
          debugPrint('onCompleted callback error: $e');
        }
      }

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigationScaffold()),
          (route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(_controller.errorMessage ?? 'onboarding_error_toast'.tr()),
          backgroundColor: AppColors.medicalAlertRed,
          action: SnackBarAction(
            label: 'onboarding_force_start'.tr(),
            textColor: Colors.white,
            onPressed: () async {
              await DatabaseHelper.instance.ensureDefaultProfile();
              await DatabaseHelper.instance.setOnboardingCompleted(true);
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (_) => const MainNavigationScaffold()),
                  (route) => false,
                );
              }
            },
          ),
        ),
      );
    }
  }

  Widget _buildSummaryRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
        Text(value,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary)),
      ],
    );
  }
}
