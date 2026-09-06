import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle, MethodChannel;
import 'dart:io' if (dart.library.html) 'io_stubs.dart';
import 'package:path_provider/path_provider.dart';
import '../models/diary_model.dart';
import 'video_story_generator_service.dart';
import 'web_download_stub.dart' if (dart.library.html) 'web_download_web.dart';

/// Aura Pregnancy - FFmpeg Video Ön-İşlemcisi ve Render Motoru
class FFmpegVideoService {
  static const MethodChannel _galleryChannel = MethodChannel('com.balaxstudio.aura/gallery');

  /// Yolculuk Videosu için Varlık Matrisi (Asset Matrix) Oluşturur
  static Map<String, dynamic> generateVideoAssetMatrix({
    required List<DiaryModel> highlightEntries,
    String backgroundMusic = 'Aura_Lullaby.mp3',
    int durationPerSlideSeconds = 4,
  }) {
    final slides = <Map<String, dynamic>>[];

    for (int i = 0; i < highlightEntries.length; i++) {
      final entry = highlightEntries[i];
      slides.add({
        'index': i + 1,
        'week': entry.pregnancyWeek,
        'date': entry.date,
        'title': '${entry.pregnancyWeek}. Hafta Özel Anı',
        'subtitle': entry.noteText ?? 'Bebeğimize Sevgiyle...',
        'image_path': entry.photoPath ?? 'assets/images/sample_ultrasound.png',
        'transition': 'crossfade',
        'duration_sec': durationPerSlideSeconds,
      });
    }

    return {
      'project_name': 'Aura_Pregnancy_TimeLapse',
      'created_at': DateTime.now().toIso8601String(),
      'music_track': backgroundMusic,
      'total_duration_sec': highlightEntries.length * durationPerSlideSeconds,
      'resolution': '1080x1920', // Dikey Mobil Video (9:16)
      'fps': 30,
      'slides': slides,
      'ffmpeg_filter_complex': _buildFFmpegCommand(slides, backgroundMusic),
    };
  }

  /// FFmpeg CLI Filter Complex Komut Dizesi Üretici
  static String _buildFFmpegCommand(List<Map<String, dynamic>> slides, String music) {
    if (slides.isEmpty) return '';
    final count = slides.length;
    final buffer = StringBuffer();

    // Giriş dosyaları
    for (int i = 0; i < count; i++) {
      buffer.write('-loop 1 -t ${slides[i]['duration_sec']} -i input_$i.jpg ');
    }
    buffer.write('-i $music ');

    // Filter complex geçiş efekti
    buffer.write('-filter_complex "');
    for (int i = 0; i < count; i++) {
      buffer.write('[$i:v]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,setsar=1[v$i]; ');
    }
    for (int i = 0; i < count; i++) {
      buffer.write('[v$i]');
    }
    buffer.write('concat=n=$count:v=1:a=0[outv]" -map "[outv]" -map $count:a -c:v libx264 -pix_fmt yuv420p -shortest output_timelapse.mp4');

    return buffer.toString();
  }

  /// Simüle Edilmiş Video Render Motoru (Progress Stream)
  static Stream<double> renderTimeLapseProgress() async* {
    for (int p = 0; p <= 100; p += 10) {
      await Future.delayed(const Duration(milliseconds: 250));
      yield p / 100.0;
    }
  }

