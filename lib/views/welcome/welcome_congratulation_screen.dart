import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/clay_theme.dart';
import '../../core/widgets/ambient_background.dart';
import 'package:easy_localization/easy_localization.dart';
import 'app_guide_screen.dart';

/// Aura Pregnancy - Hoş Geldiniz ve Tebrikler Ekranı
class WelcomeCongratulationScreen extends StatelessWidget {
  final VoidCallback? onNext;

  const WelcomeCongratulationScreen({super.key, this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AmbientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 10),

                // Üst Karşılama ve Tebrik Kartı
                Column(
                  children: [
                    // 3D Claymorphic Kalp & Anne/Bebek Aura Logosu
                    Container(
                      width: 110,
                      height: 110,
                      decoration: ClayTheme.clayDecoration(
                        color: AppColors.clayRose,
                        borderRadius: 55,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(55),
                        child: Image.asset(
                          'assets/images/aura_logo.png',
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.favorite_rounded, color: AppColors.primaryPink, size: 48),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tebrik Başlığı
                    Text(
                      'welcome_title'.tr(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Text(
                      'welcome_subtitle'.tr(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondaryPeach,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Duygusal & Güven Veren Mesaj Kartı
                    ClayCard(
                      color: AppColors.clayCardSurface,
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        children: [
                          Text(
                            'welcome_desc'.tr(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.favorite_border_rounded, size: 16, color: AppColors.primaryPink),
                              const SizedBox(width: 4),
                              Text(
                                'welcome_feature1'.tr(),
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryPink,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(Icons.medical_services_outlined, size: 16, color: AppColors.waterBlue),
                              const SizedBox(width: 4),
                              Text(
                                'welcome_feature2'.tr(),
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.waterBlue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Alt Butonlar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClayButton(
                      color: AppColors.clayRose,
                      height: 56,
                      onPressed: () {
                        if (onNext != null) {
                          onNext!();
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => const AppGuideScreen(),
                            ),
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'welcome_button'.tr(),
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, color: AppColors.primaryDark, size: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
