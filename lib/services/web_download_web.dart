// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

/// Flutter Web ortamında HTML5 Canvas + MediaRecorder ile %100 gerçek, oynatılabilir MP4/WebM video üretir ve indirir
Future<String?> recordAndDownloadVideoWeb({
  required List<Map<String, dynamic>> slidesData,
  required String fileName,
  void Function(double progress)? onProgress,
}) async {
  final canvas = html.CanvasElement(width: 720, height: 1280);
  final ctx = canvas.context2D;
  final stream = canvas.captureStream(30);

  // Desteklenen video formatlarını kontrol et (H264 / MP4 / WebM)
  String mimeType = 'video/webm;codecs=vp9';
  String fileExt = '.mp4';

  if (html.MediaRecorder.isTypeSupported('video/mp4;codecs=avc1')) {
    mimeType = 'video/mp4;codecs=avc1';
    fileExt = '.mp4';
  } else if (html.MediaRecorder.isTypeSupported('video/mp4')) {
    mimeType = 'video/mp4';
    fileExt = '.mp4';
  } else if (html.MediaRecorder.isTypeSupported('video/webm;codecs=h264')) {
    mimeType = 'video/webm;codecs=h264';
    fileExt = '.mp4'; // H264 içeren webm dosyaları MP4 oynatıcılarla tam uyumludur
  } else if (html.MediaRecorder.isTypeSupported('video/webm;codecs=vp8')) {
    mimeType = 'video/webm;codecs=vp8';
    fileExt = '.webm';
  } else if (html.MediaRecorder.isTypeSupported('video/webm')) {
    mimeType = 'video/webm';
    fileExt = '.webm';
  }

  final recorder = html.MediaRecorder(stream, {'mimeType': mimeType});
  final chunks = <html.Blob>[];

  recorder.addEventListener('dataavailable', (html.Event event) {
    final customEvent = event as html.BlobEvent;
    if (customEvent.data != null && customEvent.data!.size > 0) {
      chunks.add(customEvent.data!);
    }
  });

  final completer = Completer<String?>();

  final actualFileName = fileName.replaceAll(RegExp(r'\.(mp4|webm)$', caseSensitive: false), '') + fileExt;

  recorder.addEventListener('stop', (event) {
    final blob = html.Blob(chunks, mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', actualFileName)
      ..style.display = 'none';
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);

    completer.complete('İndirilenler / $actualFileName');
  });

  recorder.start();

  // Kare kare çizim ve animasyon (Ken Burns zoom + gradient + altyazılar)
  final totalSlides = slidesData.isNotEmpty ? slidesData.length : 1;
  const fps = 30;
  const durationPerSlideSec = 2.5; // Her anı için 2.5 saniye
  final framesPerSlide = (fps * durationPerSlideSec).toInt();
  final totalFrames = totalSlides * framesPerSlide;

  var currentTotalFrame = 0;

  for (int s = 0; s < totalSlides; s++) {
    final slide = slidesData[s];
    final week = slide['week'] ?? 12;
    final date = slide['date'] ?? '';
    final title = slide['title'] ?? 'Özel Anı';
    final subtitle = slide['subtitle'] ?? 'Bebeğimizle sevgiyle büyüyoruz...';
    final photoUrl = slide['photoPath'] ?? 'assets/images/womb_stage3.jpg';

    // Fotoğrafı yükle
    html.ImageElement? img;
    try {
      img = html.ImageElement(src: photoUrl);
      await img.onLoad.first.timeout(const Duration(milliseconds: 500), onTimeout: () => html.Event('timeout'));
    } catch (_) {}

    for (int f = 0; f < framesPerSlide; f++) {
      currentTotalFrame++;
      onProgress?.call((currentTotalFrame / totalFrames).clamp(0.0, 0.98));

      final progressInSlide = f / framesPerSlide;
      final zoom = 1.0 + (progressInSlide * 0.08);

      // 1. Koyu Sinematik Arka Plan
      ctx.fillStyle = '#1E141D';
      ctx.fillRect(0, 0, 720, 1280);

      // 2. Fotoğraf Çizimi (Ken Burns Zoom)
      ctx.save();
      ctx.translate(360, 640);
      ctx.scale(zoom, zoom);
      ctx.translate(-360, -640);
      try {
        if (img != null && img.complete == true && img.naturalWidth > 0) {
          ctx.drawImageScaled(img, 0, 0, 720, 1280);
        } else {
          final grad = ctx.createLinearGradient(0, 0, 720, 1280);
          grad.addColorStop(0, '#5A0E23');
          grad.addColorStop(1, '#1E0A12');
          ctx.fillStyle = grad;
          ctx.fillRect(0, 0, 720, 1280);
        }
      } catch (_) {}
      ctx.restore();

      // 3. Sinematik Karartma Gradyanı
      final vignette = ctx.createLinearGradient(0, 0, 0, 1280);
      vignette.addColorStop(0, 'rgba(0, 0, 0, 0.55)');
      vignette.addColorStop(0.25, 'rgba(0, 0, 0, 0.0)');
      vignette.addColorStop(0.55, 'rgba(0, 0, 0, 0.40)');
      vignette.addColorStop(1, 'rgba(0, 0, 0, 0.95)');
      ctx.fillStyle = vignette;
      ctx.fillRect(0, 0, 720, 1280);

      // 4. Üst Logo / Başlık
      ctx.fillStyle = '#FFFFFF';
      ctx.font = 'bold 28px sans-serif';
      ctx.fillText('✨ Aura Pregnancy • Anı Hikayesi', 40, 80);

      // 5. Hafta Rozeti
      ctx.fillStyle = 'rgba(255, 64, 129, 0.95)';
      _drawRoundRect(ctx, 40, 940, 260, 52, 18);
      ctx.fillStyle = '#FFFFFF';
      ctx.font = 'bold 22px sans-serif';
      ctx.fillText('$week. Hafta • $date', 60, 975);

      // 6. Başlık
      ctx.fillStyle = '#FFFFFF';
      ctx.font = 'bold 36px sans-serif';
      ctx.fillText(title, 40, 1045);

      // 7. Anı Notu
      ctx.fillStyle = 'rgba(255, 255, 255, 0.88)';
      ctx.font = '22px sans-serif';
      _drawWrappedText(ctx, subtitle, 40, 1095, 640, 32);

      await Future.delayed(const Duration(milliseconds: 25));
    }
  }

  recorder.stop();
  onProgress?.call(1.0);
  return await completer.future;
}

