import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/localization.dart';
import 'package:easy_localization/src/translations.dart';

import 'package:aura_pregnancy/services/app_nav_observer.dart';

class JsonAssetLoader extends AssetLoader {
  final Map<String, dynamic> data;

  const JsonAssetLoader(this.data);

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return data;
  }
}

Map<String, dynamic>? _cachedTrData;

Map<String, dynamic> getTrTranslations() {
  if (_cachedTrData != null) return _cachedTrData!;
  final file = File('assets/translations/tr.json');
  if (file.existsSync()) {
    _cachedTrData = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  } else {
    _cachedTrData = {};
  }
  return _cachedTrData!;
}

Widget createLocalizedTestWidget({
  required Widget child,
  Locale locale = const Locale('tr'),
}) {
  AppNavObserver.instance.reset();
  EasyLocalization.logger.enableLevels = [];
  final translations = Translations(getTrTranslations());
  Localization.load(locale, translations: translations);

  return EasyLocalization(
    supportedLocales: const [Locale('tr'), Locale('en')],
    path: 'assets/translations',
    assetLoader: JsonAssetLoader(getTrTranslations()),
    startLocale: locale,
    saveLocale: false,
    useOnlyLangCode: true,
    child: Builder(
      builder: (context) {
        return MaterialApp(
          navigatorObservers: [
            AppNavObserver.instance,
          ],
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          home: child,
        );
      },
    ),
  );
}
