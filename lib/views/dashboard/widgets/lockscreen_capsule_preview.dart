import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/profile_model.dart';

/// Aura Pregnancy - Canlı Kilit Ekranı Fetus Kapsülü (Lockscreen Activity Preview)
class LockscreenCapsulePreview extends StatelessWidget {
  final ProfileModel? profile;

  const LockscreenCapsulePreview({super.key, this.profile});

  static Future<void> show(BuildContext context, {ProfileModel? profile}) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.clayPeach,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text('📱', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 10),
            Text(
              'Canlı Kilit Ekranı',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.primaryDark, fontSize: 18),
            ),
          ],
        ),
        content: LockscreenCapsulePreview(profile: profile),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Kapat', style: GoogleFonts.outfit(color: AppColors.primaryPink, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final week = profile?.currentWeek ?? 24;
    final babyName = profile?.babyDisplayName ?? 'Bebeğiniz';

    int daysRemaining = 280 - (week * 7);
    if (daysRemaining < 0) daysRemaining = 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Telefonunuz kilitliyken bile bebeğinizin nefes alışını ve günün mesajını kilit ekranında canlı takip edin:',
          style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),

        // Kilit Ekranı Widget Simülasyonu (Dynamic Island Kapsülü)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E24), // Dark Dynamic Island Mockup
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPink.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(child: Text('👶', style: TextStyle(fontSize: 20))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$babyName • $week. Hafta',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Kavuşmaya $daysRemaining Gün Kaldı 💕',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppColors.secondaryPeach,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.favorite_rounded, color: AppColors.primaryPink, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '💬 "Anneciğim bugün minik parmaklarımı emebiliyorum, sesini her duyduğumda çok mutlu oluyorum!"',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 11.5,
                    fontStyle: FontStyle.italic,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Canlı Kilit Ekranı ve Dynamic Island bildirimleri aktifleştirildi.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.successGreen,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
