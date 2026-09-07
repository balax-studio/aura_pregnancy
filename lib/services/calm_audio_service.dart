import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Aura Pregnancy - Sakinleşme Çanı & Rahim İçi Akustik Ses Sentezleyicisi
/// Harici ses dosyası bağımlılığı olmadan, stüdyo kalitesinde saf PCM 16-bit WAV sesleri üretir.
class CalmAudioSynthesizer {
  static const int sampleRate = 44100;

  // Bellek içi ses önbelleği (Tek seferlik sentezlenir, anında çalınır)
  static final Map<String, Uint8List> _audioCache = {};

  /// 1. Sakinleşme Çanı: 432 Hz Solfeggio Tibet Meditasyon Kasesi & Zen Çanı
  static Uint8List getCalmBellWav() {
    return _audioCache.putIfAbsent('calm_bell', () {
      const double duration = 8.0; // 8 saniyelik rezonans döngüsü
      final int totalSamples = (duration * sampleRate).toInt();
      final Int16List samples = Int16List(totalSamples);

      // Harmonik frekanslar ve sönümleme katsayıları
      const double f0 = 432.0; // Temel Solfeggio huzur frekansı
      const double f1 = 432.0 * 2.76; // Metalik çan overtonu (~1192 Hz)
      const double f2 = 432.0 * 5.40; // İnce parıltı (~2332 Hz)
      const double f3 = 432.0 * 1.48; // Kase gövde rezonansı (~639 Hz)

      for (int i = 0; i < totalSamples; i++) {
        final double t = i / sampleRate;

        // Vuruş attack'ı (ilk 15 ms yumuşak yükseliş)
        final double attack = t < 0.015 ? (t / 0.015) : 1.0;

        // Üstel sönümlemeler (decay)
        final double d0 = math.exp(-t / 3.2);
        final double d1 = math.exp(-t / 1.8);
        final double d2 = math.exp(-t / 0.9);
        final double d3 = math.exp(-t / 2.6);

        // Kase tremolosu (2.2 Hz hafif titreşimli dalgalanma)
        final double tremolo = 1.0 + 0.06 * math.sin(2 * math.pi * 2.2 * t);

        // Bileşik dalga
        double sample = attack *
            tremolo *
            (0.55 * math.sin(2 * math.pi * f0 * t) * d0 +
                0.22 * math.sin(2 * math.pi * f3 * t) * d3 +
                0.14 * math.sin(2 * math.pi * f1 * t) * d1 +
                0.09 * math.sin(2 * math.pi * f2 * t) * d2);

        // Döngü sonu pürüzsüz sönümleme (loop clicking önleme)
        if (t > duration - 0.4) {
          final double fadeOut = (duration - t) / 0.4;
          sample *= fadeOut;
        }

        samples[i] = (sample.clamp(-1.0, 1.0) * 32767).toInt();
      }

      return _createWav(samples, sampleRate);
    });
  }

  /// 2. Anne Nabzı: 60 BPM Tamamen Cızırtısız, Tok, Derin ve Berrak Kalp Atışı
  static Uint8List getHeartbeatWav() {
    return _audioCache.putIfAbsent('heartbeat', () {
      const double duration = 6.0; // 6 tam saniye = 6 net fizyolojik vuruş
      final int totalSamples = (duration * sampleRate).toInt();
      final Int16List samples = Int16List(totalSamples);

      for (int i = 0; i < totalSamples; i++) {
        final double t = i / sampleRate;
        final double beatTime = t % 1.0; // Her saniye 1 vuruş döngüsü (60 BPM)

        double pulse = 0.0;

        // "Lub" (S1 Vuruşu - 0.00 ile 0.12 s arası, ~54 Hz tok kalp kası rezonansı)
        if (beatTime < 0.12) {
          final double pT = beatTime / 0.12;
          final double envelope = math.pow(math.sin(math.pi * pT), 2.0) as double;
          // Temel 54 Hz + sıcak 108 Hz overton (hiçbir gürültü/parazit yok)
          pulse += envelope *
              (0.85 * math.sin(2 * math.pi * 54.0 * beatTime) +
                  0.15 * math.sin(2 * math.pi * 108.0 * beatTime));
        }

        // "Dub" (S2 Vuruşu - 0.18 ile 0.27 s arası, ~76 Hz aortik kapanma)
        if (beatTime >= 0.18 && beatTime < 0.27) {
          final double pT = (beatTime - 0.18) / 0.09;
          final double envelope = math.pow(math.sin(math.pi * pT), 2.0) as double;
          pulse += 0.65 *
              envelope *
              (0.85 * math.sin(2 * math.pi * 76.0 * (beatTime - 0.18)) +
                  0.15 * math.sin(2 * math.pi * 152.0 * (beatTime - 0.18)));
        }

        // Vuruş aralarında %100 saf sessizlik, parazitsiz kristal netlik
        samples[i] = (pulse.clamp(-1.0, 1.0) * 32767).toInt();
      }

      return _createWav(samples, sampleRate);
    });
  }

