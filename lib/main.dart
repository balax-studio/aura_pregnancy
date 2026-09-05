import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:easy_localization/easy_localization.dart';

// Web uyumluluğu için koşullu importlar
import 'dart:io' if (dart.library.html) 'services/io_stubs.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' if (dart.library.html) 'services/sqflite_ffi_stubs.dart';
import 'core/theme/clay_theme.dart';
import 'core/constants/app_colors.dart';
import 'services/database_helper.dart';
import 'services/att_tracking_service.dart';
import 'models/profile_model.dart';
import 'views/welcome/language_selection_screen.dart';
import 'views/onboarding/onboarding_screen.dart';
import 'views/main_navigation_scaffold.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  try {
    await initializeDateFormatting('en_US', null);
    await initializeDateFormatting('tr_TR', null);
  } catch (e) {
    debugPrint('Date formatting init error: $e');
  }

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
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
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ClayTheme.themeData,
      home: const RootGateScreen(),
    );
  }
}

/// Veritabanı ve Profil Durumuna Göre Yönlendirici (Gatekeeper)
class RootGateScreen extends StatefulWidget {
  const RootGateScreen({super.key});

  @override
  State<RootGateScreen> createState() => _RootGateScreenState();
}

class _RootGateScreenState extends State<RootGateScreen> {
  bool _isLoading = true;
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
      setState(() {
        _profile = profile;
        _isOnboardingCompleted = isOnboardingCompleted;
        _hasSeenGuide = hasSeenGuide;
        _isLoading = false;
      });
      // iOS ATT (App Tracking Transparency) izin kontrolü
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AttTrackingService.instance.requestConsentIfNeeded();
      });
    } catch (e) {
      debugPrint('RootGateScreen error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: ClayTheme.clayDecoration(
                  color: AppColors.clayRose,
                  borderRadius: 35,
                ),
                child: const Center(
                  child: Icon(Icons.favorite_rounded, color: AppColors.primaryPink, size: 36),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Aura Pregnancy',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              const CircularProgressIndicator(color: AppColors.primaryPink),
            ],
          ),
        ),
      );
    }

    // Profil varsa veya onboarding tamamlanmışsa doğrudan ana navigasyona yönlendir
    if (_profile != null || _isOnboardingCompleted) {
      return const MainNavigationScaffold();
    }

    // Kullanıcı daha önce dili seçip rehberi tamamlamışsa tekrar gösterme, doğrudan Onboarding'e al
    if (_hasSeenGuide) {
      return const OnboardingScreen();
    }

    // Yeni kullanıcı için: Dil Seçimi -> Hoş Geldiniz -> Uygulama Rehberi -> Onboarding -> Ana Uygulama
    return const LanguageSelectionScreen();
  }
}
