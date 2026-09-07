import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../services/media_service.dart';
import '../../../services/video_story_generator_service.dart';
import '../../../services/ffmpeg_video_service.dart';
import '../../weekly_panel/widgets/ad_reward_dialog.dart';

/// Aura Pregnancy - Time-lapse Yolculuk Hikayesi Video Oynatıcı Diyaloğu
class TimelapseVideoDialog extends StatefulWidget {
  const TimelapseVideoDialog({super.key});

  @override
  State<TimelapseVideoDialog> createState() => _TimelapseVideoDialogState();
}

class _TimelapseVideoDialogState extends State<TimelapseVideoDialog> with SingleTickerProviderStateMixin {
  List<VideoStoryFrame> _frames = [];
  bool _isLoading = true;
  int _currentFrameIndex = 0;
  bool _isPlaying = true;
  bool _isEnded = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  Timer? _playbackTimer;
  late AnimationController _zoomController;

  @override
  void initState() {
    super.initState();
    _zoomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _loadFrames();
  }

  Future<void> _loadFrames() async {
    final frames = await VideoStoryGeneratorService.instance.generateStoryFrames();
    if (mounted) {
      setState(() {
        _frames = frames;
        _isLoading = false;
      });
      _startPlayback();
    }
  }

  void _startPlayback() {
    _playbackTimer?.cancel();
    if (!_isPlaying || _frames.isEmpty) return;

    _playbackTimer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (!mounted) return;
      if (_currentFrameIndex < _frames.length - 1) {
        setState(() {
          _currentFrameIndex++;
        });
      } else {
        // Video Bitti - İki Butonlu Bitiş Ekranını Göster
        _playbackTimer?.cancel();
        setState(() {
          _isPlaying = false;
          _isEnded = true;
        });
      }
    });
  }

  void _replayVideo() {
    setState(() {
      _currentFrameIndex = 0;
      _isPlaying = true;
      _isEnded = false;
    });
    _startPlayback();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _startPlayback();
      } else {
        _playbackTimer?.cancel();
      }
    });
  }

  Future<void> _downloadVideoWithAd() async {
    final rewardEarned = await AdRewardDialog.show(
      context: context,
      title: 'video_download_reward_title'.tr(),
      subtitle: 'video_download_reward_sub'.tr(),
      unlockTargetName: 'video_download_reward_target'.tr(),
    );

    if (rewardEarned == true && mounted) {
      await _startVideoDownload();
    }
  }

  Future<void> _startVideoDownload() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    final savedLocation = await FFmpegVideoService.exportAndSaveVideo(
      frames: _frames,
      fileName: 'Aura_Gebelik_Yolculugu_${DateTime.now().millisecondsSinceEpoch}.mp4',
      onProgress: (prog) {
        if (mounted) {
          setState(() {
            _downloadProgress = prog;
          });
        }
      },
    );

    if (!mounted) return;
    setState(() {
      _isDownloading = false;
    });

    if (savedLocation != null) {
      _showDownloadSuccessDialog(savedLocation);
    } else {
      _showDownloadErrorDialog();
    }
  }

  void _showDownloadErrorDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.background,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.medicalAlertBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, color: AppColors.medicalAlertRed, size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Kayıt Yapılamadı',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 17, color: AppColors.primaryDark),
              ),
            ),
          ],
        ),
        content: Text(
          'Video cihazınıza kaydedilirken bir sorun oluştu. Lütfen cihazınızda depolama alanı olduğunu ve gerekli medya izinlerinin verildiğini kontrol ediniz.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, height: 1.45, color: AppColors.textPrimary),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          ClayButton(
            color: AppColors.clayCardSurface,
            height: 44,
            borderRadius: 14,
            onPressed: () => Navigator.pop(ctx),
            child: Center(
              child: Text(
                'common_close'.tr(),
                style: GoogleFonts.outfit(color: AppColors.primaryDark, fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDownloadSuccessDialog(String location) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.background,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.clinicalGreenBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'video_download_success_title'.tr(),
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 17, color: AppColors.primaryDark),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'video_download_success'.tr(),
              style: GoogleFonts.plusJakartaSans(fontSize: 13, height: 1.45, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.folder_special_rounded, color: AppColors.waterBlue, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      location,
                      style: GoogleFonts.quicksand(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: ClayButton(
                  color: AppColors.clayRose,
                  height: 44,
                  borderRadius: 14,
                  onPressed: () async {
                    await FFmpegVideoService.shareLastVideo();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.share_rounded, size: 17, color: AppColors.primaryPink),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Videoyu Paylaş',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 12.5, color: AppColors.primaryDark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ClayButton(
                  color: AppColors.clayMint,
                  height: 44,
                  borderRadius: 14,
                  onPressed: () => Navigator.pop(ctx),
                  child: Center(
                    child: Text(
                      'common_close'.tr(),
                      style: GoogleFonts.outfit(color: AppColors.successGreen, fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Dialog(
        backgroundColor: Colors.transparent,
        child: Center(child: CircularProgressIndicator(color: AppColors.primaryPink)),
      );
    }

    if (_frames.isEmpty) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: AppColors.background,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.clayRose,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.movie_creation_rounded, size: 36, color: AppColors.primaryPink),
              ),
              const SizedBox(height: 14),
              Text(
                'timelapse_no_records'.tr(),
                style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              ClayButton(
                color: AppColors.clayRose,
                height: 44,
                borderRadius: 14,
                onPressed: () => Navigator.pop(context),
                child: Center(
                  child: Text(
                    'common_close'.tr(),
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentFrame = _frames[_currentFrameIndex];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 680),
        decoration: BoxDecoration(
          color: AppColors.deepCinematicDark, // Sinematik Koyu Arka Plan
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.40),
              offset: const Offset(0, 20),
              blurRadius: 40,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Ken Burns Zoom Efektli Arka Plan Fotoğrafı
              AnimatedBuilder(
                animation: _zoomController,
                builder: (context, child) {
                  final scale = 1.0 + (_zoomController.value * 0.08);
                  return Transform.scale(
                    scale: scale,
                    child: MediaService.buildPhotoWidget(
                      currentFrame.photoPath,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),

              // 2. Sinematik Karartma Gradyanı
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.55),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.40),
                      Colors.black.withValues(alpha: 0.95),
                    ],
                    stops: const [0.0, 0.25, 0.50, 1.0],
                  ),
                ),
              ),

              // 3. Üst Bar (Kare İlerleme Çubukları & Kapatma Butonu)
              Positioned(
                top: 18,
                left: 16,
                right: 16,
                child: Column(
                  children: [
                    // Parçalı İlerleme Çubuğu
                    Row(
                      children: List.generate(_frames.length, (index) {
                        final isPassed = index < _currentFrameIndex;
                        final isCurrent = index == _currentFrameIndex;

                        return Expanded(
                          child: Container(
                            height: 3.5,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: isPassed
                                  ? AppColors.primaryPink
                                  : isCurrent
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),

                    // Başlık ve Kapatma Butonu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.movie_creation_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'timelapse_story_title'.tr(),
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.file_download_rounded, color: Colors.white, size: 22),
                              tooltip: 'video_download_btn'.tr(),
                              onPressed: _isDownloading ? null : _downloadVideoWithAd,
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 4. Alt Bilgi & Kontrol Alanı (Normal Oynatma veya Bitiş Durumu)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isEnded) ...[
                      // BİTİŞ EKRANI: TEBRİK KARTI VE (KAPAT + İNDİR) BUTONLARI
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.celebration_rounded, color: AppColors.accentGold, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'video_end_title'.tr(),
                                  style: GoogleFonts.nunito(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'video_end_subtitle'.tr(),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.quicksand(
                                color: Colors.white70,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (_isDownloading) ...[
                        LinearProgressIndicator(
                          value: _downloadProgress,
                          backgroundColor: Colors.white24,
                          color: AppColors.primaryPink,
                          borderRadius: BorderRadius.circular(8),
                          minHeight: 8,
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: Text(
                            'video_download_saving'.tr(),
                            style: GoogleFonts.nunito(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // İKİ BUTON: SOLDA KAPAT - SAĞDA İNDİR
                      Row(
                        children: [
                          // SOL: KAPAT BUTONU
                          Expanded(
                            child: ClayButton(
                              color: AppColors.textPrimary,
                              height: 48,
                              borderRadius: 16,
                              onPressed: () => Navigator.pop(context),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    'common_close'.tr(),
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // SAĞ: İNDİR BUTONU (REKLAM İZLETEREK İNDİRİR)
                          Expanded(
                            child: ClayButton(
                              color: AppColors.primaryPink,
                              height: 48,
                              borderRadius: 16,
                              onPressed: _isDownloading ? null : _downloadVideoWithAd,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.file_download_rounded, color: Colors.white, size: 19),
                                  const SizedBox(width: 6),
                                  Text(
                                    'video_download_btn'.tr(),
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // TEKRAR İZLE BUTONU
                      Center(
                        child: ClayButton(
                          color: Colors.white.withValues(alpha: 0.15),
                          height: 36,
                          borderRadius: 12,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          onPressed: _replayVideo,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.replay_rounded, color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'video_replay_btn'.tr(),
                                style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      // NORMAL OYNATMA PANELİ
                      // Hafta Rozeti
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPink.withValues(alpha: 0.90),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${'weekly_week_range'.tr(args: [currentFrame.week.toString()])} • ${currentFrame.date}',
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Başlık
                      Text(
                        currentFrame.title,
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Açıklama / Anı Notu
                      Text(
                        currentFrame.subtitle,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.quicksand(
                          color: Colors.white.withValues(alpha: 0.90),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Kontrol Butonları (Önceki, Oynat/Duraklat, Sonraki)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Önceki Kare
                          IconButton(
                            onPressed: _currentFrameIndex > 0
                                ? () => setState(() => _currentFrameIndex--)
                                : null,
                            icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 28),
                          ),

                          // Oynat / Durdur Butonu
                          GestureDetector(
                            onTap: _togglePlayPause,
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.primaryPink,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryPink.withValues(alpha: 0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),

                          // Sonraki Kare
                          IconButton(
                            onPressed: _currentFrameIndex < _frames.length - 1
                                ? () => setState(() => _currentFrameIndex++)
                                : null,
                            icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 28),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
