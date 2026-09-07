import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/clay_theme.dart';
import '../../core/widgets/ambient_background.dart';
import '../../services/database_helper.dart';
import 'welcome_congratulation_screen.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  Future<void> _selectLanguage(BuildContext context, Locale locale) async {
    await context.setLocale(locale);
    try {
      await DatabaseHelper.instance.setSetting('has_selected_language', 'true');
      await DatabaseHelper.instance.setSetting('app_language', locale.languageCode);
    } catch (e) {
      debugPrint('LanguageSelection save error: $e');
    }
    if (!context.mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const WelcomeCongratulationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AmbientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: ClayTheme.clayDecoration(
                    color: AppColors.clayRose,
                    borderRadius: 44,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.language_rounded,
                      size: 48,
                      color: AppColors.primaryPink,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Choose Your Language\nDil Seçiminizi Yapın',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    height: 1.25,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 48),
                ClayLanguageButton(
                  title: 'English',
                  subtitle: 'US / UK',
                  icon: Icons.g_translate_rounded,
                  onTap: () => _selectLanguage(context, const Locale('en')),
                  color: AppColors.clayPeach,
                ),
                const SizedBox(height: 20),
                ClayLanguageButton(
                  title: 'Türkçe',
                  subtitle: 'Türkiye',
                  icon: Icons.translate_rounded,
                  onTap: () => _selectLanguage(context, const Locale('tr')),
                  color: AppColors.clayMint,
                ),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ClayLanguageButton extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const ClayLanguageButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  State<ClayLanguageButton> createState() => _ClayLanguageButtonState();
}

class _ClayLanguageButtonState extends State<ClayLanguageButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    HapticFeedback.lightImpact();
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 110),
          padding: const EdgeInsets.all(20),
          decoration: ClayTheme.clayButtonDecoration(
            color: widget.color,
            borderRadius: 28,
            isPressed: _isPressed,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, color: AppColors.primaryDark, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primaryDark,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