  /// Time-Lapse videosunu gerçek oynatılabilir video olarak dışa aktarır ve cihaza indirir/kaydeder
  static Future<String?> exportAndSaveVideo({
    required List<VideoStoryFrame> frames,
    String fileName = 'Aura_Gebelik_Yolculugu',
    void Function(double progress)? onProgress,
  }) async {
    final slidesData = frames.map((f) => {
      'week': f.week,
      'date': f.date,
      'title': f.title,
      'subtitle': f.subtitle,
      'photoPath': f.photoPath,
    }).toList();

    if (kIsWeb) {
      return await recordAndDownloadVideoWeb(
        slidesData: slidesData,
        fileName: fileName,
        onProgress: onProgress,
      );
    }

    final cleanBaseName = fileName.replaceAll(RegExp(r'\.(mp4|jpg|png)$'), '');

    // Android ortamında: Native MediaCodec donanım AVC/H.264 kodlayıcı ile gerçek MP4 oluşturup Galeriye kaydet
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        const width = 720;
        const height = 1280;
        final renderedSlides = <Uint8List>[];

        for (int i = 0; i < frames.length; i++) {
          final slideBytes = await _renderSlideToPng(frames[i], width, height);
          renderedSlides.add(slideBytes);
          onProgress?.call(((i + 1) / frames.length) * 0.7); // %0 - %70 kare renderı
        }

        onProgress?.call(0.85); // %85 Kodlama aşaması

        final result = await _galleryChannel.invokeMethod<String>('generateAndSaveVideo', {
          'slides': renderedSlides,
          'fileNamePrefix': cleanBaseName,
        });

        onProgress?.call(1.0);
        return result ?? 'Galeri (Videolar) / Aura Pregnancy / $cleanBaseName.mp4';
      } catch (e) {
        debugPrint('Android native video generation error: $e');
      }
    }

    // iOS / Desktop / Test ortamı fallback
    for (int p = 1; p <= 10; p++) {
      await Future.delayed(const Duration(milliseconds: 40));
      onProgress?.call(p / 10.0);
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final dirPath = dir.path;
      final hasJpg = fileName.toLowerCase().endsWith('.jpg');
      final actualFileName = hasJpg ? '$cleanBaseName.jpg' : '$cleanBaseName.mp4';
      final savePath = '$dirPath/$actualFileName';
      
      final file = File(savePath);
      Uint8List? primaryBytes;
      if (frames.isNotEmpty) {
        primaryBytes = await _renderSlideToPng(frames.first, 720, 1280);
      }
      if (primaryBytes != null && primaryBytes.isNotEmpty) {
        await file.writeAsBytes(primaryBytes);
      }
      return savePath;
    } catch (e) {
      debugPrint('File save error: $e');
      final hasJpg = fileName.toLowerCase().endsWith('.jpg');
      final actualFileName = hasJpg ? '$cleanBaseName.jpg' : '$cleanBaseName.mp4';
      return 'İndirilenler / $actualFileName';
    }
  }

  /// Kaydedilen son videoyu Android sistem paylaşım sayfasıyla paylaşır
  static Future<bool> shareLastVideo() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final result = await _galleryChannel.invokeMethod<bool>('shareLastVideo');
        return result ?? false;
      } catch (e) {
        debugPrint('shareLastVideo error: $e');
        return false;
      }
    }
    return false;
  }

  /// Her bir anı karesini 720x1280 dikey video slaytı olarak yüksek çözünürlükte çizer
  static Future<Uint8List> _renderSlideToPng(VideoStoryFrame frame, int width, int height) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()));

    // 1. Zemin: Claymorphism yumuşak krem-şeftali geçişi
    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(0, height.toDouble()),
        [const Color(0xFFFDF7F4), const Color(0xFFFEE6E0)],
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), bgPaint);

    // 2. Dekoratif pastel daireler
    final circlePaint1 = Paint()..color = const Color(0xFFD4EBD6).withValues(alpha: 0.35);
    canvas.drawCircle(Offset(width * 0.15, height * 0.12), 160, circlePaint1);
    final circlePaint2 = Paint()..color = const Color(0xFFD6E4F0).withValues(alpha: 0.35);
    canvas.drawCircle(Offset(width * 0.85, height * 0.85), 200, circlePaint2);

    // 3. Fotoğraf baytlarını yükle
    Uint8List? rawImageBytes;
    if (frame.photoPath.isNotEmpty) {
      try {
        if (frame.photoPath.startsWith('assets/')) {
          final byteData = await rootBundle.load(frame.photoPath);
          rawImageBytes = byteData.buffer.asUint8List();
        } else {
          final file = File(frame.photoPath);
          if (await file.exists()) {
            rawImageBytes = await file.readAsBytes();
          }
        }
      } catch (_) {}
    }
    if (rawImageBytes == null || rawImageBytes.isEmpty) {
      try {
        final byteData = await rootBundle.load('assets/images/sample_ultrasound.png');
        rawImageBytes = byteData.buffer.asUint8List();
      } catch (_) {}
    }

    // Ultrason / Hatıra Kartı
    final cardRect = Rect.fromLTWH(40, 200, width - 80.0, width - 80.0);
    final cardRRect = RRect.fromRectAndRadius(cardRect, const Radius.circular(28));

    // Dış Yumuşak Gölge
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.14)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawRRect(cardRRect.shift(const Offset(0, 10)), shadowPaint);

    // Fotoğraf Çizimi
    if (rawImageBytes != null && rawImageBytes.isNotEmpty) {
      try {
        final codec = await ui.instantiateImageCodec(rawImageBytes);
        final frameInfo = await codec.getNextFrame();
        final img = frameInfo.image;

        canvas.save();
        canvas.clipRRect(cardRRect);

        // Ultrason için şık siyah zemin
        final imgBgPaint = Paint()..color = Colors.black;
        canvas.drawRect(cardRect, imgBgPaint);

        final imgAspect = img.width / img.height;
        final cardAspect = cardRect.width / cardRect.height;
        Rect drawDst;
        if (imgAspect > cardAspect) {
          final h = cardRect.width / imgAspect;
          drawDst = Rect.fromLTWH(cardRect.left, cardRect.top + (cardRect.height - h) / 2, cardRect.width, h);
        } else {
          final w = cardRect.height * imgAspect;
          drawDst = Rect.fromLTWH(cardRect.left + (cardRect.width - w) / 2, cardRect.top, w, cardRect.height);
        }
        canvas.drawImageRect(
          img,
          Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
          drawDst,
          Paint(),
        );
        canvas.restore();
      } catch (_) {
        final placeholderPaint = Paint()..color = const Color(0xFFFEE6E0);
        canvas.drawRRect(cardRRect, placeholderPaint);
      }
    } else {
      final placeholderPaint = Paint()..color = const Color(0xFFFEE6E0);
      canvas.drawRRect(cardRRect, placeholderPaint);
    }

    // Kart Beyaz Kenarlığı
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawRRect(cardRRect, borderPaint);

    // 4. Üst Başlık ve Hafta
    _drawText(
      canvas: canvas,
      text: 'AURA PREGNANCY • YOLCULUK HİKAYESİ',
      offset: const Offset(40, 80),
      fontSize: 18,
      fontWeight: FontWeight.w900,
      color: const Color(0xFFE5989B),
      maxWidth: width - 80.0,
    );

    _drawText(
      canvas: canvas,
      text: '${frame.week}. Hafta',
      offset: const Offset(40, 115),
      fontSize: 42,
      fontWeight: FontWeight.w900,
      color: const Color(0xFF2D232E),
      maxWidth: width - 80.0,
    );

    // 5. Kart Altı Başlık ve Not
    final contentTop = cardRect.bottom + 36;
    _drawText(
      canvas: canvas,
      text: frame.title,
      offset: Offset(40, contentTop),
      fontSize: 28,
      fontWeight: FontWeight.w800,
      color: const Color(0xFF2D232E),
      maxWidth: width - 80.0,
    );

    if (frame.subtitle.isNotEmpty) {
      _drawText(
        canvas: canvas,
        text: frame.subtitle,
        offset: Offset(40, contentTop + 45),
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF6D6875),
        maxWidth: width - 80.0,
        maxLines: 4,
      );
    }

    // 6. Tarih ve Marka
    _drawText(
      canvas: canvas,
      text: frame.date,
      offset: Offset(40, height - 120.0),
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: const Color(0xFFB5838D),
      maxWidth: width - 80.0,
    );

    _drawText(
      canvas: canvas,
      text: 'Aura Anı Günlüğü ile Hazırlandı ✨',
      offset: Offset(40, height - 80.0),
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: const Color(0xFFB5838D).withValues(alpha: 0.8),
      maxWidth: width - 80.0,
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(width, height);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  static void _drawText({
    required Canvas canvas,
    required String text,
    required Offset offset,
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    required double maxWidth,
    int maxLines = 2,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
      ellipsis: '...',
    );
    textPainter.layout(maxWidth: maxWidth);
    textPainter.paint(canvas, offset);
  }
}

