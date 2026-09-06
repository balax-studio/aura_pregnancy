import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Aura Pregnancy - Gerçekçi Canlı Tıbbi Ultrason & Fetal Sonografi Simülatörü
class MedicalUltrasoundWombWidget extends StatefulWidget {
  final int currentWeek;
  final int currentDay; // 1-7
  final String babyName;
  final String eddDate;
  final VoidCallback? onTap;

  const MedicalUltrasoundWombWidget({
    super.key,
    required this.currentWeek,
    this.currentDay = 3,
    this.babyName = 'Bebeğimiz',
    this.eddDate = '2026-10-15',
    this.onTap,
  });

  @override
  State<MedicalUltrasoundWombWidget> createState() =>
      _MedicalUltrasoundWombWidgetState();
}

class _MedicalUltrasoundWombWidgetState
    extends State<MedicalUltrasoundWombWidget> with TickerProviderStateMixin {
  late AnimationController _sweepController; // Sonar Işın Taraması (Sweep Beam)
  late AnimationController _heartbeatController; // Fetal Kalp Atışı
  late AnimationController _dopplerWaveController; // Canlı Doppler EKG Akışı
  late AnimationController
      _breathingController; // Fetal Solunum / Süzülme Hareketi

  bool _isCaliperActive = false;
  Offset _caliperPos = const Offset(140, 110);

  @override
  void initState() {
    super.initState();

    // 1. Sonar Tarama Işını (2.2 saniye yelpaze taraması)
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // 2. Fetal Kalp Atışı (~400ms ritmik döngü)
    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);

    // 3. Doppler Dalga Formu Kaydırma (1.5 saniye)
    _dopplerWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // 4. Sıvı İçi Nazik Solunum & Yüzme (3.8 saniye)
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _sweepController.dispose();
    _heartbeatController.dispose();
    _dopplerWaveController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  void _onScreenTapped(TapDownDetails details) {
    setState(() {
      _isCaliperActive = !_isCaliperActive;
      _caliperPos = details.localPosition;
    });
    widget.onTap?.call();
  }

  int _getStageForWeek(int week) {
    if (week <= 6) return 1;
    if (week <= 9) return 2;
    if (week <= 13) return 3;
    if (week <= 17) return 4;
    if (week <= 21) return 5;
    if (week <= 25) return 6;
    if (week <= 29) return 7;
    if (week <= 33) return 8;
    if (week <= 36) return 9;
    return 10;
  }

  String _getHeartRateRange(int week) {
    if (week <= 6) {
      return '100 - 125 bpm';
    } else if (week <= 9) {
      return '140 - 170 bpm';
    } else if (week <= 13) {
      return '150 - 170 bpm';
    } else if (week <= 21) {
      return '135 - 160 bpm';
    } else if (week <= 29) {
      return '130 - 155 bpm';
    } else if (week <= 33) {
      return '125 - 150 bpm';
    } else {
      return '120 - 145 bpm';
    }
  }

  @override
  Widget build(BuildContext context) {
    final week = widget.currentWeek;
    final day = widget.currentDay;
    final stage = _getStageForWeek(week);
    final heartRateRange = _getHeartRateRange(week);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0C1017), // Derin Tıbbi Monitör Siyahı
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF2A3649), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F2B48).withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ÜST TIBBİ TELEMETRİ / HUD BİLGİ BARI
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: const Color(0xFF141B26),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00E676), // Canlı Yeşil LED
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'HD LIVE 4D SONOGRAPHY',
                      style: GoogleFonts.jetBrainsMono(
                        color: const Color(0xFF90CAF9),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                Text(
                  'GA: ${week}w+${day}d  •  FHR: $heartRateRange',
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFFFFD54F), // Amber Telemetri
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          // ANA ULTRASON AKUSTİK EKRANI
          GestureDetector(
            onTapDown: _onScreenTapped,
            child: SizedBox(
              height: 240,
              width: double.infinity,
              child: Stack(
                children: [
                  // 1. Akustik Izgara ve Haftalık Anatomik Fetüs Çizimi
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _sweepController,
                      _heartbeatController,
                      _breathingController,
                    ]),
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(double.infinity, 240),
                        painter: _UltrasoundScreenPainter(
                          week: week,
                          stage: stage,
                          sweepProgress: _sweepController.value,
                          heartbeatScale: _heartbeatController.value,
                          breathingOffset: _breathingController.value,
                          isCaliperActive: _isCaliperActive,
                          caliperPos: _caliperPos,
                        ),
                      );
                    },
                  ),

                  // 2. Sol Akustik Derinlik Skalası (Depth Ruler)
                  Positioned(
                    left: 8,
                    top: 15,
                    bottom: 15,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return Text(
                          '${index * 3}',
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontSize: 8,
                          ),
                        );
                      }),
                    ),
                  ),

                  // 3. Sağ Üst Kalp Atışı Aralık Rozeti
                  Positioned(
                    right: 12,
                    top: 10,
                    child: AnimatedBuilder(
                      animation: _heartbeatController,
                      builder: (context, child) {
                        final scale =
                            0.95 + (_heartbeatController.value * 0.12);
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE91E63)
                                  .withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFFFF4081)
                                      .withValues(alpha: 0.7)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.favorite_rounded,
                                    color: Color(0xFFFF4081), size: 12),
                                const SizedBox(width: 5),
                                Text(
                                  heartRateRange,
                                  style: GoogleFonts.jetBrainsMono(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // 4. Caliper Ölçüm Bilgisi (Dokunulduğunda)
                  if (_isCaliperActive)
                    Positioned(
                      left: _caliperPos.dx - 40,
                      top: max(10, _caliperPos.dy - 35),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getCaliperLabel(week),
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.black,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ALT CANLI DOPPLER SES / EKG DALGASI
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            color: const Color(0xFF0A0E14),
            child: Row(
              children: [
                Text(
                  'DOPPLER',
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFF00E5FF),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _dopplerWaveController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(double.infinity, 30),
                        painter: _DopplerWaveformPainter(
                          progress: _dopplerWaveController.value,
                          heartbeat: _heartbeatController.value,
                        ),
                      );
                    },
                  ),
                ),
                Text(
                  _getStageName(week),
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFB0BEC5),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCaliperLabel(int week) {
    if (week <= 13) {
      return 'CRL: ${(week * 0.6).toStringAsFixed(1)} cm';
    } else if (week <= 27) {
      return 'BPD: ${(week * 0.28).toStringAsFixed(1)} cm';
    } else {
      return 'FL: ${(week * 0.18).toStringAsFixed(1)} cm';
    }
  }

  String _getStageName(int week) {
    if (week <= 8) return 'Embriyonik Kese';
    if (week <= 13) return '1. Trimester (İkili Tarama)';
    if (week <= 20) return '2. Trimester Erken Dönem';
    if (week <= 27) return '2. Trimester (Ayrıntılı Ultrason)';
    if (week <= 34) return '3. Trimester Fetal Büyüme';
    return '3. Trimester (Doğuma Hazır)';
  }
}

