import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../models/diary_model.dart';
import '../../../services/ffmpeg_video_service.dart';
import '../../weekly_panel/widgets/ad_reward_dialog.dart';
import 'timelapse_video_dialog.dart';

/// FFmpeg Yolculuk Videosu Render Diyalogu
class VideoRendererDialog extends StatefulWidget {
  final List<DiaryModel> highlightEntries;

  const VideoRendererDialog({super.key, required this.highlightEntries});

  @override
  State<VideoRendererDialog> createState() => _VideoRendererDialogState();
}

class _VideoRendererDialogState extends State<VideoRendererDialog> {
  bool _isRendering = false;
  double _progress = 0.0;
  bool _isFinished = false;

  void _watchVideoNow() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (ctx) => const TimelapseVideoDialog(),
    );
  }

  void _requestRenderWithReward() {
    AdRewardDialog.show(
      context: context,
      title: 'video_reward_unlock_title'.tr(),
      subtitle: 'video_reward_unlock_sub'.tr(),
      unlockTargetName: 'timelapse_story_title'.tr(),
      onRewardEarned: () {
        _startRender();
      },
    );
  }

  void _startRender() {
    setState(() {
      _isRendering = true;
      _progress = 0.0;
      _isFinished = false;
    });

    FFmpegVideoService.renderTimeLapseProgress().listen((prog) {
      if (mounted) {
        setState(() {
          _progress = prog;
          if (prog >= 1.0) {
            _isRendering = false;
            _isFinished = true;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final matrix = FFmpegVideoService.generateVideoAssetMatrix(
      highlightEntries: widget.highlightEntries,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: ClayCard(
        color: AppColors.clayRose,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: ClayTheme.clayDecoration(
                color: Colors.white,
                borderRadius: 20,
              ),
              child: const Center(
                child: Icon(Icons.movie_creation_rounded, color: AppColors.primaryPink, size: 32),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'video_dialog_title'.tr(),
              style: GoogleFonts.outfit(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'video_dialog_subtitle'.tr(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Bilgi Kutusu
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildMatrixRow('video_stat_moments'.tr(), 'video_stat_count'.tr(args: [widget.highlightEntries.length.toString()])),
                  _buildMatrixRow('video_stat_melody'.tr(), 'Aura_Lullaby.mp3'),
                  _buildMatrixRow('video_stat_res'.tr(), 'video_stat_res_val'.tr()),
                  _buildMatrixRow('video_stat_est_time'.tr(), 'video_stat_seconds'.tr(args: [matrix['total_duration_sec'].toString()])),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (_isRendering) ...[
              LinearProgressIndicator(
                value: _progress,
                backgroundColor: AppColors.backgroundSubtle,
                color: AppColors.primaryPink,
                borderRadius: BorderRadius.circular(8),
                minHeight: 12,
              ),
              const SizedBox(height: 8),
              Text(
                'video_processing'.tr(args: [(_progress * 100).toInt().toString()]),
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primaryDark),
              ),
              const SizedBox(height: 16),
            ] else if (_isFinished) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.clayMint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'video_success'.tr(),
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: AppColors.successGreen, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            Row(
              children: [
                Expanded(
                  child: ClayButton(
                    color: AppColors.clayCardSurface,
                    height: 44,
                    borderRadius: 14,
                    onPressed: () => Navigator.pop(context),
                    child: Center(
                      child: Text(
                        'common_close'.tr(),
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClayButton(
                    color: _isFinished ? AppColors.clayMint : AppColors.clayPeach,
                    height: 44,
                    borderRadius: 14,
                    onPressed: _isRendering ? null : (_isFinished ? _watchVideoNow : _requestRenderWithReward),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isFinished) ...[
                          const Icon(Icons.play_circle_filled_rounded, color: AppColors.successGreen, size: 18),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            _isFinished ? 'video_ready'.tr() : 'video_start_render'.tr(),
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: _isFinished ? AppColors.successGreen : AppColors.primaryDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatrixRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
          Text(
            val,
            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
