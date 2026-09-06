import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/clay_theme.dart';
import '../../core/services/ad_service.dart';

/// Aura Pregnancy - Claymorphic Yerel Gelişmiş Reklam Kartı (Native Ad Card)
/// Hem Android hem iOS için gerçek Google Mobile Ads NativeAd desteği sunar;
/// Reklam yüklenemediğinde veya test/çevrimdışı ortamda şık Claymorphic tasarımı yedek gösterir.
class ClayNativeAdCard extends StatefulWidget {
  final String? title;
  final String? description;
  final String? buttonText;
  final IconData icon;
  final Color? cardColor;
  final VoidCallback? onTap;

  const ClayNativeAdCard({
    super.key,
    this.title,
    this.description,
    this.buttonText,
    this.icon = Icons.spa_rounded,
    this.cardColor,
    this.onTap,
  });

  @override
  State<ClayNativeAdCard> createState() => _ClayNativeAdCardState();
}

class _ClayNativeAdCardState extends State<ClayNativeAdCard> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    if (AdService.instance.isMobile) {
      _nativeAd = AdService.instance.createNativeAd(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (error) {
          if (mounted) {
            setState(() {
              _isAdLoaded = false;
            });
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdLoaded && _nativeAd != null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        height: 110,
        decoration: ClayTheme.clayDecoration(
          color: widget.cardColor ?? AppColors.clayCardSurface,
          borderRadius: 26,
        ),
        clipBehavior: Clip.antiAlias,
        child: AdWidget(ad: _nativeAd!),
      );
    }

    return _buildFallbackCard(context);
  }

  Widget _buildFallbackCard(BuildContext context) {
    final effectiveTitle = widget.title ?? 'ad_native_title_1'.tr();
    final effectiveDesc = widget.description ?? 'ad_native_desc_1'.tr();
    final effectiveBtn = widget.buttonText ?? 'ad_native_btn_1'.tr();
    final surfaceColor = widget.cardColor ?? AppColors.clayCardSurface;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: ClayTheme.clayDecoration(
        color: surfaceColor,
        borderRadius: 26,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst Satır: Şeffaf Sponsor Rozeti & Bilgi İkonu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.secondaryPeach.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.campaign_outlined, color: AppColors.secondaryPeach, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'ad_native_sponsor_badge'.tr(),
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.secondaryPeach,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              Tooltip(
                message: 'ad_sponsored_info'.tr(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.04),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // İçerik Satırı: İkon Havuzu + Başlık ve Açıklama
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: ClayTheme.concaveDecoration(
                  color: Colors.white,
                  borderRadius: 16,
                ),
                child: Center(
                  child: Icon(widget.icon, color: AppColors.secondaryPeach, size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      effectiveTitle,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDark,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      effectiveDesc,
                      style: GoogleFonts.quicksand(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Alt Satır: ClayButton Eylemi
          Align(
            alignment: Alignment.centerRight,
            child: ClayButton(
              color: AppColors.clayPeach,
              height: 42,
              borderRadius: 14,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              onPressed: widget.onTap ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryPink,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'ad_thank_support'.tr(),
                                style: GoogleFonts.nunito(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.white,
                        elevation: 8,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(
                            color: AppColors.primaryPink.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    effectiveBtn,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primaryDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
