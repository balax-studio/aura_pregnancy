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
  Completer<RewardedAd?>? _loadingCompleter;
  int _retryAttempt = 0;
  Timer? _retryTimer;

  /// Reklam motorunu başlatır
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      if (isMobile) {
        await MobileAds.instance.initialize();
        unawaited(loadRewardedAd());
      }
      _isInitialized = true;
      debugPrint('[AdService] Google Mobile Ads servisi hazırlandı (Platform: ${defaultTargetPlatform.name}, ReleaseMode: $kReleaseMode).');
    } catch (e) {
      _isInitialized = true;
      debugPrint('[AdService] Başlatma notu: $e');
    }
  }

  /// Arka planda veya anlık olarak bir sonraki ödüllü reklamı yükler
  Future<RewardedAd?> loadRewardedAd() async {
    if (!isMobile) return null;

    // Halihazırda geçerli bir reklam varsa doğrudan döndür
    if (_preloadedRewardedAd != null) {
      return _preloadedRewardedAd;
    }

    // Halihazırda devam eden bir yükleme isteği varsa o Completer'ı bekle
    if (_isLoadingRewarded && _loadingCompleter != null) {
      return _loadingCompleter!.future;
    }

    _isLoadingRewarded = true;
    _loadingCompleter = Completer<RewardedAd?>();
    final targetAdUnitId = rewardedAdUnitId;

    debugPrint('[AdService] RewardedAd yükleniyor (AdUnitId: $targetAdUnitId)...');

    RewardedAd.load(
      adUnitId: targetAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _preloadedRewardedAd = ad;
          _isLoadingRewarded = false;
          _retryAttempt = 0;
          _retryTimer?.cancel();
          debugPrint('[AdService] RewardedAd başarıyla önbelleklendi.');
          if (_loadingCompleter != null && !_loadingCompleter!.isCompleted) {
            _loadingCompleter!.complete(ad);
          }
          _loadingCompleter = null;
        },
        onAdFailedToLoad: (error) {
          _preloadedRewardedAd = null;
          _isLoadingRewarded = false;
          debugPrint('[AdService] RewardedAd yüklenemedi: $error (Code: ${error.code}, Message: ${error.message})');
          if (_loadingCompleter != null && !_loadingCompleter!.isCompleted) {
            _loadingCompleter!.complete(null);
          }
          _loadingCompleter = null;

          // Hata durumunda exponential backoff ile otomatik tekrar deneme
          _retryAttempt++;
          final nextRetrySeconds = (_retryAttempt * 5).clamp(5, 30);
          _retryTimer?.cancel();
          _retryTimer = Timer(Duration(seconds: nextRetrySeconds), () {
            if (_preloadedRewardedAd == null && !_isLoadingRewarded) {
              debugPrint('[AdService] RewardedAd otomatik retry başlatılıyor ($_retryAttempt. deneme)...');
              loadRewardedAd();
            }
          });
        },
      ),
    );

    return _loadingCompleter!.future;
  }

  /// Ödüllü reklam hazır mı kontrolü
  bool get isRewardedAdReady => _preloadedRewardedAd != null;

  /// Gerçek AdMob Rewarded reklamını ekranda gösterir (Hazır değilse yüklenmesini bekler)
  Future<bool> showRealRewardedAd({
    required VoidCallback onRewardEarned,
    Duration timeout = const Duration(seconds: 7),
  }) async {
    if (!isMobile) return false;

    RewardedAd? ad = _preloadedRewardedAd;
    if (ad == null) {
      debugPrint('[AdService] RewardedAd önbellekte yok, anlık olarak yükleniyor...');
      try {
        ad = await loadRewardedAd().timeout(timeout);
      } catch (e) {
        debugPrint('[AdService] RewardedAd anlık yükleme zaman aşımına uğradı ($timeout): $e');
      }
    }

    if (ad == null) {
      debugPrint('[AdService] Gösterilecek RewardedAd bulunamadı.');
      return false;
    }

    final completer = Completer<bool>();
    bool rewardEarned = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('[AdService] RewardedAd tam ekran açıldı.');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[AdService] RewardedAd kapatıldı.');
        ad.dispose();
        _preloadedRewardedAd = null;
        unawaited(loadRewardedAd());
        if (!completer.isCompleted) {
          completer.complete(rewardEarned);
        }
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        debugPrint('[AdService] RewardedAd gösterim hatası: $err');
        ad.dispose();
        _preloadedRewardedAd = null;
        unawaited(loadRewardedAd());
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    try {
      await ad.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          debugPrint('[AdService] Ödül kazanıldı! (${reward.amount} ${reward.type})');
          rewardEarned = true;
          onRewardEarned();
        },
      );
    } catch (e) {
      debugPrint('[AdService] ad.show istisnası: $e');
      _preloadedRewardedAd = null;
      unawaited(loadRewardedAd());
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }

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
