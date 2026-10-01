import 'package:flutter/material.dart';
import 'notification_service.dart';

/// Aura Pregnancy - Gezinme ve Modal Takip Gözlemcisi
/// Diyaloglar (showDialog), alt pencereler (showModalBottomSheet) veya açılır pencereler (PopupRoute)
/// açıldığında alt navigasyon çubuğunun (Bottom Bar) otomatik ve akıcı şekilde gizlenmesini sağlar.
/// Ayrıca uygulama arka plana geçince re-engagement bildirimini zamanlar.
class AppNavObserver extends NavigatorObserver with WidgetsBindingObserver {
  AppNavObserver._internal();
  static final AppNavObserver instance = AppNavObserver._internal();

  final ValueNotifier<bool> isModalOpen = ValueNotifier<bool>(false);
  int _modalCount = 0;
  String _currentLang = 'tr';

  /// WidgetsBinding'e kayıt ol (main.dart'ta çağrılmalı)
  void registerLifecycle() {
    WidgetsBinding.instance.addObserver(this);
  }

  /// Dil bilgisini güncelle (bildirim mesajları için)
  void updateLang(String lang) {
    _currentLang = lang;
  }

  void reset() {
    _modalCount = 0;
    isModalOpen.value = false;
  }

  // ─── AppLifecycle: arka plana geçiş / öne geliş ────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Uygulama arka plana geçti → 3 gün sonrası için re-engagement zamanla
      final dayIndex = DateTime.now().day;
      NotificationService.instance.scheduleReEngagementFromNow(dayIndex, _currentLang);
    } else if (state == AppLifecycleState.resumed) {
      // Uygulama öne geldi → re-engagement iptal et (kullanıcı geri döndü)
      NotificationService.instance.cancelReEngagement();
    }
  }

  // ─── Modal / Popup İzleme ───────────────────────────────────────────────

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PopupRoute) {
      _modalCount++;
      isModalOpen.value = true;
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (route is PopupRoute) {
      _modalCount = (_modalCount - 1).clamp(0, 999);
      isModalOpen.value = _modalCount > 0;
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    if (route is PopupRoute) {
      _modalCount = (_modalCount - 1).clamp(0, 999);
      isModalOpen.value = _modalCount > 0;
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (oldRoute is PopupRoute && newRoute is! PopupRoute) {
      _modalCount = (_modalCount - 1).clamp(0, 999);
    } else if (oldRoute is! PopupRoute && newRoute is PopupRoute) {
      _modalCount++;
    }
    isModalOpen.value = _modalCount > 0;
  }
}
