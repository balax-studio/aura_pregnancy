import 'dart:async';
import 'dart:io' if (dart.library.html) '../../services/io_stubs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../views/weekly_panel/widgets/ad_reward_dialog.dart';
import '../constants/app_colors.dart';

/// Aura Pregnancy - Reklam Yönetim ve Yapılandırma Servisi
/// Google Mobile Ads (AdMob) resmi kimlikleri, Rewarded ve Native Ad koordinasyonu.
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  /// Canlı (Production) AdMob Kimlikleri
  static const String androidAppId = 'ca-app-pub-2626843024156194~8901972198';
  static const String androidNativeProdId = 'ca-app-pub-2626843024156194/5241928781';
  static const String androidRewardedProdId = 'ca-app-pub-2626843024156194/6798553034';

  static const String iosAppId = 'ca-app-pub-2626843024156194~2005391358';
  static const String iosNativeProdId = 'ca-app-pub-2626843024156194/1254687514';
  static const String iosRewardedProdId = 'ca-app-pub-2626843024156194/8379228012';

  /// Google Mobile Ads Resmi Test Reklam Birimi Kimlikleri (Ad Unit IDs)
  static const String androidRewardedTestId = 'ca-app-pub-3940256099942544/5224354917';
  static const String iosRewardedTestId = 'ca-app-pub-3940256099942544/1712485313';

  static const String androidNativeTestId = 'ca-app-pub-3940256099942544/2247696110';
  static const String iosNativeTestId = 'ca-app-pub-3940256099942544/3986624511';

  static const String androidBannerTestId = 'ca-app-pub-3940256099942544/6300978111';
  static const String iosBannerTestId = 'ca-app-pub-3940256099942544/2934735716';

  bool get isMobile {
    if (kIsWeb) return false;
    try {
      if (Platform.environment.containsKey('FLUTTER_TEST')) {
        return false;
      }
    } catch (_) {}
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Ortama göre aktif Native Ad Unit ID'yi döner (Platform & Canlı / Test ayrımı)
  static String get nativeAdUnitId {
    final isIos = defaultTargetPlatform == TargetPlatform.iOS;
    if (kReleaseMode) {
      return isIos
          ? (iosNativeProdId.isNotEmpty ? iosNativeProdId : iosNativeTestId)
          : androidNativeProdId;
    }
    return isIos ? iosNativeTestId : androidNativeTestId;
  }

  /// Ortama göre aktif Rewarded Ad Unit ID'yi döner (Platform & Canlı / Test ayrımı)
  static String get rewardedAdUnitId {
    final isIos = defaultTargetPlatform == TargetPlatform.iOS;
    if (kReleaseMode) {
      return isIos
          ? (iosRewardedProdId.isNotEmpty ? iosRewardedProdId : iosRewardedTestId)
          : androidRewardedProdId;
    }
    return isIos ? iosRewardedTestId : androidRewardedTestId;
  }

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  RewardedAd? _preloadedRewardedAd;
  bool _isLoadingRewarded = false;

  /// Reklam motorunu başlatır
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      if (isMobile) {
        await MobileAds.instance.initialize();
        loadRewardedAd();
      }
      _isInitialized = true;
      debugPrint('[AdService] Google Mobile Ads servisi hazırlandı.');
    } catch (e) {
      _isInitialized = true;
      debugPrint('[AdService] Başlatma notu: $e');
    }
  }

  /// Arka planda bir sonraki ödüllü reklamı hazırlar (Preload)
  void loadRewardedAd() {
    if (!isMobile || _isLoadingRewarded || _preloadedRewardedAd != null) return;
    _isLoadingRewarded = true;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _preloadedRewardedAd = ad;
          _isLoadingRewarded = false;
          debugPrint('[AdService] RewardedAd başarıyla önbelleklendi.');
        },
        onAdFailedToLoad: (error) {
          _preloadedRewardedAd = null;
          _isLoadingRewarded = false;
          debugPrint('[AdService] RewardedAd yüklenemedi: $error');
        },
      ),
    );
  }

  /// Ödüllü reklam hazır mı kontrolü
  bool get isRewardedAdReady => _preloadedRewardedAd != null;

  /// Gerçek AdMob Rewarded reklamını ekranda gösterir
  Future<bool> showRealRewardedAd({
    required VoidCallback onRewardEarned,
  }) async {
    final ad = _preloadedRewardedAd;
    if (ad == null) {
      loadRewardedAd();
      return false;
    }

    final completer = Completer<bool>();
    bool rewardEarned = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _preloadedRewardedAd = null;
        loadRewardedAd();
        if (!completer.isCompleted) {
          completer.complete(rewardEarned);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _preloadedRewardedAd = null;
        loadRewardedAd();
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    ad.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        rewardEarned = true;
        onRewardEarned();
      },
    );

    return completer.future;
  }

  /// Hem iOS hem Android için Claymorphism uyumlu NativeTemplateStyle ile Yerel Reklam oluşturucu
  NativeAd? createNativeAd({
    required void Function(NativeAd ad) onAdLoaded,
    required void Function(LoadAdError error) onAdFailedToLoad,
  }) {
    if (!isMobile) return null;

    final nativeAd = NativeAd(
      adUnitId: nativeAdUnitId,
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor: AppColors.background,
        cornerRadius: 22.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.primaryDark,
          backgroundColor: AppColors.clayPeach,
          style: NativeTemplateFontStyle.bold,
          size: 13.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.primaryDark,
          style: NativeTemplateFontStyle.bold,
          size: 14.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.textSecondary,
          style: NativeTemplateFontStyle.normal,
          size: 11.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.textSecondary,
          style: NativeTemplateFontStyle.normal,
          size: 10.0,
        ),
      ),
      listener: NativeAdListener(
        onAdLoaded: (ad) => onAdLoaded(ad as NativeAd),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onAdFailedToLoad(error);
        },
      ),
    );

    nativeAd.load();
    return nativeAd;
  }

  /// Kullanıcının isteğiyle tetiklenen Ödüllü Reklam Akışı
  /// Sıfır Dark-Pattern: Kullanıcıya ne kazanacağını net açıklar, izleme bitince ödülü %100 verir.
  static Future<bool> showRewardedUnlock({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String unlockTargetName,
    required VoidCallback onRewardEarned,
  }) async {
    final result = await AdRewardDialog.show(
      context: context,
      title: title,
      subtitle: subtitle,
      unlockTargetName: unlockTargetName,
      onRewardEarned: onRewardEarned,
    );
    return result ?? false;
  }
}