  /// 3. Amniyotik Sıvı & Anne Karnı: Gerçek Rahim İçi Boğuk Su Uğultusu ve Plasental Akış
  static Uint8List getAmnioticFluidWav() {
    return _audioCache.putIfAbsent('amniotic_fluid', () {
      const double duration = 8.0; // 8 saniyelik kesintisiz döngü
      final int totalSamples = (duration * sampleRate).toInt();
      final Int16List samples = Int16List(totalSamples);
      final math.Random random = math.Random(1337);

      // İki kutuplu rezonanslı alçak geçiren filtre (Resonant Low-Pass Filter ~180 Hz)
      double filterState1 = 0.0;
      double filterState2 = 0.0;

      // Pembe gürültü üretici durumları
      double b0 = 0.0, b1 = 0.0, b2 = 0.0;

      for (int i = 0; i < totalSamples; i++) {
        final double t = i / sampleRate;

        // Anne aortası & plasenta kan akışı whoosh ritmi (~1.14 saniyede bir yumuşak sıvı akışı)
        final double flowCycle = (t % 1.14) / 1.14;
        final double flowEnvelope = 0.45 +
            0.55 * (math.pow(math.sin(math.pi * flowCycle), 1.6) as double);

        // Beyaz gürültüden pembe gürültüye dönüşüm
        final double white = random.nextDouble() * 2.0 - 1.0;
        b0 = 0.99765 * b0 + white * 0.0990460;
        b1 = 0.96300 * b1 + white * 0.1605524;
        b2 = 0.57000 * b2 + white * 0.5678465;
        final double rawFluid = (b0 + b1 + b2) * 0.28;

        // 180 Hz Anne karnı boğuk akustik filtreleme (Amniyotik sıvı yüksek frekansları tamamen yutar)
        filterState1 += 0.032 * (rawFluid - filterState1);
        filterState2 += 0.032 * (filterState1 - filterState2);

        // Derin su altı uğultusu (58 Hz & 88 Hz zengin sıvı rezonansı)
        final double deepWombHum = 0.14 * math.sin(2 * math.pi * 58.0 * t) +
            0.08 * math.sin(2 * math.pi * 88.0 * t);

        final double finalSample = (filterState2 * flowEnvelope * 2.8) + deepWombHum;
        samples[i] = (finalSample.clamp(-1.0, 1.0) * 32767).toInt();
      }

      return _createWav(samples, sampleRate);
    });
  }

  /// 4. Pembe Gürültü & Dinlendirici Yağmur: Sakin Başlayıp Kademeli Şiddetlenen Huzurlu Yağmur
  static Uint8List getPinkRainWav() {
    return _audioCache.putIfAbsent('pink_rain', () {
      const double duration = 12.0; // 12 saniyelik kademeli döngü
      final int totalSamples = (duration * sampleRate).toInt();
      final Int16List samples = Int16List(totalSamples);
      final math.Random random = math.Random(8888);

      double b0 = 0.0, b1 = 0.0, b2 = 0.0;
      double lpfRain = 0.0;

      for (int i = 0; i < totalSamples; i++) {
        final double t = i / sampleRate;

        // Yağmur Yoğunluk Eğrisi:
        // 0-3 sn: Sakin çiseleme (0.28)
        // 3-8 sn: Yavaş yavaş, huzur verici bir şekilde şiddetlenme (0.28 -> 0.85)
        // 8-10 sn: Dolgun ve dinlendirici tepe noktası (0.85)
        // 10-12 sn: Sakin başlangıç seviyesine pürüzsüz geri dönüş (0.85 -> 0.28)
        double rainIntensity;
        if (t < 3.0) {
          rainIntensity = 0.28 + 0.05 * (t / 3.0);
        } else if (t < 8.0) {
          final double progress = (t - 3.0) / 5.0;
          rainIntensity = 0.33 + 0.52 * (0.5 - 0.5 * math.cos(math.pi * progress));
        } else if (t < 10.0) {
          rainIntensity = 0.85;
        } else {
          final double progress = (t - 10.0) / 2.0;
          rainIntensity = 0.85 - 0.57 * progress;
        }

        // Paul Kellet Pembe Gürültü Filtresi (-3dB/oktav)
        final double white = random.nextDouble() * 2.0 - 1.0;
        b0 = 0.99765 * b0 + white * 0.0990460;
        b1 = 0.96300 * b1 + white * 0.1605524;
        b2 = 0.57000 * b2 + white * 0.5678465;
        final double pinkBase = (b0 + b1 + b2 + white * 0.45) * 0.16;

        // Yağmur damla dokusu (şiddetlendikçe pıtırtı sıklığı ve zenginliği artar)
        double raindropBurst = 0.0;
        final double dropThreshold = 0.0003 + 0.0016 * rainIntensity;
        if (random.nextDouble() < dropThreshold) {
          raindropBurst = (random.nextDouble() * 0.38 - 0.19) * rainIntensity;
        }

        // 3.5 kHz hafif yumuşatıcı alçak geçiren filtre (tiz patlamaları yumuşatır, huzur verir)
        final double rawRain = (pinkBase * rainIntensity) + raindropBurst;
        lpfRain += 0.25 * (rawRain - lpfRain);

        samples[i] = (lpfRain.clamp(-1.0, 1.0) * 32767).toInt();
      }

      return _createWav(samples, sampleRate);
    });
  }

