import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Aura Pregnancy - Generatif Matematiksel Ortam Işığı & Yaşayan Aura Arka Planı
/// Düz renk ve donuk statik kutular yerine, sinüzoidal harmonik dalgalar,
/// anne nefesini taklit eden ritmik ışık geçişleri ve mikro-stardust parçacıkları üretir.
class AmbientBackground extends StatefulWidget {
  final Widget child;
  final bool showAmbientOrbs;

  const AmbientBackground({
    super.key,
    required this.child,
    this.showAmbientOrbs = true,
  });

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showAmbientOrbs) {
      return Container(
        decoration: const BoxDecoration(
          gradient: AppColors.ambientBackgroundGradient,
        ),
        child: widget.child,
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.ambientBackgroundGradient,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Matematiksel Generatif Aura Katmanı (RepaintBoundary ile izole, 60fps GPU dostu)
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _GenerativeAuraPainter(
                      progress: _pulseController.value,
                    ),
                  );
                },
              ),
            ),
          ),

          // 2. Ana İçerik
          widget.child,
        ],
      ),
    );
  }
}

/// Generatif Matematiksel Işık & Organik Aura Çizicisi (Shader-like CustomPainter)
class _GenerativeAuraPainter extends CustomPainter {
  final double progress;

  _GenerativeAuraPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    if (width <= 0 || height <= 0) return;

    final time = progress * 2 * math.pi;

    // 1. Anne & Bebek Yaşayan Şeftali Işık Halesi (Sağ Üst / Orta Salınım)
    final orb1X = width * 0.85 + math.sin(time) * (width * 0.08);
    final orb1Y = height * 0.18 + math.cos(time * 0.7) * (height * 0.05);
    final orb1Radius = width * 0.55 + math.sin(time * 1.2) * (width * 0.06);

    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.clayPeach.withValues(alpha: 0.32),
          AppColors.clayRose.withValues(alpha: 0.16),
          Colors.transparent,
        ],
        stops: const [0.0, 0.48, 1.0],
      ).createShader(
        Rect.fromCircle(
          center: Offset(orb1X, orb1Y),
          radius: orb1Radius,
        ),
      );

    canvas.drawCircle(Offset(orb1X, orb1Y), orb1Radius, paint1);

    // 2. Sakinleştirici Lavanta & Su Mavisi Halesi (Sol Alt / Orta Salınım)
    final orb2X = width * 0.15 + math.cos(time * 0.8) * (width * 0.09);
    final orb2Y = height * 0.72 + math.sin(time * 0.9) * (height * 0.06);
    final orb2Radius = width * 0.60 + math.cos(time * 1.1) * (width * 0.05);

    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.clayLavender.withValues(alpha: 0.28),
          AppColors.claySky.withValues(alpha: 0.14),
          Colors.transparent,
        ],
        stops: const [0.0, 0.50, 1.0],
      ).createShader(
        Rect.fromCircle(
          center: Offset(orb2X, orb2Y),
          radius: orb2Radius,
        ),
      );

    canvas.drawCircle(Offset(orb2X, orb2Y), orb2Radius, paint2);

    // 3. Ferahlatıcı Nane Yeşili Mikro Işıma (Merkez Sağ Alt)
    final orb3X = width * 0.70 + math.sin(time * 0.6 + 1.0) * (width * 0.07);
    final orb3Y = height * 0.88 + math.cos(time * 0.5 + 1.0) * (height * 0.04);
    final orb3Radius = width * 0.42;

    final paint3 = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.clayMint.withValues(alpha: 0.22),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(
        Rect.fromCircle(
          center: Offset(orb3X, orb3Y),
          radius: orb3Radius,
        ),
      );

    canvas.drawCircle(Offset(orb3X, orb3Y), orb3Radius, paint3);

    // 4. Polar Koordinatlı Mikro Stardust Parçacıkları (Tactile Floating Sparkles)
    final particlePaint = Paint()..style = PaintingStyle.fill;
    final particleSeeds = [
      const Offset(0.22, 0.15),
      const Offset(0.78, 0.32),
      const Offset(0.35, 0.58),
      const Offset(0.82, 0.76),
      const Offset(0.18, 0.84),
      const Offset(0.55, 0.24),
    ];

    for (int i = 0; i < particleSeeds.length; i++) {
      final seed = particleSeeds[i];
      final phase = time + (i * 1.047); // 60 derece faz farkı (2pi / 6)
      final px = (seed.dx * width) + math.sin(phase) * 12.0;
      final py = (seed.dy * height) + math.cos(phase * 0.8) * 16.0;
      final pAlpha = ((math.sin(phase * 1.5) + 1.0) * 0.5 * 0.28).clamp(0.04, 0.30);
      final pRadius = 1.6 + math.sin(phase) * 0.8;

      particlePaint.color = Colors.white.withValues(alpha: pAlpha);
      canvas.drawCircle(Offset(px, py), pRadius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GenerativeAuraPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
