import 'package:flutter/material.dart';

/// Aura Pregnancy - Gezinme ve Modal Takip Gözlemcisi
/// Diyaloglar (showDialog), alt pencereler (showModalBottomSheet) veya açılır pencereler (PopupRoute)
/// açıldığında alt navigasyon çubuğunun (Bottom Bar) otomatik ve akıcı şekilde gizlenmesini sağlar.
class AppNavObserver extends NavigatorObserver {
  AppNavObserver._internal();
  static final AppNavObserver instance = AppNavObserver._internal();

  final ValueNotifier<bool> isModalOpen = ValueNotifier<bool>(false);
  int _modalCount = 0;

  void reset() {
    _modalCount = 0;
    isModalOpen.value = false;
  }

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