  /// 5. Akustik Beyaz Gürültü: Kolik Yatıştırıcı, Dış Sesleri Maskeleyen Saf Uyku Frekansı
  static Uint8List getWhiteNoiseWav() {
    return _audioCache.putIfAbsent('white_noise', () {
      const double duration = 8.0;
      final int totalSamples = (duration * sampleRate).toInt();
      final Int16List samples = Int16List(totalSamples);
      final math.Random random = math.Random(5555);

      double lpfWhite = 0.0;

      for (int i = 0; i < totalSamples; i++) {
        // Saf Gauss benzeri beyaz gürültü
        final double u1 = random.nextDouble().clamp(1e-6, 1.0);
        final double u2 = random.nextDouble();
        final double normalNoise = math.sqrt(-2.0 * math.log(u1)) * math.cos(2.0 * math.pi * u2) * 0.18;

        // Bebek ve anne kulağını yormaması için 6.5 kHz üst-tiz tıraşlaması (tatlı hava akımı/şşş tınısı)
        lpfWhite += 0.38 * (normalNoise - lpfWhite);

        samples[i] = (lpfWhite.clamp(-1.0, 1.0) * 32767).toInt();
      }

      return _createWav(samples, sampleRate);
    });
  }

  /// 6. Sakinleştirici Ninni Kutusu: Celesta & Çan Tınılı Melodi
  static Uint8List getLullabyBoxWav() {
    return _audioCache.putIfAbsent('lullaby_box', () {
      const double duration = 8.0; // 8 saniyelik huzurlu arpej
      final int totalSamples = (duration * sampleRate).toInt();
      final Int16List samples = Int16List(totalSamples);

      // Ninni notaları: C4 (261.63), E4 (329.63), G4 (392.00), C5 (523.25), B4 (493.88), G4, E4, C4
      final List<_NoteEvent> melody = [
        _NoteEvent(0.00, 261.63, 0.70),
        _NoteEvent(1.00, 329.63, 0.65),
        _NoteEvent(2.00, 392.00, 0.70),
        _NoteEvent(3.00, 523.25, 0.75),
        _NoteEvent(4.00, 493.88, 0.70),
        _NoteEvent(5.00, 392.00, 0.65),
        _NoteEvent(6.00, 329.63, 0.65),
        _NoteEvent(7.00, 261.63, 0.70),
      ];

      for (int i = 0; i < totalSamples; i++) {
        final double t = i / sampleRate;
        double sample = 0.0;

        for (final note in melody) {
          if (t >= note.startTime && t < note.startTime + 2.0) {
            final double noteT = t - note.startTime;
            final double attack = noteT < 0.01 ? (noteT / 0.01) : 1.0;
            final double decay = math.exp(-noteT / 0.85);

            // Celesta / Çan tınısı: Temel + 2. harmonik + 3. harmonik
            final double tone = 0.65 * math.sin(2 * math.pi * note.freq * noteT) +
                0.25 * math.sin(2 * math.pi * note.freq * 2 * noteT) +
                0.10 * math.sin(2 * math.pi * note.freq * 3 * noteT);

            sample += attack * decay * tone * note.gain;
          }
        }

        // Döngü sonu pürüzsüzleştirme
        if (t > duration - 0.2) {
          final double fadeOut = (duration - t) / 0.2;
          sample *= fadeOut;
        }

        samples[i] = (sample.clamp(-1.0, 1.0) * 32767).toInt();
      }

      return _createWav(samples, sampleRate);
    });
  }

