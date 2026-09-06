import 'dart:ui';
import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'inset_box_shadow.dart';
import '../constants/app_colors.dart';

/// Claymorphism 3.0 & Liquid Glass Hibrit UI Tarzı Yapılandırması ve Widget Bileşenleri
/// Formül: Hacimli Degrade (Volume Gradient) + Çift İç Işık + Buzlu Sıvı Cam (Liquid Glass) + Dokunsal Yaylanma
class ClayTheme {
  static const double defaultRadius = 26.0;
  static const double cardRadius = 30.0;
  static const double buttonRadius = 24.0;

  /// Standart Claymorphism Kart Kutu Dekorasyonu (Hacim Degradesi + Çift İç Işık + Çift Katmanlı Dış Gölge)
  static BoxDecoration clayDecoration({
    required Color color,
    double borderRadius = defaultRadius,
    bool isPressed = false,
  }) {
    final HSLColor hsl = HSLColor.fromColor(color);
    final Color topLight =
        hsl.withLightness((hsl.lightness + 0.045).clamp(0.0, 1.0)).toColor();
    final Color bottomShade =
        hsl.withLightness((hsl.lightness - 0.035).clamp(0.0, 1.0)).toColor();

    if (isPressed) {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: const Alignment(-0.2, -1.0),
          end: const Alignment(0.2, 1.0),
          colors: [bottomShade, color],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1.0,
        ),
        boxShadow: [
          // 1. Zemin temas gölgesi
          BoxShadow(
            color: color.withValues(alpha: 0.16),
            offset: const Offset(0, 2),
            blurRadius: 6,
            inset: false,
          ),
          // 2. İç çöküntü gölgesi
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            offset: const Offset(0, 5),
            blurRadius: 8,
            inset: true,
          ),
          // 3. Alt hafif karşı ışık
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.85),
            offset: const Offset(0, -4),
            blurRadius: 7,
            inset: true,
          ),
        ],
      );
    }

    // Normal Havada Duran (Floating) Durum
    return BoxDecoration(
      gradient: LinearGradient(
        begin: const Alignment(-0.3, -1.0),
        end: const Alignment(0.3, 1.0),
        colors: [topLight, color, bottomShade],
        stops: const [0.0, 0.6, 1.0],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.70),
        width: 1.2,
      ),
      boxShadow: [
        // 1. Zemin Temas Gölgesi (Net zemin ayrımı)
        BoxShadow(
          color: color.withValues(alpha: 0.14),
          offset: const Offset(0, 3),
          blurRadius: 8,
          inset: false,
        ),
        // 2. Yumuşak Sıcak Atmosferik Dış Işıma (Ambient Glow - Kartı yüzdüren derinlik)
        BoxShadow(
          color: const Color(0x18C49A9E).withValues(alpha: 0.16),
          offset: const Offset(0, 14),
          blurRadius: 28,
          spreadRadius: -2,
          inset: false,
        ),
        // 3. Üst-Sol Hacimsel İç Işık (Kil parlaklığı)
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.88),
          offset: const Offset(1.5, 4.5),
          blurRadius: 8,
          inset: true,
        ),
        // 4. Alt-Sağ İç Gölge (Kil alt kıvrımı)
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.07),
          offset: const Offset(-1.0, -4.5),
          blurRadius: 8,
          inset: true,
        ),
      ],
    );
  }

  /// Liquid Glass & Glazed Ceramic (Buzlu Sıvı Cam & Sırlı Seramik) Dekorasyonu
  /// Yarı saydam arka plan, parlak beyaz sır çerçevesi ve mikro iç ışıklar içerir.
  static BoxDecoration glazedGlassDecoration({
    Color? surfaceColor,
    double borderRadius = cardRadius,
    double opacity = 0.85,
    bool isPressed = false,
  }) {
    final Color base = surfaceColor ?? Colors.white;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: (opacity + 0.08).clamp(0.0, 0.98)),
          base.withValues(alpha: opacity.clamp(0.0, 0.95)),
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.85),
        width: 1.2,
      ),
      boxShadow: [
        const BoxShadow(
          color: Color(0x18C49A9E),
          offset: Offset(0, 12),
          blurRadius: 24,
          inset: false,
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.92),
          offset: const Offset(0, 2),
          blurRadius: 6,
          inset: true,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          offset: const Offset(0, -3),
          blurRadius: 6,
          inset: true,
        ),
      ],
    );
  }

  /// Butonlar ve Küçük Etkileşim Öğeleri İçin Optimize Edilmiş Keskin Claymorphism 3.0 Dekorasyonu
  /// Butonlar ve Küçük Etkileşim Öğeleri İçin Optimize Edilmiş Hacimli Claymorphism 3.0 Dekorasyonu
  static BoxDecoration clayButtonDecoration({
    required Color color,
    double borderRadius = buttonRadius,
    bool isPressed = false,
  }) {
    final HSLColor hsl = HSLColor.fromColor(color);
    final Color topLight =
        hsl.withLightness((hsl.lightness + 0.08).clamp(0.0, 1.0)).toColor();
    final Color bottomShade =
        hsl.withLightness((hsl.lightness - 0.06).clamp(0.0, 1.0)).toColor();

    if (isPressed) {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: const Alignment(-0.2, -1.0),
          end: const Alignment(0.2, 1.0),
          colors: [bottomShade, color],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          // Zemin temas gölgesi (baskı anında yere yaklaşır)
          BoxShadow(
            color: color.withValues(alpha: 0.18),
            offset: const Offset(0, 2),
            blurRadius: 4,
            inset: false,
          ),
          // İç çöküntü gölgesi (basılma hissi)
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            offset: const Offset(0, 4),
            blurRadius: 7,
            inset: true,
          ),
          // Alt hafif karşı ışık
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.70),
            offset: const Offset(0, -3),
            blurRadius: 5,
            inset: true,
          ),
        ],
      );
    }

    return BoxDecoration(
      gradient: LinearGradient(
        begin: const Alignment(-0.35, -1.0),
        end: const Alignment(0.35, 1.0),
        colors: [topLight, color, bottomShade],
        stops: const [0.0, 0.55, 1.0],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.85),
        width: 1.2,
      ),
      boxShadow: [
        // 1. Zemin Temas Gölgesi (Net zemin ayrımı)
        BoxShadow(
          color: color.withValues(alpha: 0.22),
          offset: const Offset(0, 3),
          blurRadius: 6,
          spreadRadius: -1,
          inset: false,
        ),
        // 2. Kromatik Ortam Halesi (Diffuse Ambient Bloom - Butonu havaya kaldıran yumuşak yayılım)
        BoxShadow(
          color: color.withValues(alpha: 0.26),
          offset: const Offset(0, 12),
          blurRadius: 24,
          spreadRadius: -2,
          inset: false,
        ),
        // 3. Üst-Sol Hacimsel İç Işık (Porselen Sır Parlaklığı)
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.94),
          offset: const Offset(1.2, 3.5),
          blurRadius: 4,
          inset: true,
        ),
        // 4. Alt-Sağ Hacimsel Derinlik Gölgesi
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          offset: const Offset(-1.0, -3.5),
          blurRadius: 5,
          inset: true,
        ),
      ],
    );
  }

  /// İçbükey / Oyuk (Concave / Inset) Claymorphism Dekorasyonu
  /// Metin girişleri, çukur rozetler ve iç kutular için kullanılır
  static BoxDecoration concaveDecoration({
    required Color color,
    double borderRadius = defaultRadius,
    Border? border,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      border: border ??
          Border.all(
            color: Colors.black.withValues(alpha: 0.04),
            width: 1.0,
          ),
      boxShadow: [
        // 1. Üst & Sol İç Çukur Gölgesi (Derinlik hissi)
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.11),
          offset: const Offset(0, 4),
          blurRadius: 8,
          inset: true,
        ),
        // 2. Alt & Sağ İç Işık (Çukur kenar yansıması)
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.85),
          offset: const Offset(0, -3),
          blurRadius: 6,
          inset: true,
        ),
      ],
    );
  }

  /// ThemeData Yapılandırması (GoogleFonts Outfit & Plus Jakarta Sans / Nunito Entegrasyonu)
  static ThemeData get themeData {
    final baseTextTheme = GoogleFonts.outfitTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryPink,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryPink,
        surface: AppColors.clayCardSurface,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
          letterSpacing: -0.6,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -0.4,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: -0.2,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleSmall: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          height: 1.35,
        ),
        bodySmall: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
        labelMedium: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
        labelSmall: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.white,
        contentTextStyle: GoogleFonts.nunito(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.primaryPink.withValues(alpha: 0.15),
            width: 1.2,
          ),
        ),
        elevation: 6,
      ),
    );
  }
}

