import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dart:io' if (dart.library.html) 'io_stubs.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Aura Pregnancy - Gerçek Mikrofon Ses Kayıt Servisi (Audio Recording Service)
class AudioRecordingService extends ChangeNotifier {
  AudioRecordingService._internal();
  static final AudioRecordingService instance = AudioRecordingService._internal();

  AudioRecorder? _audioRecorder;
  bool _isRecording = false;
  bool _isPaused = false;
  int _secondsElapsed = 0;
  Timer? _recordingTimer;
  final List<double> _waveforms = [];
  String? _currentRecordingPath;
  String? _lastErrorMessage;

  bool get isRecording => _isRecording;
  bool get isPaused => _isPaused;
  int get secondsElapsed => _secondsElapsed;
  List<double> get waveforms => List.unmodifiable(_waveforms);
  String? get currentRecordingPath => _currentRecordingPath;
  String? get lastErrorMessage => _lastErrorMessage;

  AudioRecorder get recorder {
    _audioRecorder ??= AudioRecorder();
    return _audioRecorder!;
  }

  String get formattedDuration {
    final minutes = (_secondsElapsed ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsElapsed % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Mikrofon İznini Kontrol Et ve İste
  Future<bool> checkAndRequestPermission() async {
    if (kIsWeb) return true;

    final status = await Permission.microphone.request();
    if (status.isGranted || status.isLimited) {
      _lastErrorMessage = null;
      return true;
    }

    if (status.isPermanentlyDenied) {
      _lastErrorMessage = 'audio_mic_perm_denied_permanent'.tr();
    } else {
      _lastErrorMessage = 'audio_mic_perm_denied'.tr();
    }
    notifyListeners();
    return false;
  }

  /// Gerçek Ses Kaydını Başlat
  Future<bool> startRecording() async {
    _lastErrorMessage = null;
    final hasPerm = await checkAndRequestPermission();
    if (!hasPerm) {
      return false;
    }

    try {
      final rec = recorder;

      // Kayıt dizinini hazırla
      String filePath;
      if (!kIsWeb) {
        final appDocDir = await getApplicationDocumentsDirectory();
        final recordingsDir = Directory(p.join(appDocDir.path, 'aura_audio_letters'));
        if (!await recordingsDir.exists()) {
          await recordingsDir.create(recursive: true);
        }
        final fileName = 'voice_letter_${DateTime.now().millisecondsSinceEpoch}.m4a';
        filePath = p.join(recordingsDir.path, fileName);
      } else {
        filePath = 'voice_letter_${DateTime.now().millisecondsSinceEpoch}.m4a';
      }

      _currentRecordingPath = filePath;

      // Gerçek donanım kaydını başlat (AAC/m4a formatı)
      await rec.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: filePath,
      );

      _isRecording = true;
      _isPaused = false;
      _secondsElapsed = 0;
      _waveforms.clear();
      _waveforms.addAll([0.2, 0.4, 0.3, 0.5, 0.3]);
      notifyListeners();

      _recordingTimer?.cancel();
      _recordingTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) async {
        if (!_isPaused && _isRecording) {
          if (timer.tick % 5 == 0) {
            _secondsElapsed++;
          }

          // Gerçek mikrofondan anlık ses genliğini al
          try {
            final amp = await rec.getAmplitude();
            // dBFS değeri (-60dB ile 0dB arasında döner)
            final currentDb = amp.current;
            // 0.0 - 1.0 aralığına normalize et
            double normalized = 0.15;
            if (currentDb > -60) {
              normalized = ((currentDb + 60) / 60).clamp(0.15, 1.0);
            }
            _waveforms.add(normalized);
            if (_waveforms.length > 28) {
              _waveforms.removeAt(0);
            }
          } catch (_) {
            _waveforms.add(0.25);
            if (_waveforms.length > 28) {
              _waveforms.removeAt(0);
            }
          }

          notifyListeners();
        }
      });

      return true;
    } catch (e) {
      debugPrint('Audio recording start error: $e');
      _lastErrorMessage = 'Ses kaydı başlatılırken hata oluştu: $e';
      _isRecording = false;
      notifyListeners();
      return false;
    }
  }

  /// Kaydı Duraklat / Devam Ettir
  Future<void> togglePause() async {
    if (!_isRecording) return;
    try {
      final rec = recorder;
      if (_isPaused) {
        await rec.resume();
        _isPaused = false;
      } else {
        await rec.pause();
        _isPaused = true;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Audio recording togglePause error: $e');
    }
  }

  /// Kaydı Tamamla ve Ses Dosyası Yolunu Döndür
  Future<Map<String, dynamic>?> stopRecording() async {
    _recordingTimer?.cancel();
    _recordingTimer = null;

    final totalSec = _secondsElapsed > 0 ? _secondsElapsed : 1;
    String? finalPath;

    try {
      final rec = recorder;
      finalPath = await rec.stop();
      finalPath ??= _currentRecordingPath;
    } catch (e) {
      debugPrint('Audio recording stop error: $e');
      finalPath = _currentRecordingPath;
    }

    _isRecording = false;
    _isPaused = false;
    _secondsElapsed = 0;
    _waveforms.clear();
    notifyListeners();

    if (finalPath == null || finalPath.isEmpty) {
      return null;
    }

    return {
      'path': finalPath,
      'duration_sec': totalSec,
      'formatted_duration': '${(totalSec ~/ 60).toString().padLeft(2, '0')}:${(totalSec % 60).toString().padLeft(2, '0')}',
    };
  }

  /// Kaydı İptal Et ve Dosyayı Temizle
  Future<void> cancelRecording() async {
    _recordingTimer?.cancel();
    _recordingTimer = null;

    try {
      final rec = recorder;
      final path = await rec.stop();
      if (path != null && !kIsWeb) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Audio recording cancel error: $e');
    }

    _isRecording = false;
    _isPaused = false;
    _secondsElapsed = 0;
    _waveforms.clear();
    _currentRecordingPath = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _audioRecorder?.dispose();
    super.dispose();
  }
}

