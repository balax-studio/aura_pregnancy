import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/clay_theme.dart';
import '../emergency/emergency_screen.dart';

/// Aura Pregnancy - Kalıcı Üst Başlık (AppBar) Acil Durum Güvenlik Rozeti
class EmergencyBeaconButton extends StatelessWidget {
  final VoidCallback? onTap;

  const EmergencyBeaconButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const ValueKey('appbar_emergency_beacon'),
      onTap: () {
        HapticFeedback.mediumImpact();
        if (onTap != null) {
          onTap!();
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => Scaffold(
                backgroundColor: AppColors.background,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryDark),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                body: const SafeArea(child: EmergencyScreen()),
              ),
            ),
          );
        }
      },
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
              'ACİL',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.medicalAlertRed,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
