import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/clay_theme.dart';

/// Aura Pregnancy - Pre-ATT (App Tracking Transparency) Bilgilendirme Modalı
/// Apple yönergelerine uygun şekilde kullanıcıya iznin faydasını ve güvenliğini aktarır.
class PreAttConsentDialog extends StatelessWidget {
  const PreAttConsentDialog({super.key});

  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const PreAttConsentDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: ClayTheme.clayDecoration(
          color: AppColors.clayCardSurface,
          borderRadius: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // İkon & Rozet
            Center(
              child: Container(
                width: 68,
                height: 68,
                decoration: ClayTheme.clayDecoration(
                  color: AppColors.clayRose,
                  borderRadius: 24,
                ),
                child: const Center(
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.secondaryPeach,
                    size: 34,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Başlık
            Text(
              'pre_att_title'.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryDark,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 10),

            // Açıklama Metni
            Text(
              'pre_att_desc'.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),

            // Avantaj Maddeleri
            _buildFeatureItem(
              icon: Icons.favorite_rounded,
              iconColor: AppColors.primaryPink,
              text: 'pre_att_feature_1'.tr(),
            ),
            const SizedBox(height: 8),
            _buildFeatureItem(
              icon: Icons.verified_user_rounded,
              iconColor: const Color(0xFF2E6135),
              text: 'pre_att_feature_2'.tr(),
            ),
            const SizedBox(height: 22),

            // Devam Et Butonu
            ClayButton(
              color: AppColors.clayPeach,
              height: 52,
              borderRadius: 16,
              onPressed: () => Navigator.pop(context, true),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.primaryDark,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'pre_att_btn_continue'.tr(),
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Şimdilik Geç Butonu
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'pre_att_btn_skip'.tr(),
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF7A6E78),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