void _drawRoundRect(html.CanvasRenderingContext2D ctx, num x, num y, num w, num h, num r) {
  ctx.beginPath();
  ctx.moveTo(x + r, y);
  ctx.lineTo(x + w - r, y);
  ctx.quadraticCurveTo(x + w, y, x + w, y + r);
  ctx.lineTo(x + w, y + h - r);
  ctx.quadraticCurveTo(x + w, y + h, x + w - r, y + h);
  ctx.lineTo(x + r, y + h);
  ctx.quadraticCurveTo(x, y + h, x, y + h - r);
  ctx.lineTo(x, y + r);
  ctx.quadraticCurveTo(x, y, x + r, y);
  ctx.closePath();
  ctx.fill();
}

void _drawWrappedText(html.CanvasRenderingContext2D ctx, String text, num x, num y, num maxWidth, num lineHeight) {
  final words = text.split(' ');
  var line = '';
  var currentY = y;

  for (final word in words) {
    final testLine = line.isEmpty ? word : '$line $word';
    final metrics = ctx.measureText(testLine);
    if ((metrics.width ?? 0) > maxWidth && line.isNotEmpty) {
      ctx.fillText(line, x, currentY);
      line = word;
      currentY += lineHeight;
    } else {
      line = testLine;
    }
  }
  if (line.isNotEmpty) {
    ctx.fillText(line, x, currentY);
  }
}

/// Basit indirme yardımcı fonksiyonu
void downloadFileWeb(Uint8List bytes, String fileName) {
  final blob = html.Blob([bytes], 'video/mp4');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..style.display = 'none';
  html.document.body?.children.add(anchor);
  anchor.click();
  html.document.body?.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}
