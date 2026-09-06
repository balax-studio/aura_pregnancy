import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../services/audio_service.dart';

/// Claymorphic Sesli Mektup / Kalp Atışı Oynatıcı Kartı
class ClayAudioPlayer extends StatefulWidget {
  final String audioPath;
  final String title;
  final int durationSeconds;

  const ClayAudioPlayer({
    super.key,
    required this.audioPath,
    this.title = '',
    this.durationSeconds = 30,
  });

  @override
  State<ClayAudioPlayer> createState() => _ClayAudioPlayerState();
}

class _ClayAudioPlayerState extends State<ClayAudioPlayer> {
  final AudioPlaybackService _player = AudioPlaybackService.instance;

  @override
  void initState() {
    super.initState();
    _player.addListener(_onPlayerUpdate);
  }

  void _onPlayerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _player.removeListener(_onPlayerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isThisPlaying = _player.currentPlayingPath == widget.audioPath && _player.isPlaying && !_player.isPaused;
    final isThisPaused = _player.currentPlayingPath == widget.audioPath && _player.isPaused;
    final isThisActive = _player.currentPlayingPath == widget.audioPath;

    final pos = isThisActive ? _player.positionSeconds : 0;
    final total = isThisActive ? _player.totalDurationSeconds : widget.durationSeconds;
    final progress = total > 0 ? (pos / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: ClayTheme.clayDecoration(
        color: isThisPlaying ? AppColors.clayMint : AppColors.clayLavender,
        borderRadius: 20,
        isPressed: isThisPlaying,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Oynat / Duraklat Butonu
              GestureDetector(
                onTap: () {
                  if (isThisPlaying) {
                    _player.pause();
                  } else if (isThisPaused) {
                    _player.resume();
                  } else {
                    _player.play(widget.audioPath, durationSeconds: widget.durationSeconds);
                  }
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: ClayTheme.clayDecoration(
                    color: isThisPlaying ? AppColors.successGreen : AppColors.clayRose,
                    borderRadius: 22,
                    isPressed: isThisPlaying,
                  ),
                  child: Center(
                    child: Icon(
                      isThisPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 26,
                      color: isThisPlaying ? Colors.white : AppColors.primaryDark,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Başlık ve Süre
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${_player.formatTime(pos)} / ${_player.formatTime(total)}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // İlerleme Çubuğu (Scrubber Bar)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Colors.white,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isThisPlaying ? AppColors.successGreen : AppColors.primaryPink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (isThisActive && (isThisPlaying || isThisPaused)) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.stop_rounded, size: 20, color: AppColors.medicalAlertRed),
                  onPressed: () => _player.stop(),
                  tooltip: 'audio_stop'.tr(),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
