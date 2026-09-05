// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Generate 6 Ultrasound Stage Images', () async {
    const width = 600;
    const height = 600;

    for (int stage = 1; stage <= 6; stage++) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
          recorder, Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()));

      // 1. Koyu Akustik Monitör Arka Planı
      final bgPaint = Paint()..color = const Color(0xFF080C12);
      canvas.drawRect(
          Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), bgPaint);

      // 2. Akustik Sektör Koni Alanı
      final conePath = Path();
      const apex = Offset(width / 2, -20);
      conePath.moveTo(apex.dx, apex.dy);
      conePath.lineTo(20, height.toDouble());
      conePath.arcToPoint(
        Offset(width - 20, height.toDouble()),
        radius: const Radius.circular(width * 0.8),
      );
      conePath.close();

      final coneShader = const RadialGradient(
        center: Alignment(0, -0.9),
        radius: 1.3,
        colors: [
          Color(0xFF221610), // Sıcak 4D HD Live Sepya-Altın Tonu
          Color(0xFF140F0C),
          Color(0xFF0A0806),
        ],
      ).createShader(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()));

      canvas.drawPath(conePath, Paint()..shader = coneShader);

      // Akustik Eko Grid Halkaları
      final gridPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      for (int i = 1; i <= 5; i++) {
        canvas.drawCircle(apex, (height * 0.2) * i, gridPaint);
      }

      // 3. Haftalık Anatomik Fetüs Çizimi
      canvas.save();
      canvas.clipPath(conePath);
      const center = Offset(width / 2, height * 0.5);

      if (stage == 1) {
        // 1-8 Hafta: Erken Gebelik Kesesi & Yolk Sac & Embriyo
        final sacPaint = Paint()..color = const Color(0xFF2A201C);
        canvas.drawOval(
            Rect.fromCenter(center: center, width: 220, height: 160), sacPaint);

        final sacBorder = Paint()
          ..color = const Color(0xFFD4A373).withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6;
        canvas.drawOval(
            Rect.fromCenter(center: center, width: 220, height: 160),
            sacBorder);

        // Yolk Sac
        final yolkBorder = Paint()
          ..color = const Color(0xFFFFE0B2).withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;
        canvas.drawCircle(
            Offset(center.dx - 35, center.dy - 10), 24, yolkBorder);

        // Embriyo Kutbu
        final embryoPaint = Paint()..color = const Color(0xFFFFF3E0);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(center.dx + 20, center.dy),
                width: 55,
                height: 28),
            const Radius.circular(14),
          ),
          embryoPaint,
        );

        // Kalp Işıltısı
        final heartPaint = Paint()..color = const Color(0xFFFF5252);
        canvas.drawCircle(Offset(center.dx + 16, center.dy), 8, heartPaint);
      } else if (stage == 2) {
        // 9-13 Hafta: 1. Trimester İkili Tarama (Kranium, NT, Omurga)
        final tissue = Paint()
          ..color = const Color(0xFFC68B59).withValues(alpha: 0.75);
        final bone = Paint()
          ..color = const Color(0xFFFFE8D6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6;

        // Kranium
        canvas.drawCircle(Offset(center.dx - 55, center.dy - 35), 44, tissue);
        canvas.drawCircle(Offset(center.dx - 55, center.dy - 35), 44, bone);

        // NT Eko Alanı
        final ntPaint = Paint()
          ..color = const Color(0xFF40C4FF).withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.5;
        canvas.drawArc(
          Rect.fromCircle(
              center: Offset(center.dx - 65, center.dy - 25), radius: 32),
          pi * 0.4,
          pi * 0.5,
          false,
          ntPaint,
        );

        // Omurga
        final spine = Path();
        spine.moveTo(center.dx - 30, center.dy - 10);
        spine.quadraticBezierTo(
            center.dx + 25, center.dy - 15, center.dx + 55, center.dy + 30);
        spine.quadraticBezierTo(
            center.dx + 45, center.dy + 65, center.dx + 10, center.dy + 70);
        canvas.drawPath(spine, bone);

        // Kol & Bacak
        canvas.drawLine(Offset(center.dx - 15, center.dy + 10),
            Offset(center.dx - 30, center.dy + 35), bone);
        canvas.drawLine(Offset(center.dx + 35, center.dy + 45),
            Offset(center.dx + 25, center.dy + 80), bone);

        // Kalp
        canvas.drawCircle(Offset(center.dx - 10, center.dy + 15), 10,
            Paint()..color = const Color(0xFFFF1744));
      } else if (stage == 3) {
        // 14-20 Hafta: 2. Trimester Erken Dönem (Yüz Profili & Kemikler)
        final tissue = Paint()
          ..color = const Color(0xFFD49A6A).withValues(alpha: 0.8);
        final bone = Paint()
          ..color = const Color(0xFFFFF0E0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6.5;

        // Baş & Yüz
        canvas.drawCircle(Offset(center.dx - 60, center.dy - 30), 52, tissue);
        final facePath = Path();
        facePath.moveTo(center.dx - 80, center.dy - 55);
        facePath.lineTo(center.dx - 105, center.dy - 20); // Burun
        facePath.lineTo(center.dx - 92, center.dy - 10);
        facePath.lineTo(center.dx - 98, center.dy + 5); // Dudak
        facePath.lineTo(center.dx - 88, center.dy + 20); // Çene
        canvas.drawPath(facePath, bone);

        // Burun Kemiği
        canvas.drawLine(
            Offset(center.dx - 98, center.dy - 26),
            Offset(center.dx - 86, center.dy - 34),
            Paint()
              ..color = Colors.white
              ..strokeWidth = 4.5);

        // Omurga Dizi Noktaları
        for (int i = 0; i < 14; i++) {
          final t = i / 13.0;
          final x = center.dx - 35 + (t * 110);
          final y = center.dy + 15 + sin(t * pi) * 45;
          canvas.drawCircle(Offset(x, y), 4.5, Paint()..color = Colors.white);
        }

        // Gövde
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(center.dx + 10, center.dy + 25),
                width: 100,
                height: 75),
            tissue);
        // Femur
        canvas.drawLine(Offset(center.dx + 45, center.dy + 45),
            Offset(center.dx + 85, center.dy + 75), bone);
        // Kalp
        canvas.drawCircle(Offset(center.dx - 15, center.dy + 15), 11,
            Paint()..color = const Color(0xFFFF1744));
      } else if (stage == 4) {
        // 21-27 Hafta: 2. Trimester 4D Morfoloji
        final tissue = Paint()
          ..color = const Color(0xFFE0A878).withValues(alpha: 0.85);
        final bone = Paint()
          ..color = const Color(0xFFFFF5EC)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7;

        // Baş & Yüz
        canvas.drawCircle(Offset(center.dx - 65, center.dy - 25), 60, tissue);
        final facePath = Path();
        facePath.moveTo(center.dx - 85, center.dy - 60);
        facePath.lineTo(center.dx - 118, center.dy - 15); // Burun ucu
        facePath.lineTo(center.dx - 104, center.dy - 2);
        facePath.lineTo(center.dx - 110, center.dy + 12); // Dudak
        facePath.lineTo(center.dx - 98, center.dy + 30); // Çene
        canvas.drawPath(facePath, bone);

        // Göz Kapağı
        canvas.drawArc(
          Rect.fromCenter(
              center: Offset(center.dx - 85, center.dy - 20),
              width: 22,
              height: 10),
          0,
          pi,
          false,
          Paint()
            ..color = const Color(0xFF8D5B36)
            ..strokeWidth = 4
            ..style = PaintingStyle.stroke,
        );

        // Gövde & Sırt
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(center.dx + 15, center.dy + 30),
                width: 135,
                height: 95),
            tissue);
        for (int i = 0; i < 16; i++) {
          final t = i / 15.0;
          final x = center.dx - 30 + (t * 130);
          final y = center.dy + 15 + sin(t * pi) * 55;
          canvas.drawCircle(Offset(x, y), 5.0, Paint()..color = Colors.white);
        }

        // Göbek Kordonu
        final cord = Path();
        cord.moveTo(center.dx + 25, center.dy + 45);
        cord.quadraticBezierTo(
            center.dx + 65, center.dy + 85, center.dx + 105, center.dy + 65);
        canvas.drawPath(
            cord,
            Paint()
              ..color = const Color(0xFF40C4FF).withValues(alpha: 0.85)
              ..strokeWidth = 6
              ..style = PaintingStyle.stroke);

        // Kalp
        canvas.drawCircle(Offset(center.dx - 15, center.dy + 20), 12,
            Paint()..color = const Color(0xFFFF1744));
      } else if (stage == 5) {
        // 28-34 Hafta: 3. Trimester Dolgun Yanaklı Fetüs
        final tissue = Paint()
          ..color = const Color(0xFFE8B588).withValues(alpha: 0.9);
        final bone = Paint()
          ..color = const Color(0xFFFFF8F0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7.5;

        canvas.drawCircle(Offset(center.dx - 60, center.dy - 20), 68, tissue);
        final facePath = Path();
        facePath.moveTo(center.dx - 80, center.dy - 65);
        facePath.lineTo(center.dx - 120, center.dy - 12);
        facePath.lineTo(center.dx - 105, center.dy);
        facePath.lineTo(center.dx - 112, center.dy + 15);
        facePath.lineTo(center.dx - 96, center.dy + 36);
        canvas.drawPath(facePath, bone);

        // Dolgun Yanak
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(center.dx - 70, center.dy + 5),
                width: 45,
                height: 35),
            Paint()..color = const Color(0xFFF4C49C));

        // Kapalı Göz
        canvas.drawArc(
          Rect.fromCenter(
              center: Offset(center.dx - 85, center.dy - 18),
              width: 24,
              height: 12),
          0,
          pi,
          false,
          Paint()
            ..color = const Color(0xFF8D5B36)
            ..strokeWidth = 4.5
            ..style = PaintingStyle.stroke,
        );

        // Geniş Gövde
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(center.dx + 25, center.dy + 35),
                width: 160,
                height: 110),
            tissue);
        // Kalp
        canvas.drawCircle(Offset(center.dx - 10, center.dy + 25), 14,
            Paint()..color = const Color(0xFFFF1744));
      } else {
        // 35-40 Hafta: Doğuma Hazır Tam Bebek
        final tissue = Paint()
          ..color = const Color(0xFFEEBF94).withValues(alpha: 0.95);
        final bone = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8;

        canvas.drawCircle(Offset(center.dx - 55, center.dy - 15), 76, tissue);
        final facePath = Path();
        facePath.moveTo(center.dx - 75, center.dy - 70);
        facePath.lineTo(center.dx - 125, center.dy - 10);
        facePath.lineTo(center.dx - 108, center.dy + 2);
        facePath.lineTo(center.dx - 116, center.dy + 20);
        facePath.lineTo(center.dx - 98, center.dy + 42);
        canvas.drawPath(facePath, bone);

        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(center.dx - 65, center.dy + 10),
                width: 52,
                height: 40),
            Paint()..color = const Color(0xFFF8CFA8));

        // Kapalı Göz
        canvas.drawArc(
          Rect.fromCenter(
              center: Offset(center.dx - 85, center.dy - 15),
              width: 26,
              height: 12),
          0,
          pi,
          false,
          Paint()
            ..color = const Color(0xFF7A4A28)
            ..strokeWidth = 5
            ..style = PaintingStyle.stroke,
        );

        // Büyük Gövde
        canvas.drawOval(
            Rect.fromCenter(
                center: Offset(center.dx + 35, center.dy + 40),
                width: 175,
                height: 125),
            tissue);
        // Kalp
        canvas.drawCircle(Offset(center.dx - 5, center.dy + 30), 15,
            Paint()..color = const Color(0xFFFF1744));
      }

      canvas.restore();

      final picture = recorder.endRecording();
      final img = await picture.toImage(width, height);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final file = File('assets/images/ultrasound_stage$stage.png');
      await file.writeAsBytes(buffer);
      print('Wrote assets/images/ultrasound_stage$stage.png');
    }
  });
}
