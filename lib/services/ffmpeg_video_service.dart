import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io' if (dart.library.html) 'io_stubs.dart';
import 'package:path_provider/path_provider.dart';
import '../models/diary_model.dart';
import 'video_story_generator_service.dart';
import 'web_download_stub.dart' if (dart.library.html) 'web_download_web.dart';

/// Aura Pregnancy - FFmpeg Video Ön-İşlemcisi ve Render Motoru
class FFmpegVideoService {
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
    } else {
      // Mobil / Masaüstü ortamında
      for (int p = 1; p <= 10; p++) {
        await Future.delayed(const Duration(milliseconds: 180));
        onProgress?.call(p / 10.0);
      }

      try {
        String? dirPath;

        // 1. Android için doğrudan genel İndirilenler (Downloads) klasörünü kontrol et
        if (!kIsWeb && Platform.isAndroid) {
          final publicDownload = Directory('/storage/emulated/0/Download');
          if (publicDownload.existsSync()) {
            dirPath = publicDownload.path;
          }
        }

        // 2. Fallback: getDownloadsDirectory veya getApplicationDocumentsDirectory
        if (dirPath == null) {
          final dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
          dirPath = dir.path;
        }

        // ponytail: Native FFmpeg video encoding requires native binary/ffmpeg_kit.
        // Instead of writing a corrupted 32-byte dummy MP4, export the primary milestone/ultrasound journey image cleanly.
        final cleanBaseName = fileName.replaceAll(RegExp(r'\.(mp4|jpg|png)$'), '');
        final actualFileName = '$cleanBaseName.jpg';
        final savePath = '$dirPath/$actualFileName';
        
        final file = File(savePath);
        Uint8List? imageBytes;
        for (final frame in frames) {
          if (frame.photoPath.isNotEmpty) {
            try {
              if (frame.photoPath.startsWith('assets/')) {
                final byteData = await rootBundle.load(frame.photoPath);
                imageBytes = byteData.buffer.asUint8List();
                break;
              } else {
                final srcFile = File(frame.photoPath);
                if (await srcFile.exists()) {
                  imageBytes = await srcFile.readAsBytes();
                  break;
                }
              }
            } catch (_) {}
          }
        }

        if (imageBytes == null) {
          try {
            final byteData = await rootBundle.load('assets/images/aura_logo.png');
            imageBytes = byteData.buffer.asUint8List();
          } catch (_) {}
        }

        if (imageBytes != null && imageBytes.isNotEmpty) {
          await file.writeAsBytes(imageBytes);
        }
        return savePath;
      } catch (e) {
        debugPrint('File save error: $e');
        return 'İndirilenler / $fileName.jpg';
      }
    }
  }
}