/// Akustik Sektör, 4D HD Live Ekojenik Fetüs ve Sonar Çizicisi
class _UltrasoundScreenPainter extends CustomPainter {
  final int week;
  final int stage;
  final double sweepProgress;
  final double heartbeatScale;
  final double breathingOffset;
  final bool isCaliperActive;
  final Offset caliperPos;

  _UltrasoundScreenPainter({
    required this.week,
    required this.stage,
    required this.sweepProgress,
    required this.heartbeatScale,
    required this.breathingOffset,
    required this.isCaliperActive,
    required this.caliperPos,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.46);
    final width = size.width;
    final height = size.height;

    // 1. Akustik Sektör Yelpaze Koni Alanı
    final sectorPath = Path();
    final apex = Offset(width / 2, -15);
    sectorPath.moveTo(apex.dx, apex.dy);
    sectorPath.lineTo(width * 0.06, height);
    sectorPath.arcToPoint(
      Offset(width * 0.94, height),
      radius: Radius.circular(width * 0.82),
    );
    sectorPath.close();

    // Sektör Arka Planı (Sıcak 4D HD Live Sepya-Altın ve Akustik Tonları)
    final sectorPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0, -0.9),
        radius: 1.35,
        colors: [
          Color(0xFF241712), // 4D HD Live Sıcak Sepya
          Color(0xFF160F0C),
          Color(0xFF090706),
        ],
      ).createShader(Rect.fromLTWH(0, 0, width, height));
    canvas.drawPath(sectorPath, sectorPaint);

    // 2. Akustik Derinlik Arkları
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 1; i <= 4; i++) {
      final r = (height * 0.25) * i;
      canvas.drawCircle(apex, r, gridPaint);
    }

    // 3. Haftaya Göre Gerçekçi 4D Anatomik Fetüs Çizimi
    canvas.save();
    canvas.clipPath(sectorPath);

    final breatheY = sin(breathingOffset * pi) * 4.5;
    final breatheRotate = sin(breathingOffset * pi) * 0.025;

    canvas.translate(center.dx, center.dy + breatheY);
    canvas.rotate(breatheRotate);

    if (stage == 1) {
      _drawStage1EarlyEmbryo(canvas, heartbeatScale);
    } else if (stage == 2) {
      _drawStage2FirstTrimester(canvas, heartbeatScale);
    } else if (stage == 3) {
      _drawStage3EarlySecondTrimester(canvas, heartbeatScale);
    } else if (stage == 4) {
      _drawStage4DetailedMorphology(canvas, heartbeatScale);
    } else if (stage == 5) {
      _drawStage5ThirdTrimesterGrowth(canvas, heartbeatScale);
    } else {
      _drawStage6FullTermBaby(canvas, heartbeatScale);
    }

    canvas.restore();

    // 4. Sonar Işın Taraması (Sector Sweep Beam)
    final sweepAngle = -0.58 + (sweepProgress * 1.16); // -33° ile +33°
    final beamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF00E5FF).withValues(alpha: 0.4),
          const Color(0xFF00E5FF).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, width, height))
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.translate(apex.dx, apex.dy);
    canvas.rotate(sweepAngle);
    canvas.drawLine(Offset.zero, Offset(0, height * 1.25), beamPaint);
    canvas.restore();

    // 5. Caliper Ölçüm Çizgileri
    if (isCaliperActive) {
      final calPaint = Paint()
        ..color = const Color(0xFF00E5FF)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(caliperPos.dx - 10, caliperPos.dy),
        Offset(caliperPos.dx + 10, caliperPos.dy),
        calPaint,
      );
      canvas.drawLine(
        Offset(caliperPos.dx, caliperPos.dy - 10),
        Offset(caliperPos.dx, caliperPos.dy + 10),
        calPaint,
      );
      canvas.drawCircle(caliperPos, 14, calPaint);
    }
  }

  /// 1. Evre (1-8. Hafta): Erken Gebelik Kesesi & Yolk Sac & Embriyo Kutbu
  void _drawStage1EarlyEmbryo(Canvas canvas, double pulse) {
    // Gestasyonel Kese
    final sacPaint = Paint()
      ..color = const Color(0xFF33221C).withValues(alpha: 0.6);
    canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 140, height: 105),
        sacPaint);

    final sacBorder = Paint()
      ..color = const Color(0xFFE0A978).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5;
    canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 140, height: 105),
        sacBorder);

    // Yolk Sac
    final yolkBorder = Paint()
      ..color = const Color(0xFFFFE0B2).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(const Offset(-25, -8), 16, yolkBorder);

    // Embriyonik Kutup
    final embryoPaint = Paint()..color = const Color(0xFFFFF3E0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(12, 0), width: 38, height: 20),
        const Radius.circular(10),
      ),
      embryoPaint,
    );

    // Atan Fetal Kalp Işıltısı
    final heartPaint = Paint()
      ..color = const Color(0xFFFF5252).withValues(alpha: 0.8 + (pulse * 0.2))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(10, 0), 5 + (pulse * 2.5), heartPaint);
  }

  /// 2. Evre (9-13. Hafta): 1. Trimester İkili Tarama (Kranium, NT, Omurga)
  void _drawStage2FirstTrimester(Canvas canvas, double pulse) {
    final tissue = Paint()
      ..color = const Color(0xFFC68B59).withValues(alpha: 0.75);
    final bone = Paint()
      ..color = const Color(0xFFFFE8D6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Kranium
    canvas.drawCircle(const Offset(-36, -22), 28, tissue);
    canvas.drawCircle(const Offset(-36, -22), 28, bone);

    // NT Ense Kalınlığı Eko Lüsens Alanı
    final ntPaint = Paint()
      ..color = const Color(0xFF40C4FF).withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(-44, -16), radius: 21),
      pi * 0.4,
      pi * 0.5,
      false,
      ntPaint,
    );

    // Omurga
    final spine = Path();
    spine.moveTo(-20, -6);
    spine.quadraticBezierTo(14, -10, 34, 18);
    spine.quadraticBezierTo(28, 42, 6, 44);
    canvas.drawPath(spine, bone);

    // Kol & Bacak
    canvas.drawLine(const Offset(-10, 6), const Offset(-20, 22), bone);
    canvas.drawLine(const Offset(22, 28), const Offset(16, 52), bone);

    // Atan Kalp
    final heartPaint = Paint()
      ..color = const Color(0xFFFF1744).withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(-6, 10), 6 + (pulse * 2.8), heartPaint);
  }

  /// 3. Evre (14-20. Hafta): 2. Trimester Erken Dönem (Yüz Profili & Omurlar)
  void _drawStage3EarlySecondTrimester(Canvas canvas, double pulse) {
    final tissue = Paint()
      ..color = const Color(0xFFD49A6A).withValues(alpha: 0.8);
    final bone = Paint()
      ..color = const Color(0xFFFFF0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5;

    // Baş & Yüz Profili
    canvas.drawCircle(const Offset(-42, -20), 34, tissue);
    final facePath = Path();
    facePath.moveTo(-54, -36);
    facePath.lineTo(-72, -12); // Burun
    facePath.lineTo(-63, -5);
    facePath.lineTo(-67, 4); // Dudak
    facePath.lineTo(-60, 14); // Çene
    canvas.drawPath(facePath, bone);

    // Burun Kemiği
    canvas.drawLine(
        const Offset(-68, -16),
        const Offset(-60, -22),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 3);

    // Omurga Dizi Noktaları
    for (int i = 0; i < 11; i++) {
      final t = i / 10.0;
      final x = -24 + (t * 75);
      final y = 10 + sin(t * pi) * 30;
      canvas.drawCircle(Offset(x, y), 3.2, Paint()..color = Colors.white);
    }

    // Gövde
    canvas.drawOval(
        Rect.fromCenter(center: const Offset(6, 18), width: 68, height: 50),
        tissue);
    // Femur
    canvas.drawLine(const Offset(30, 30), const Offset(56, 52), bone);
    // Kalp
    canvas.drawCircle(const Offset(-10, 10), 7 + (pulse * 3.0),
        Paint()..color = const Color(0xFFFF1744));
  }

  /// 4. Evre (21-27. Hafta): 2. Trimester 4D Ayrıntılı Morfoloji
  void _drawStage4DetailedMorphology(Canvas canvas, double pulse) {
    final tissue = Paint()
      ..color = const Color(0xFFE0A878).withValues(alpha: 0.85);
    final bone = Paint()
      ..color = const Color(0xFFFFF5EC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    // Baş & Yüz
    canvas.drawCircle(const Offset(-45, -16), 40, tissue);
    final facePath = Path();
    facePath.moveTo(-58, -40);
    facePath.lineTo(-80, -10); // Burun ucu
    facePath.lineTo(-70, -1);
    facePath.lineTo(-74, 9); // Dudak
    facePath.lineTo(-66, 22); // Çene
    canvas.drawPath(facePath, bone);

    // Kapalı Göz Kapağı
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(-58, -14), width: 16, height: 7),
      0,
      pi,
      false,
      Paint()
        ..color = const Color(0xFF8D5B36)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );

    // Gövde & Sırt
    canvas.drawOval(
        Rect.fromCenter(center: const Offset(10, 20), width: 92, height: 64),
        tissue);
    for (int i = 0; i < 13; i++) {
      final t = i / 12.0;
      final x = -20 + (t * 88);
      final y = 10 + sin(t * pi) * 36;
      canvas.drawCircle(Offset(x, y), 3.5, Paint()..color = Colors.white);
    }

    // Göbek Kordonu
    final cord = Path();
    cord.moveTo(18, 30);
    cord.quadraticBezierTo(44, 58, 72, 44);
    canvas.drawPath(
        cord,
        Paint()
          ..color = const Color(0xFF40C4FF).withValues(alpha: 0.85)
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke);

    // Kalp Dört Odacık
    canvas.drawCircle(const Offset(-10, 14), 8 + (pulse * 3.2),
        Paint()..color = const Color(0xFFFF1744));
  }

  /// 5. Evre (28-34. Hafta): 3. Trimester Dolgun Yanaklı Fetüs
  void _drawStage5ThirdTrimesterGrowth(Canvas canvas, double pulse) {
    final tissue = Paint()
      ..color = const Color(0xFFE8B588).withValues(alpha: 0.9);
    final bone = Paint()
      ..color = const Color(0xFFFFF8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5;

    canvas.drawCircle(const Offset(-42, -14), 46, tissue);
    final facePath = Path();
    facePath.moveTo(-56, -44);
    facePath.lineTo(-84, -8); // Burun
    facePath.lineTo(-72, 1);
    facePath.lineTo(-78, 11); // Dudak
    facePath.lineTo(-66, 25); // Dolgun çene
    canvas.drawPath(facePath, bone);

    // Yanak Dolgunluğu
    canvas.drawOval(
        Rect.fromCenter(center: const Offset(-48, 4), width: 32, height: 24),
        Paint()..color = const Color(0xFFF4C49C));

    // Kapalı Göz
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(-60, -12), width: 17, height: 8),
      0,
      pi,
      false,
      Paint()
        ..color = const Color(0xFF8D5B36)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );

    // Geniş Gövde
    canvas.drawOval(
        Rect.fromCenter(center: const Offset(18, 24), width: 110, height: 75),
        tissue);
    // Kalp
    canvas.drawCircle(const Offset(-6, 18), 9 + (pulse * 3.5),
        Paint()..color = const Color(0xFFFF1744));
  }

  /// 6. Evre (35-40. Hafta): Doğuma Hazır Tam Bebek
  void _drawStage6FullTermBaby(Canvas canvas, double pulse) {
    final tissue = Paint()
      ..color = const Color(0xFFEEBF94).withValues(alpha: 0.95);
    final bone = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    canvas.drawCircle(const Offset(-38, -10), 52, tissue);
    final facePath = Path();
    facePath.moveTo(-52, -48);
    facePath.lineTo(-86, -7); // Burun
    facePath.lineTo(-74, 2);
    facePath.lineTo(-80, 14); // Dudak
    facePath.lineTo(-68, 30); // Çene
    canvas.drawPath(facePath, bone);

    canvas.drawOval(
        Rect.fromCenter(center: const Offset(-45, 7), width: 36, height: 28),
        Paint()..color = const Color(0xFFF8CFA8));

    // Kapalı Göz
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(-60, -10), width: 18, height: 8),
      0,
      pi,
      false,
      Paint()
        ..color = const Color(0xFF7A4A28)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke,
    );

    // Büyük Gövde
    canvas.drawOval(
        Rect.fromCenter(center: const Offset(24, 28), width: 122, height: 86),
        tissue);
    // Kalp
    canvas.drawCircle(const Offset(-4, 20), 10 + (pulse * 3.8),
        Paint()..color = const Color(0xFFFF1744));
  }

  @override
  bool shouldRepaint(covariant _UltrasoundScreenPainter oldDelegate) {
    return true;
  }
}

