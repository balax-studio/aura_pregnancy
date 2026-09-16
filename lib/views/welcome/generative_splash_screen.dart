import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/clay_theme.dart';

/// Aura Pregnancy - Generatif Matematiksel Açılış (Splash) Ekranı
/// 1.8 saniyelik sinüzoidal kalp ritmi dalgaları, phyllotaxis altın oran parçacıkları
/// ve pürüzsüz Claymorphic geçiş animasyonları sunar.
class GenerativeSplashScreen extends StatefulWidget {
  final VoidCallback? onAnimationComplete;

  const GenerativeSplashScreen({
    super.key,
    this.onAnimationComplete,
  });

  @override
  State<GenerativeSplashScreen> createState() => _GenerativeSplashScreenState();
}

class _GenerativeSplashScreenState extends State<GenerativeSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.60, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.30, 0.75, curve: Curves.easeOut),
      ),
    );

    _animController.forward().then((_) {
      if (mounted) {
        widget.onAnimationComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Generatif Matematiksel Dalga & Parçacık Tuvali (GPU İzole)
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _GenerativeOpeningAuraPainter(
                      progress: _animController.value,
                    ),
                  );
                },
              ),
            ),
          ),

          // 2. Merkezi Claymorphic Amblem & Başlık
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hacimli Clay Kalp Rozeti
                    Container(
                      width: 88,
                      height: 88,
                      decoration: ClayTheme.clayDecoration(
                        color: AppColors.clayRose,
                        borderRadius: 34,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // İç halo
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryPink.withValues(alpha: 0.12),
                            ),
                          ),
                          const Icon(
                            Icons.favorite_rounded,
                            color: AppColors.primaryPink,
                            size: 44,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Başlık ve Slogan Metinleri
                    FadeTransition(
                      opacity: _textFadeAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Aura Pregnancy',
                            style: GoogleFonts.outfit(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'splash_tagline'.tr(),
                            style: GoogleFonts.quicksand(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Matematiksel Akustik Dalga ve Phyllotaxis Stardust Çizicisi
class _GenerativeOpeningAuraPainter extends CustomPainter {
  final double progress;

  _GenerativeOpeningAuraPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    if (width <= 0 || height <= 0) return;

    final center = Offset(width / 2, height / 2);
    final maxRadius = math.max(width, height) * 0.75;

    // 1. Konsantrik Kalp Atımı Dalgaları (Expanding Concentric Harmonic Waves)
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    const waveCount = 4;
    for (int i = 0; i < waveCount; i++) {
      final waveProgress = (progress * 1.5 - (i * 0.18)).clamp(0.0, 1.0);
      if (waveProgress > 0) {
        final currentRadius = 40.0 + (waveProgress * (maxRadius - 40.0));
        final opacity = (math.sin(waveProgress * math.pi) * 0.35).clamp(0.0, 0.35);

        wavePaint.color = i.isEven
            ? AppColors.primaryPink.withValues(alpha: opacity)
            : AppColors.secondaryPeach.withValues(alpha: opacity * 0.85);

        canvas.drawCircle(center, currentRadius, wavePaint);
      }
    }

    // 2. Merkez Çevreleyen Yumuşak Ambient Halo
    final haloRadius = 70.0 + (math.sin(progress * math.pi * 2) * 15.0);
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.clayPeach.withValues(alpha: 0.45 * (1.0 - progress * 0.3)),
          AppColors.clayRose.withValues(alpha: 0.25 * (1.0 - progress * 0.3)),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(
        Rect.fromCircle(center: center, radius: haloRadius * 2.2),
      );

    canvas.drawCircle(center, haloRadius * 2.2, haloPaint);

    // 3. Phyllotaxis Altın Oran Parçacıkları (Golden Angle Spirals)
    const particleCount = 20;
    const goldenAngle = 137.508 * (math.pi / 180.0);
    final particlePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < particleCount; i++) {
      final theta = i * goldenAngle + (progress * math.pi * 0.8);
      final r = (30.0 + math.sqrt(i + 1) * 32.0) * (0.6 + progress * 0.5);
      final px = center.dx + r * math.cos(theta);
      final py = center.dy + r * math.sin(theta);

      final pAlpha = ((math.sin(progress * math.pi + (i * 0.2)) + 1.0) * 0.5 * 0.45).clamp(0.05, 0.40);
      final pRadius = 1.4 + (math.sin(theta * 2) * 0.8);

      particlePaint.color = i % 3 == 0
          ? AppColors.primaryPink.withValues(alpha: pAlpha)
          : (i % 3 == 1
              ? AppColors.secondaryPeach.withValues(alpha: pAlpha)
              : AppColors.accentGold.withValues(alpha: pAlpha));

      canvas.drawCircle(Offset(px, py), pRadius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GenerativeOpeningAuraPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
