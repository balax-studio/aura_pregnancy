import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

/// Aura Pregnancy - Anne Karnında Hafif Hareketli Bebek Animasyonu Widget'ı
class AnimatedWombBabyWidget extends StatefulWidget {
  final int currentWeek;
  final String babyName;
  final String gender;
  final VoidCallback? onTap;

  const AnimatedWombBabyWidget({
    super.key,
    required this.currentWeek,
    this.babyName = 'Bebeğim',
    this.gender = 'surprise',
    this.onTap,
  });

  @override
  State<AnimatedWombBabyWidget> createState() => _AnimatedWombBabyWidgetState();
}

class _AnimatedWombBabyWidgetState extends State<AnimatedWombBabyWidget>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _heartbeatController;
  late AnimationController _sparkleController;
  bool _isTapped = false;

  @override
  void initState() {
    super.initState();

    // 1. Sıvı İçinde Nazik Süzülme Animasyonu (3.5 saniyelik dingin döngü)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat(reverse: true);

    // 2. Kalp Atışı & Solunum Nabzı (1.2 saniyelik ritmik nabız)
    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // 3. Amniyotik Işıltı Animasyonu
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _heartbeatController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() => _isTapped = true);
    widget.onTap?.call();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isTapped = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final week = widget.currentWeek;

    return GestureDetector(
      onTap: _handleTap,
      child: Center(
        child: Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [
                Color(0xFFFFEEF3), // İç rahmin sıcak pembesi
                Color(0xFFFDE0E8),
                Color(0xFFFAD2DE),
              ],
              stops: [0.3, 0.7, 1.0],
            ),
            boxShadow: [
              // Dış yumuşak Claymorphic gölge
              BoxShadow(
                color: AppColors.primaryPink.withValues(alpha: 0.22),
                offset: const Offset(0, 16),
                blurRadius: 30,
              ),
              // Üst iç ışık
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.8),
                offset: const Offset(-8, -8),
                blurRadius: 16,
              ),
              // Alt iç gölge
              BoxShadow(
                color: const Color(0xFFE899AE).withValues(alpha: 0.35),
                offset: const Offset(8, 8),
                blurRadius: 16,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Amniyotik Sıvı & Işıltı Halkaları
              AnimatedBuilder(
                animation: _sparkleController,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(220, 220),
                    painter: _AmnioticFluidPainter(
                      progress: _sparkleController.value,
                      pulse: _heartbeatController.value,
                    ),
                  );
                },
              ),

              // Hareketli & Süzülen Bebek Silueti
              AnimatedBuilder(
                animation: Listenable.merge([_floatController, _heartbeatController]),
                builder: (context, child) {
                  final floatOffsetY = sin(_floatController.value * pi) * 8.0;
                  final floatRotation = sin(_floatController.value * pi) * 0.04;
                  final pulseScale = 0.96 + (_heartbeatController.value * 0.07) + (_isTapped ? 0.08 : 0.0);

                  return Transform.translate(
                    offset: Offset(0, floatOffsetY),
                    child: Transform.rotate(
                      angle: floatRotation,
                      child: Transform.scale(
                        scale: pulseScale,
                        child: _buildBabyFigureForWeek(week),
                      ),
                    ),
                  );
                },
              ),

              // Kalp Atışı Minik Işıltısı
              Positioned(
                top: 75,
                child: AnimatedBuilder(
                  animation: _heartbeatController,
                  builder: (context, child) {
                    final opacity = (0.3 + (_heartbeatController.value * 0.7)).clamp(0.0, 1.0);
                    return Opacity(
                      opacity: opacity,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryPink.withValues(alpha: 0.3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.favorite_rounded, color: AppColors.primaryPink, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'Kalp Atışı Aktif',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Alt Bilgi Etiketi (Haftalık Durum)
              Positioned(
                bottom: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome_rounded, size: 11, color: AppColors.primaryPink),
                      const SizedBox(width: 4),
                      Text(
                        _getBabyActionText(week),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bulunulan haftaya göre bebeğin gelişim aşaması görseli
  Widget _buildBabyFigureForWeek(int week) {
    if (week <= 8) {
      // 1-8. Hafta: Minik Embriyo / Kalp Tomurcuğu Evresi
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFF8FA3).withValues(alpha: 0.85),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF758F).withValues(alpha: 0.4),
              blurRadius: 18,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.spa_rounded, color: Colors.white, size: 42),
        ),
      );
    } else if (week <= 13) {
      // 9-13. Hafta: İlk Fetüs Silueti (Kollar, Bacaklar belirgin)
      return Container(
        width: 105,
        height: 105,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFFB3C1).withValues(alpha: 0.9),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPink.withValues(alpha: 0.35),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.nature_people_rounded, color: Colors.white, size: 54),
        ),
      );
    } else if (week <= 27) {
      // 14-27. Hafta: 2. Trimester Hareketli Sevimli Fetüs
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFFCCD5).withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPink.withValues(alpha: 0.3),
              blurRadius: 22,
              spreadRadius: 3,
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.child_care_rounded, color: Colors.white, size: 68),
        ),
      );
    } else {
      // 28-40. Hafta: 3. Trimester Tam Gelişmiş Melek Bebek
      return Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFFF0F3),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPink.withValues(alpha: 0.35),
              blurRadius: 25,
              spreadRadius: 4,
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.face_retouching_natural_rounded, color: AppColors.primaryPink, size: 78),
        ),
      );
    }
  }

  String _getBabyActionText(int week) {
    if (week <= 8) {
      return 'Kalp tüpleri hızla atıyor';
    } else if (week <= 13) {
      return 'Amniyotik sıvıda tatlı yüzüş';
    } else if (week <= 20) {
      return 'Sesinizi dinliyor ve esniyor';
    } else if (week <= 28) {
      return 'Minik hareketlerle dans ediyor';
    } else if (week <= 36) {
      return 'Rüya görüyor ve kilo alıyor';
    } else {
      return 'Doğuma hazır bekliyor';
    }
  }
}

/// Amniyotik Sıvı Işıltı ve Dalgalanma Çizicisi
class _AmnioticFluidPainter extends CustomPainter {
  final double progress;
  final double pulse;

  _AmnioticFluidPainter({required this.progress, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35 * (1.0 - progress))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Genişleyen Işıltı Halkası
    final radius = (size.width / 2.6) + (progress * 25.0);
    canvas.drawCircle(center, radius, paint);

    // Parıltı Noktaları (Yıldız tozları)
    final dotPaint = Paint()..color = const Color(0xFFFF758F).withValues(alpha: 0.45);
    for (int i = 0; i < 6; i++) {
      final angle = (i * (pi / 3)) + (progress * pi * 0.5);
      final r = (size.width / 3.2) + sin(progress * 2 * pi + i) * 12;
      final x = center.dx + cos(angle) * r;
      final y = center.dy + sin(angle) * r;
      canvas.drawCircle(Offset(x, y), 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AmnioticFluidPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.pulse != pulse;
  }
}
