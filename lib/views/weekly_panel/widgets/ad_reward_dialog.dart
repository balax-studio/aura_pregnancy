import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../core/services/ad_service.dart';

/// Aura Pregnancy - Ödüllü Reklam İzleme ve İçerik Kilit Açma Modalı
class AdRewardDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final String unlockTargetName;
  final VoidCallback? onRewardEarned;

  const AdRewardDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.unlockTargetName,
    this.onRewardEarned,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String unlockTargetName,
    VoidCallback? onRewardEarned,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AdRewardDialog(
        title: title,
        subtitle: subtitle,
        unlockTargetName: unlockTargetName,
        onRewardEarned: onRewardEarned,
      ),
    );
  }

  @override
  State<AdRewardDialog> createState() => _AdRewardDialogState();
}

class _AdRewardDialogState extends State<AdRewardDialog> with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  int _countdown = 5;
  Timer? _timer;
  bool _isCompleted = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  Future<void> _startAdPlayback() async {
    if (AdService.instance.isRewardedAdReady) {
      final earned = await AdService.instance.showRealRewardedAd(
        onRewardEarned: widget.onRewardEarned ?? () {},
      );
      if (!mounted) return;
      if (earned) {
        setState(() {
          _isCompleted = true;
          _isPlaying = false;
        });
        return;
      }
    }

    _runFallbackCountdown();
  }

  void _runFallbackCountdown() {
    setState(() {
      _isPlaying = true;
      _countdown = 5;
      _isCompleted = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        _timer?.cancel();
        setState(() {
          _countdown = 0;
          _isCompleted = true;
          _isPlaying = false;
        });
        widget.onRewardEarned?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: ClayTheme.clayDecoration(
          color: AppColors.clayCardSurface,
          borderRadius: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isPlaying && !_isCompleted) ...[
              // 1. REKLAM İZLEME TEKLİFİ EKRANI
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: ClayTheme.clayDecoration(
                    color: AppColors.clayRose,
                    borderRadius: 22,
                  ),
                  child: const Center(
                    child: Icon(Icons.lock_clock_rounded, color: AppColors.secondaryPeach, size: 32),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: ClayTheme.clayDecoration(
                  color: AppColors.clayPeach,
                  borderRadius: 18,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.smart_display_rounded, color: AppColors.primaryDark, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'ad_watch_info'.tr(args: [widget.unlockTargetName]),
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              ClayButton(
                color: AppColors.clayPeach,
                height: 52,
                onPressed: _startAdPlayback,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_circle_filled_rounded, color: AppColors.primaryDark, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'ad_watch_btn'.tr(),
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'common_cancel_opt'.tr(),
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF7A6E78),
                  ),
                ),
              ),
            ] else if (_isPlaying) ...[
              // 2. REKLAM OYNATILIYOR (CANLI GERİ SAYIM & SİMÜLASYON)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.stars_rounded, color: AppColors.accentGold, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'ad_sponsored'.tr(),
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2D232E),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D232E),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$_countdown ${'ad_seconds_short'.tr()}',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Reklam Görsel Kartı
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.clayRose,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryPink.withValues(alpha: 0.2),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Icons.spa_rounded, color: AppColors.primaryPink, size: 28),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Aura Mom & Baby Care',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF2D232E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ad_brand_sub'.tr(),
                          style: GoogleFonts.quicksand(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF5C4F53),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 12,
                      left: 20,
                      right: 20,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (5 - _countdown) / 5.0,
                          minHeight: 6,
                          backgroundColor: Colors.white.withValues(alpha: 0.5),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryPink),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'ad_loading_reward'.tr(),
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF7A6E78),
                ),
              ),
            ] else ...[
              // 3. REKLAM BİTTİ & KİLİT AÇILDI
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: ClayTheme.clayDecoration(
                    color: const Color(0xFFD4EBD6),
                    borderRadius: 22,
                  ),
                  child: const Center(
                    child: Icon(Icons.lock_open_rounded, color: Color(0xFF2E6135), size: 34),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Text(
                'ad_unlocked_title'.tr(),
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2D232E),
                ),
              ),
              const SizedBox(height: 6),

              Text(
                'ad_unlocked_desc'.tr(args: [widget.unlockTargetName]),
                textAlign: TextAlign.center,
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5C4F53),
                ),
              ),
              const SizedBox(height: 20),

              ClayButton(
                color: AppColors.clayPeach,
                height: 52,
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'ad_continue_btn'.tr(),
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
