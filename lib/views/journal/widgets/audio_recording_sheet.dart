import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/clay_theme.dart';
import '../../../../services/audio_service.dart';

/// Claymorphic Sesli Mektup Kayıt Stüdyosu (Modal Bottom Sheet)
class AudioRecordingSheet extends StatefulWidget {
  const AudioRecordingSheet({super.key});

  static Future<Map<String, dynamic>?> show(BuildContext context) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const AudioRecordingSheet(),
    );
  }

  @override
  State<AudioRecordingSheet> createState() => _AudioRecordingSheetState();
}

class _AudioRecordingSheetState extends State<AudioRecordingSheet> with SingleTickerProviderStateMixin {
  final AudioRecordingService _service = AudioRecordingService.instance;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _service.addListener(_onServiceUpdate);
    
    // Otomatik olarak kaydı başlat
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final success = await _service.startRecording();
      if (mounted) {
        setState(() {});
        if (!success && _service.lastErrorMessage != null) {
          // İzin veya donanım uyarısı
        }
      }
    });
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceUpdate);
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final waveforms = _service.waveforms;
    final hasError = _service.lastErrorMessage != null;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tutamaç
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Başlık
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎙️', style: TextStyle(fontSize: 26)),
              const SizedBox(width: 8),
              Text(
                'audio_sheet_title'.tr(),
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'audio_sheet_subtitle'.tr(),
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          if (hasError) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.medicalAlertBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.medicalAlertRed.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.medicalAlertRed, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _service.lastErrorMessage!,
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.medicalAlertRed),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClayButton(
                    color: AppColors.clayRose,
                    height: 40,
                    onPressed: () {
                      openAppSettings();
                    },
                    child: Text(
                      'audio_sheet_open_settings'.tr(),
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            // Canlı Sayım Süresi (00:07)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.clayRose,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPink.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  _service.formattedDuration,
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Canlı Ses Dalgası (Waveform Visualizer)
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    offset: const Offset(0, 3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: waveforms.isEmpty
                    ? [Text('audio_sheet_listening'.tr(), style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textMuted))]
                    : waveforms.map((amp) {
                        final h = (amp * 40).clamp(6.0, 44.0);
                        return Container(
                          width: 4,
                          height: h,
                          margin: const EdgeInsets.symmetric(horizontal: 2.5),
                          decoration: BoxDecoration(
                            color: _service.isPaused ? Colors.grey.shade400 : AppColors.primaryPink,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Ortadaki Büyük Nabız Mikrofon Butonu
            Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = _service.isPaused ? 1.0 : (1.0 + (_pulseController.value * 0.08));
                  return Transform.scale(
                    scale: scale,
                    child: GestureDetector(
                      onTap: () => _service.togglePause(),
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: ClayTheme.clayDecoration(
                          color: _service.isPaused ? AppColors.clayPeach : AppColors.clayRose,
                          borderRadius: 38,
                          isPressed: _service.isPaused,
                        ),
                        child: Center(
                          child: Icon(
                            _service.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                            size: 36,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _service.isPaused ? 'audio_sheet_paused'.tr() : 'audio_sheet_recording'.tr(),
                style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Alt Aksiyon Butonları
          Row(
            children: [
              Expanded(
                child: ClayButton(
                  color: AppColors.clayCardSurface,
                  onPressed: () async {
                    final nav = Navigator.of(context);
                    await _service.cancelRecording();
                    if (!mounted) return;
                    nav.pop();
                  },
                  child: Text(
                    'common_cancel'.tr(),
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (!hasError) ...[
                Expanded(
                  flex: 2,
                  child: ClayButton(
                    color: AppColors.clayMint,
                    onPressed: () async {
                      final nav = Navigator.of(context);
                      final result = await _service.stopRecording();
                      if (!mounted) return;
                      nav.pop(result);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          'audio_sheet_finish'.tr(),
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.successGreen, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
