// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

void main() {
  final outDir = Directory(r'd:\github\hamilelik-app\assets\images');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  for (int stage = 1; stage <= 4; stage++) {
    final pngBytes = generateWombStagePng(stage);
    final file = File('${outDir.path}\\womb_stage$stage.png');
    file.writeAsBytesSync(pngBytes);
    print('Generated: ${file.path} (${pngBytes.length} bytes)');
  }
}

Uint8List generateWombStagePng(int stage) {
  const width = 480;
  const height = 360;

  // RGBA Pixel Buffer
  final rawData = Uint8List(height * (1 + width * 4));
  var offset = 0;

  const centerX = width / 2.0;
  const centerY = height / 2.0;

  for (int y = 0; y < height; y++) {
    rawData[offset++] = 0; // Filter type: None

    for (int x = 0; x < width; x++) {
      final dx = x - centerX;
      final dy = y - centerY;
      final distFromCenter = sqrt(dx * dx + dy * dy);

      // 1. Rahim Duvarı & Amniyotik Boşluk Arka Planı (Sıcak Kırmızı-Mürdüm Tonları)
      double r = 40 + (30 * (1.0 - (distFromCenter / 260).clamp(0.0, 1.0)));
      double g = 10 + (15 * (1.0 - (distFromCenter / 260).clamp(0.0, 1.0)));
      double b = 18 + (20 * (1.0 - (distFromCenter / 260).clamp(0.0, 1.0)));

      // Dış rahim halkası aydınlatması
      if (distFromCenter > 120 && distFromCenter < 220) {
        final wallIntensity = sin((distFromCenter - 120) / 100 * pi);
        r += wallIntensity * 160;
        g += wallIntensity * 40;
        b += wallIntensity * 55;
      }

      // 2. Fetus Evresi Çizimi
      if (stage == 1) {
        // 1-8. Hafta: Minik Embriyo & Gebelik Kesesi
        final embDx = dx - 10;
        final embDy = dy;
        final embDist = sqrt(embDx * embDx + embDy * embDy);
        if (embDist < 30) {
          final intensity = 1.0 - (embDist / 30);
          r = 240 * intensity + r * (1 - intensity);
          g = 200 * intensity + g * (1 - intensity);
          b = 180 * intensity + b * (1 - intensity);
        }
        // Kalp
        final heartDist = sqrt((dx - 5) * (dx - 5) + dy * dy);
        if (heartDist < 8) {
          r = 255;
          g = 50;
          b = 80;
        }
      } else if (stage == 2) {
        // 9-13. Hafta: 12. Hafta Erken Fetus
        final headDist = sqrt((dx + 40) * (dx + 40) + (dy + 25) * (dy + 25));
        final bodyDist = sqrt((dx - 15) * (dx - 15) + (dy - 10) * (dy - 10));

        if (headDist < 42) {
          final intensity = 1.0 - (headDist / 42);
          r = 245 * intensity + r * (1 - intensity);
          g = 185 * intensity + g * (1 - intensity);
          b = 160 * intensity + b * (1 - intensity);
        } else if (bodyDist < 50) {
          final intensity = 1.0 - (bodyDist / 50);
          r = 235 * intensity + r * (1 - intensity);
          g = 175 * intensity + g * (1 - intensity);
          b = 150 * intensity + b * (1 - intensity);
        }
      } else if (stage == 3) {
        // 14-27. Hafta: 2. Trimester Kıvrılmış Gerçek Fetus & Göbek Kordonu (Lennart Nilsson Stili)
        final headDist = sqrt((dx + 55) * (dx + 55) + (dy + 35) * (dy + 35));
        final bodyDist = sqrt((dx - 10) * (dx - 10) + (dy - 15) * (dy - 15));
        final limbDist = sqrt((dx + 15) * (dx + 15) + (dy - 55) * (dy - 55));

        // Kordon (Spiral kordon eğrisi)
        final cordY = sin(x * 0.05) * 25 + 10;
        if ((y - (centerY + cordY)).abs() < 9 && x > 140 && x < 380) {
          r = 255;
          g = 210;
          b = 215; // Parlak beyazımsı-pembe kordon
        } else if (headDist < 58) {
          // Baş ve Yüz Profili
          final intensity = 1.0 - (headDist / 58);
          r = 250 * intensity + r * (1 - intensity);
          g = 190 * intensity + g * (1 - intensity);
          b = 165 * intensity + b * (1 - intensity);
        } else if (bodyDist < 70) {
          // Gövde & Sırt
          final intensity = 1.0 - (bodyDist / 70);
          r = 240 * intensity + r * (1 - intensity);
          g = 175 * intensity + g * (1 - intensity);
          b = 150 * intensity + b * (1 - intensity);
        } else if (limbDist < 45) {
          // Bacaklar
          final intensity = 1.0 - (limbDist / 45);
          r = 245 * intensity + r * (1 - intensity);
          g = 180 * intensity + g * (1 - intensity);
          b = 155 * intensity + b * (1 - intensity);
        }
      } else {
        // 28-40. Hafta: 3. Trimester Dolgun Yanaklı Melek Bebek
        final headDist = sqrt((dx + 50) * (dx + 50) + (dy + 30) * (dy + 30));
        final bodyDist = sqrt((dx - 20) * (dx - 20) + (dy - 20) * (dy - 20));

        if (headDist < 70) {
          final intensity = 1.0 - (headDist / 70);
          r = 255 * intensity + r * (1 - intensity);
          g = 200 * intensity + g * (1 - intensity);
          b = 175 * intensity + b * (1 - intensity);
        } else if (bodyDist < 85) {
          final intensity = 1.0 - (bodyDist / 85);
          r = 245 * intensity + r * (1 - intensity);
          g = 185 * intensity + g * (1 - intensity);
          b = 160 * intensity + b * (1 - intensity);
        }
      }

      rawData[offset++] = r.clamp(0.0, 255.0).toInt();
      rawData[offset++] = g.clamp(0.0, 255.0).toInt();
      rawData[offset++] = b.clamp(0.0, 255.0).toInt();
      rawData[offset++] = 255; // Alpha
    }
  }

  // PNG Kodlama (Header + IHDR + IDAT + IEND)
  final compressed = zlib.encode(rawData);
  final png = BytesBuilder();

  // 1. Signature
  png.add([137, 80, 78, 71, 13, 10, 26, 10]);

  // 2. IHDR Chunk
  final ihdrData = ByteData(13);
  ihdrData.setUint32(0, width);
  ihdrData.setUint32(4, height);
  ihdrData.setUint8(8, 8); // Bit depth
  ihdrData.setUint8(9, 6); // ColorType: RGBA
  ihdrData.setUint8(10, 0); // Compression
  ihdrData.setUint8(11, 0); // Filter
  ihdrData.setUint8(12, 0); // Interlace
  _writeChunk(png, 'IHDR', ihdrData.buffer.asUint8List());

  // 3. IDAT Chunk
  _writeChunk(png, 'IDAT', Uint8List.fromList(compressed));

  // 4. IEND Chunk
  _writeChunk(png, 'IEND', Uint8List(0));

  return png.toBytes();
}

void _writeChunk(BytesBuilder builder, String type, Uint8List data) {
  final length = data.length;
  final lengthBytes = ByteData(4)..setUint32(0, length);
  builder.add(lengthBytes.buffer.asUint8List());

  final typeBytes = Uint8List.fromList(type.codeUnits);
  builder.add(typeBytes);

  if (length > 0) {
    builder.add(data);
  }

  final crcPayload = Uint8List(4 + length);
  crcPayload.setRange(0, 4, typeBytes);
  if (length > 0) {
    crcPayload.setRange(4, 4 + length, data);
  }
  final crc = _calculateCrc32(crcPayload);
  final crcBytes = ByteData(4)..setUint32(0, crc);
  builder.add(crcBytes.buffer.asUint8List());
}

int _calculateCrc32(Uint8List bytes) {
  int crc = 0xFFFFFFFF;
  for (int b in bytes) {
    crc ^= b;
    for (int i = 0; i < 8; i++) {
      if ((crc & 1) != 0) {
        crc = (crc >> 1) ^ 0xEDB88320;
      } else {
        crc = crc >> 1;
      }
    }
  }
  return crc ^ 0xFFFFFFFF;
}