  /// 16-bit Mono PCM'den Standart RIFF WAVE Başlığı ve Byte Dizisi Üretici
  static Uint8List _createWav(Int16List samples, int sampleRate) {
    final int byteLength = samples.length * 2;
    final int totalLength = byteLength + 44;
    final Uint8List buffer = Uint8List(totalLength);
    final ByteData byteData = ByteData.sublistView(buffer);

    // RIFF chunk descriptor
    buffer[0] = 0x52; // 'R'
    buffer[1] = 0x49; // 'I'
    buffer[2] = 0x46; // 'F'
    buffer[3] = 0x46; // 'F'
    byteData.setUint32(4, totalLength - 8, Endian.little);
    buffer[8] = 0x57; // 'W'
    buffer[9] = 0x41; // 'A'
    buffer[10] = 0x56; // 'V'
    buffer[11] = 0x45; // 'E'

    // "fmt " sub-chunk
    buffer[12] = 0x66; // 'f'
    buffer[13] = 0x6D; // 'm'
    buffer[14] = 0x74; // 't'
    buffer[15] = 0x20; // ' '
    byteData.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
    byteData.setUint16(20, 1, Endian.little); // AudioFormat (1 = PCM)
    byteData.setUint16(22, 1, Endian.little); // NumChannels (1 = Mono)
    byteData.setUint32(24, sampleRate, Endian.little); // SampleRate
    byteData.setUint32(28, sampleRate * 2, Endian.little); // ByteRate
    byteData.setUint16(32, 2, Endian.little); // BlockAlign
    byteData.setUint16(34, 16, Endian.little); // BitsPerSample (16 bits)

    // "data" sub-chunk
    buffer[36] = 0x64; // 'd'
    buffer[37] = 0x61; // 'a'
    buffer[38] = 0x74; // 't'
    buffer[39] = 0x61; // 'a'
    byteData.setUint32(40, byteLength, Endian.little);

    // Sample kopyalama
    for (int i = 0; i < samples.length; i++) {
      byteData.setInt16(44 + (i * 2), samples[i], Endian.little);
    }

    return buffer;
  }
}

class _NoteEvent {
  final double startTime;
  final double freq;
  final double gain;
  _NoteEvent(this.startTime, this.freq, this.gain);
}

/// Sakinleşme Çanı ve Ambiyans Oynatıcı Yönetici Servisi
class CalmAudioService {
  CalmAudioService._internal();
  static final CalmAudioService instance = CalmAudioService._internal();

  AudioPlayer? _player;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      _player = AudioPlayer();
      await _player?.setReleaseMode(ReleaseMode.loop);
      _isInitialized = true;
    } catch (e) {
      debugPrint('CalmAudioService init error: $e');
    }
  }

  AudioPlayer get player {
    _player ??= AudioPlayer();
    return _player!;
  }

  /// Belirtilen parça ID'sine göre sesi anında sentezler ve döngüsel çalar
  Future<void> playTrack(String trackId, {double volume = 0.75}) async {
    try {
      await init();
      Uint8List wavBytes;
      switch (trackId) {
        case 'calm_bell':
          wavBytes = CalmAudioSynthesizer.getCalmBellWav();
          break;
        case 'heartbeat':
          wavBytes = CalmAudioSynthesizer.getHeartbeatWav();
          break;
        case 'amniotic_fluid':
        case 'amniotic_waves': // Geriye dönük uyumluluk
          wavBytes = CalmAudioSynthesizer.getAmnioticFluidWav();
          break;
        case 'pink_rain':
          wavBytes = CalmAudioSynthesizer.getPinkRainWav();
          break;
        case 'white_noise':
          wavBytes = CalmAudioSynthesizer.getWhiteNoiseWav();
          break;
        case 'lullaby_box':
          wavBytes = CalmAudioSynthesizer.getLullabyBoxWav();
          break;
        default:
          wavBytes = CalmAudioSynthesizer.getCalmBellWav();
      }

      await player.stop();
      await player.setVolume(volume);
      await player.setReleaseMode(ReleaseMode.loop);
      await player.play(BytesSource(wavBytes, mimeType: 'audio/wav'));
    } catch (e) {
      debugPrint('CalmAudioService playTrack error: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _player?.setVolume(volume);
    } catch (e) {
      debugPrint('CalmAudioService setVolume error: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _player?.pause();
    } catch (e) {
      debugPrint('CalmAudioService pause error: $e');
    }
  }

  Future<void> resume() async {
    try {
      await _player?.resume();
    } catch (e) {
      debugPrint('CalmAudioService resume error: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _player?.stop();
    } catch (e) {
      debugPrint('CalmAudioService stop error: $e');
    }
  }

  Future<void> dispose() async {
    try {
      await _player?.stop();
      await _player?.dispose();
      _player = null;
      _isInitialized = false;
    } catch (e) {
      debugPrint('CalmAudioService dispose error: $e');
    }
  }
}