/// Aura Pregnancy - Gerçek Ses Çalma Servisi (Audio Playback Service)
class AudioPlaybackService extends ChangeNotifier {
  AudioPlaybackService._internal() {
    _initPlayerListeners();
  }
  static final AudioPlaybackService instance = AudioPlaybackService._internal();

  AudioPlayer? _player;
  String? _currentPlayingPath;
  bool _isPlaying = false;
  bool _isPaused = false;
  int _positionSeconds = 0;
  int _totalDurationSeconds = 0;
  StreamSubscription? _posSub;
  StreamSubscription? _durSub;
  StreamSubscription? _stateSub;
  StreamSubscription? _completeSub;

  String? get currentPlayingPath => _currentPlayingPath;
  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  int get positionSeconds => _positionSeconds;
  int get totalDurationSeconds => _totalDurationSeconds;

  AudioPlayer get player {
    _player ??= AudioPlayer();
    return _player!;
  }

  double get progressRatio {
    if (_totalDurationSeconds <= 0) return 0.0;
    return (_positionSeconds / _totalDurationSeconds).clamp(0.0, 1.0);
  }

  String formatTime(int totalSec) {
    final minutes = (totalSec ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSec % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _initPlayerListeners() {
    final p = player;

    _posSub?.cancel();
    _posSub = p.onPositionChanged.listen((pos) {
      _positionSeconds = pos.inSeconds;
      notifyListeners();
    });

    _durSub?.cancel();
    _durSub = p.onDurationChanged.listen((dur) {
      if (dur.inSeconds > 0) {
        _totalDurationSeconds = dur.inSeconds;
        notifyListeners();
      }
    });

    _completeSub?.cancel();
    _completeSub = p.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _isPaused = false;
      _positionSeconds = 0;
      notifyListeners();
    });

    _stateSub?.cancel();
    _stateSub = p.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      _isPaused = state == PlayerState.paused;
      notifyListeners();
    });
  }

  /// Ses Çalmaya Başla
  Future<void> play(String audioPath, {int durationSeconds = 0}) async {
    final p = player;

    // Aynı ses çalıyorsa ve duraklatılmışsa devam et
    if (_currentPlayingPath == audioPath && _isPaused) {
      await resume();
      return;
    }

    // Farklı ses veya yeni başlangıç
    try {
      await p.stop();
      _currentPlayingPath = audioPath;
      _positionSeconds = 0;
      _totalDurationSeconds = durationSeconds > 0 ? durationSeconds : 0;
      _isPlaying = true;
      _isPaused = false;
      notifyListeners();

      if (audioPath.startsWith('assets/')) {
        // Asset sesi (örn. assets/audio/voice_letter.m4a)
        final assetSourcePath = audioPath.replaceFirst('assets/', '');
        await p.play(AssetSource(assetSourcePath));
      } else if (!kIsWeb && File(audioPath).existsSync()) {
        // Cihazdaki yerel dosya
        await p.play(DeviceFileSource(audioPath));
      } else {
        // Fallback veya URL
        await p.play(AssetSource('audio/voice_letter.m4a'));
      }
    } catch (e) {
      debugPrint('AudioPlaybackService play error: $e');
      _isPlaying = false;
      _isPaused = false;
      notifyListeners();
    }
  }

  /// Duraklat
  Future<void> pause() async {
    if (_isPlaying) {
      try {
        await player.pause();
        _isPaused = true;
        _isPlaying = false;
        notifyListeners();
      } catch (e) {
        debugPrint('AudioPlaybackService pause error: $e');
      }
    }
  }

  /// Devam Et
  Future<void> resume() async {
    if (_isPaused) {
      try {
        await player.resume();
        _isPaused = false;
        _isPlaying = true;
        notifyListeners();
      } catch (e) {
        debugPrint('AudioPlaybackService resume error: $e');
      }
    }
  }

  /// Durdur
  Future<void> stop() async {
    try {
      await player.stop();
      _isPlaying = false;
      _isPaused = false;
      _positionSeconds = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('AudioPlaybackService stop error: $e');
    }
  }

  /// Belirli Bir Saniyeye İlerle
  Future<void> seekTo(int seconds) async {
    try {
      _positionSeconds = seconds;
      notifyListeners();
      await player.seek(Duration(seconds: seconds));
    } catch (e) {
      debugPrint('AudioPlaybackService seek error: $e');
    }
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _completeSub?.cancel();
    _stateSub?.cancel();
    _player?.dispose();
    super.dispose();
  }
}
