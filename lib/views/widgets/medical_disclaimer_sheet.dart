import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/clay_theme.dart';

/// Aura Pregnancy - Tıbbi Sorumluluk Reddi ve Yasal Bilgilendirme Modalı (Liquid Glass & Glazed Ceramic)
class MedicalDisclaimerSheet extends StatelessWidget {
  const MedicalDisclaimerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const MedicalDisclaimerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: ClayTheme.glazedGlassDecoration(
              surfaceColor: AppColors.background,
              borderRadius: 32,
              opacity: 0.92,
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tutamaç Çizgisi
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: ClayTheme.concaveDecoration(
                color: Colors.black.withValues(alpha: 0.12),
                borderRadius: 10,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Başlık Rozeti
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.clayMint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(Icons.verified_user_rounded, color: AppColors.successGreen, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'legal_disclaimer_title'.tr(),
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    Text(
                      'legal_disclaimer_badge'.tr(),
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Maddeler Kaydırılabilir Liste
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildLegalItem(
                    icon: Icons.medical_services_outlined,
                    iconColor: AppColors.primaryPink,
                    bgColor: AppColors.clayRose,
                    title: 'legal_item_1_title'.tr(),
                    desc: 'legal_item_1_desc'.tr(),
                  ),
                  const SizedBox(height: 10),
                  _buildLegalItem(
                    icon: Icons.local_hospital_outlined,
                    iconColor: AppColors.waterBlue,
                    bgColor: AppColors.claySky,
                    title: 'legal_item_2_title'.tr(),
                    desc: 'legal_item_2_desc'.tr(),
                  ),
                  const SizedBox(height: 10),
                  _buildLegalItem(
                    icon: Icons.emergency_outlined,
                    iconColor: AppColors.medicalAlertRed,
                    bgColor: AppColors.clayPeach,
                    title: 'legal_item_3_title'.tr(),
                    desc: 'legal_item_3_desc'.tr(),
                  ),
                  const SizedBox(height: 10),
                  _buildLegalItem(
                    icon: Icons.lock_outline_rounded,
                    iconColor: AppColors.successGreen,
                    bgColor: AppColors.clayMint,
                    title: 'legal_item_4_title'.tr(),
                    desc: 'legal_item_4_desc'.tr(),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Gizlilik Politikası Butonu & Anladım Kapat Butonu
          Row(
            children: [
              Expanded(
                child: ClayButton(
                  color: AppColors.claySky,
                  height: 48,
                  borderRadius: 16,
                  onPressed: () async {
                    final uri = Uri.parse('https://docs.google.com/document/d/e/2PACX-1vS6uFWNKKhE-D5MateR98z1d6ytQNssL6iSWYryOd-Uy2UcAewmrHo6YvSHG0YRmz3CNmWtCxdkn-l_/pub');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.privacy_tip_outlined, color: AppColors.primaryDark, size: 16),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'legal_privacy_policy_btn'.tr(),
                          style: GoogleFonts.nunito(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ClayButton(
                  color: AppColors.clayMint,
                  height: 48,
                  borderRadius: 16,
                  onPressed: () => Navigator.pop(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, color: AppColors.successGreen, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'legal_disclaimer_understood'.tr(),
                        style: GoogleFonts.nunito(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.successGreen,
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
),
);
}

  Widget _buildLegalItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String desc,
  }) {
    return ClayCard(
      color: bgColor,
      borderRadius: 18,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dokunulduğunda Yasal Bilgilendirme Modalını Açan Mikro Bilgi Butonu
class MedicalInfoButton extends StatelessWidget {
  final double size;
  final Color? color;

  const MedicalInfoButton({
    super.key,
    this.size = 32.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => MedicalDisclaimerSheet.show(context),
      child: Container(
        width: size,
        height: size,
        decoration: ClayTheme.clayDecoration(
          color: color ?? AppColors.clayMint,
          borderRadius: size / 2,
        ),
        child: Center(
          child: Icon(
            Icons.shield_outlined,
            size: size * 0.52,
            color: AppColors.successGreen,
          ),
        ),
      ),
    );
  }
}

/// Tüm Ekranlarda Kullanılabilen Dokunulabilir Tıbbi Sorumluluk Reddi Bandı
class MedicalDisclaimerBanner extends StatelessWidget {
  final String? customText;

  const MedicalDisclaimerBanner({super.key, this.customText});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => MedicalDisclaimerSheet.show(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: ClayTheme.clayDecoration(
          color: AppColors.clayCardSurface,
          borderRadius: 16,
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.primaryPink, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                customText ?? 'disclaimer_weekly'.tr(),
                style: GoogleFonts.quicksand(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 11),
          ],
        ),
      ),
    );
  }
}