/// Claymorphic & Liquid Glass Kart Widget'ı
/// isGlazed: true olduğunda buzlu cam (BackdropFilter) ve sırlı seramik yansıması sunar.
class ClayCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool isGlazed;
  final double blurSigma;

  const ClayCard({
    super.key,
    required this.child,
    this.color = AppColors.clayCardSurface,
    this.borderRadius = ClayTheme.cardRadius,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.onTap,
    this.isGlazed = false,
    this.blurSigma = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    if (isGlazed) {
      return Container(
        margin: margin,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              decoration: ClayTheme.glazedGlassDecoration(
                surfaceColor: color,
                borderRadius: borderRadius,
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(borderRadius),
                child: InkWell(
                  borderRadius: BorderRadius.circular(borderRadius),
                  onTap: onTap,
                  child: Padding(
                    padding: padding,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: margin,
      decoration: ClayTheme.clayDecoration(
        color: color,
        borderRadius: borderRadius,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Claymorphic Buton Widget'ı (Yaylanma animasyonu, Haptic dokunuş ve dolgun pastel parlaklık)
class ClayButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color color;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? width;

  const ClayButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.color = AppColors.clayRose,
    this.borderRadius = ClayTheme.buttonRadius,
    this.padding,
    this.height,
    this.width,
  });

  @override
  State<ClayButton> createState() => _ClayButtonState();
}

class _ClayButtonState extends State<ClayButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onPressed == null) return;
    HapticFeedback.lightImpact();
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final effectivePadding = widget.padding ??
        (widget.height != null
            ? const EdgeInsets.symmetric(horizontal: 14)
            : const EdgeInsets.symmetric(horizontal: 24, vertical: 14));

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.955 : 1.0,
        duration: Duration(milliseconds: _isPressed ? 90 : 160),
        curve: _isPressed ? Curves.easeOutQuad : Curves.easeOutBack,
        child: AnimatedContainer(
          duration: Duration(milliseconds: _isPressed ? 90 : 160),
          curve: _isPressed ? Curves.easeOutQuad : Curves.easeOutBack,
          width: widget.width,
          height: widget.height,
          decoration: ClayTheme.clayButtonDecoration(
            color: widget.color,
            borderRadius: widget.borderRadius,
            isPressed: _isPressed,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Üst Glaze Işık Yayı (Specular Pearl Sheen Arch)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: (widget.height != null ? widget.height! * 0.46 : 22),
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(widget.borderRadius),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.38),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: effectivePadding,
                  child: widget.child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
