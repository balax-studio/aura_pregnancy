import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/clay_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../services/database_helper.dart';
import '../onboarding/onboarding_screen.dart';
import '../main_navigation_scaffold.dart';

/// Aura Pregnancy - Detaylı ve Açıklayıcı Uygulama Rehberi & Yönlendiriciler
class AppGuideScreen extends StatefulWidget {
  final VoidCallback? onCompleteGuide;

  const AppGuideScreen({super.key, this.onCompleteGuide});

  @override
  State<AppGuideScreen> createState() => _AppGuideScreenState();
}

class _AppGuideScreenState extends State<AppGuideScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  List<Map<String, dynamic>> get _guideSteps => [
    {
      'icon': Icons.calendar_month_rounded,
      'color': AppColors.clayRose,
      'title': 'guide_step1_title'.tr(),
      'subtitle': 'guide_step1_subtitle'.tr(),
      'description': 'guide_step1_desc'.tr(),
      'highlights': [
        'guide_step1_hl1'.tr(),
        'guide_step1_hl2'.tr(),
        'guide_step1_hl3'.tr(),
      ],
    },
    {
      'icon': Icons.medical_services_rounded,
      'color': AppColors.claySky,
      'title': 'guide_step2_title'.tr(),
      'subtitle': 'guide_step2_subtitle'.tr(),
      'description': 'guide_step2_desc'.tr(),
      'highlights': [
        'guide_step2_hl1'.tr(),
        'guide_step2_hl2'.tr(),
        'guide_step2_hl3'.tr(),
        'guide_step2_hl4'.tr(),
      ],
    },
    {
      'icon': Icons.water_drop_rounded,
      'color': AppColors.clayPeach,
      'title': 'guide_step3_title'.tr(),
      'subtitle': 'guide_step3_subtitle'.tr(),
      'description': 'guide_step3_desc'.tr(),
      'highlights': [
        'guide_step3_hl1'.tr(),
        'guide_step3_hl2'.tr(),
        'guide_step3_hl3'.tr(),
      ],
    },
    {
      'icon': Icons.menu_book_rounded,
      'color': AppColors.clayLavender,
      'title': 'guide_step4_title'.tr(),
      'subtitle': 'guide_step4_subtitle'.tr(),
      'description': 'guide_step4_desc'.tr(),
      'highlights': [
        'guide_step4_hl1'.tr(),
        'guide_step4_hl2'.tr(),
        'guide_step4_hl3'.tr(),
      ],
    },
    {
      'icon': Icons.emergency_rounded,
      'color': AppColors.medicalAlertBg,
      'title': 'guide_step5_title'.tr(),
      'subtitle': 'guide_step5_subtitle'.tr(),
      'description': 'guide_step5_desc'.tr(),
      'highlights': [
        'guide_step5_hl1'.tr(),
        'guide_step5_hl2'.tr(),
        'guide_step5_hl3'.tr(),
      ],
    },
  ];


  void _nextStep() {
    if (_currentStep < _guideSteps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    } else {
      _finishGuide(goToOnboarding: true);
    }
  }

  Future<void> _finishGuide({bool goToOnboarding = true}) async {
    try {
      await DatabaseHelper.instance.setSetting('has_seen_guide', 'true');
    } catch (e) {
      debugPrint('Guide setting save error: $e');
    }

    if (widget.onCompleteGuide != null) {
      widget.onCompleteGuide!();
      return;
    }

    if (goToOnboarding) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
        ),
      );
    } else {
      await DatabaseHelper.instance.ensureDefaultProfile();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const MainNavigationScaffold(),
        ),
        (route) => false,
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
          'guide_app_title'.tr(),
          style: GoogleFonts.outfit(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            child: ClayButton(
              onPressed: _finishGuide,
              color: AppColors.clayRose,
              height: 36,
              borderRadius: 14,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'guide_skip'.tr(),
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.primaryPink,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded, color: AppColors.primaryPink, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
      body: AmbientBackground(
        child: SafeArea(
        child: Column(
          children: [
            // İlerleme Çubukları
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: List.generate(_guideSteps.length, (index) {
                  final isActive = index <= _currentStep;
                  return Expanded(
                    child: Container(
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primaryPink : AppColors.backgroundSubtle,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentStep = idx),
                itemCount: _guideSteps.length,
                itemBuilder: (context, index) {
                  final step = _guideSteps[index];
                  final highlights = step['highlights'] as List<String>;
                  final stepIcon = step['icon'] as IconData;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // İkon & Başlık Kartı
                        ClayCard(
                          color: step['color'] as Color,
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: ClayTheme.clayDecoration(
                                      color: Colors.white,
                                      borderRadius: 16,
                                    ),
                                    child: Center(
                                      child: Icon(stepIcon, color: AppColors.primaryDark, size: 24),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          step['title'] as String,
                                          style: GoogleFonts.outfit(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primaryDark,
                                          ),
                                        ),
                                        Text(
                                          step['subtitle'] as String,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.secondaryPeach,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                step['description'] as String,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Öne Çıkan Yönlendirici Maddeler
                        ClayCard(
                          color: AppColors.clayCardSurface,
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.stars_rounded, color: AppColors.accentGold, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'guide_highlights_title'.tr(),
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ...highlights.map((h) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.successGreen),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            h,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                              height: 1.35,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Alt İlerleme ve Başlama Butonu
            Padding(
              padding: const EdgeInsets.all(24),
              child: ClayButton(
                color: _currentStep == _guideSteps.length - 1 ? AppColors.clayMint : AppColors.clayRose,
                height: 56,
                onPressed: _nextStep,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentStep == _guideSteps.length - 1 ? 'guide_button_start'.tr() : 'guide_button_next'.tr(),
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _currentStep == _guideSteps.length - 1 ? AppColors.successGreen : AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: _currentStep == _guideSteps.length - 1 ? AppColors.successGreen : AppColors.primaryDark,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