/// Canlı Doppler EKG / Fetal Akış Çizicisi
class _DopplerWaveformPainter extends CustomPainter {
  final double progress;
  final double heartbeat;

  _DopplerWaveformPainter({required this.progress, required this.heartbeat});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final midY = height / 2;

    final wavePaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF00E5FF).withValues(alpha: 0.3),
          const Color(0xFF00E5FF).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, midY);

    const segmentWidth = 45.0;
    final offsetShift = progress * segmentWidth;

    for (double x = -segmentWidth;
        x <= width + segmentWidth;
        x += segmentWidth) {
      final curX = x - offsetShift;
      // Sistolik Eko Piki (Doppler Systolic Peak)
      path.lineTo(curX + 10, midY);
      path.lineTo(curX + 18, midY - (height * 0.42)); // Sivri Sistolik tepe
      path.lineTo(curX + 24, midY - (height * 0.15)); // Dikrotik çentik
      path.lineTo(curX + 30, midY - (height * 0.28)); // Diyastolik dalga
      path.lineTo(curX + 38, midY);
    }

    canvas.drawPath(path, wavePaint);

    final closedPath = Path.from(path);
    closedPath.lineTo(width, height);
    closedPath.lineTo(0, height);
    closedPath.close();
    canvas.drawPath(closedPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _DopplerWaveformPainter oldDelegate) {
    return true;
  }
}
