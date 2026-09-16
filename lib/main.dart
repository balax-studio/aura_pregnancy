import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:easy_localization/easy_localization.dart';

// Web uyumluluğu için koşullu importlar
import 'dart:io' if (dart.library.html) 'services/io_stubs.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' if (dart.library.html) 'services/sqflite_ffi_stubs.dart';
import 'core/theme/clay_theme.dart';
import 'services/database_helper.dart';
import 'services/att_tracking_service.dart';
import 'services/app_nav_observer.dart';
import 'core/services/ad_service.dart';
import 'models/profile_model.dart';
import 'views/welcome/generative_splash_screen.dart';
import 'views/welcome/language_selection_screen.dart';
import 'views/onboarding/onboarding_screen.dart';
import 'views/main_navigation_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  try {
    await initializeDateFormatting('en_US', null);
    await initializeDateFormatting('tr_TR', null);
    await initializeDateFormatting('tr', null);
    await initializeDateFormatting('en', null);
  } catch (e) {
    debugPrint('Date formatting init error: $e');
  }

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Google Mobile Ads servisi başlatma
  await AdService.instance.initialize();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('tr')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const AuraPregnancyApp(),
    ),
  );
}

class AuraPregnancyApp extends StatelessWidget {
  const AuraPregnancyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aura Pregnancy',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [
        AppNavObserver.instance,
      ],
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ClayTheme.themeData,
      home: const RootGateScreen(),
    );
  }
}

/// Veritabanı ve Profil Durumuna Göre Yönlendirici (Gatekeeper & Generatif Splash Ekranı)
class RootGateScreen extends StatefulWidget {
  const RootGateScreen({super.key});

  @override
  State<RootGateScreen> createState() => _RootGateScreenState();
}

class _RootGateScreenState extends State<RootGateScreen> {
  bool _isDataReady = false;
  bool _isSplashComplete = false;
  ProfileModel? _profile;
  bool _isOnboardingCompleted = false;
  bool _hasSeenGuide = false;

  @override
  void initState() {
    super.initState();
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    try {
      final profile = await DatabaseHelper.instance.getProfile();
      final isOnboardingCompleted = await DatabaseHelper.instance.isOnboardingCompleted();
      final hasSeenGuide = await DatabaseHelper.instance.hasSeenGuide();
      final savedLang = await DatabaseHelper.instance.getSetting('app_language');
      if (savedLang != null && savedLang.isNotEmpty && mounted) {
        if (context.locale.languageCode != savedLang) {
          await context.setLocale(Locale(savedLang));
        }
      }
      if (mounted) {
        setState(() {
          _profile = profile;
          _isOnboardingCompleted = isOnboardingCompleted;
          _hasSeenGuide = hasSeenGuide;
          _isDataReady = true;
        });
      }
      // iOS ATT (App Tracking Transparency) izin kontrolü
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          AttTrackingService.instance.requestConsentWithPreDialogIfNeeded(context);
        }
      });
    } catch (e) {
      debugPrint('RootGateScreen error: $e');
      if (mounted) {
        setState(() => _isDataReady = true);
      }
    }
  }

  Widget _buildDestinationScreen() {
    // Profil varsa veya onboarding tamamlanmışsa doğrudan ana navigasyona yönlendir
    if (_profile != null || _isOnboardingCompleted) {
      return const MainNavigationScaffold(key: ValueKey('main_nav_screen'));
    }

    // Kullanıcı daha önce dili seçip rehberi tamamlamışsa tekrar gösterme, doğrudan Onboarding'e al
    if (_hasSeenGuide) {
      return const OnboardingScreen(key: ValueKey('onboarding_screen'));
    }

    // Yeni kullanıcı için: Dil Seçimi -> Hoş Geldiniz -> Uygulama Rehberi -> Onboarding -> Ana Uygulama
    return const LanguageSelectionScreen(key: ValueKey('language_screen'));
  }

  @override
  Widget build(BuildContext context) {
    final showSplash = !_isDataReady || !_isSplashComplete;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      child: showSplash
          ? GenerativeSplashScreen(
              key: const ValueKey('generative_splash'),
              onAnimationComplete: () {
                if (mounted) {
                  setState(() => _isSplashComplete = true);
                }
              },
            )
          : _buildDestinationScreen(),
    );
  }
}
