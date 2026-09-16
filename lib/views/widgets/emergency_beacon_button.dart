import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/clay_theme.dart';
import '../emergency/emergency_screen.dart';

/// Aura Pregnancy - Kalıcı Üst Başlık (AppBar) Dokunsal Acil Durum Güvenlik Rozeti
class EmergencyBeaconButton extends StatefulWidget {
  final VoidCallback? onTap;

  const EmergencyBeaconButton({super.key, this.onTap});

  @override
  State<EmergencyBeaconButton> createState() => _EmergencyBeaconButtonState();
}

class _EmergencyBeaconButtonState extends State<EmergencyBeaconButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const ValueKey('appbar_emergency_beacon'),
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.mediumImpact();
        if (widget.onTap != null) {
          widget.onTap!();
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
      child: AnimatedScale(
        scale: _isPressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: ClayTheme.clayButtonDecoration(
            color: AppColors.medicalAlertBg,
            borderRadius: 16,
            isPressed: _isPressed,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeTransition(
                opacity: Tween<double>(begin: 0.6, end: 1.0).animate(_pulseController),
                child: const Icon(
                  Icons.emergency_rounded,
                  color: AppColors.medicalAlertRed,
                  size: 14,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'ACİL',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.medicalAlertRed,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
