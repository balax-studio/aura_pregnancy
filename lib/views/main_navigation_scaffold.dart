import 'dart:async';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/ambient_background.dart';
import '../core/widgets/fluid_clay_bottom_bar.dart';
import '../services/app_nav_observer.dart';
import '../services/database_helper.dart';
import '../services/pregnancy_notification_service.dart';
import 'widgets/notification_permission_dialog.dart';
import 'dashboard/dashboard_screen.dart';
import 'weekly_panel/weekly_panel_screen.dart';
import 'daily_tracker/daily_tracker_screen.dart';
import 'journal/journal_screen.dart';
import 'more/more_tools_screen.dart';
import 'emergency/emergency_screen.dart';

/// Aura Pregnancy - Ana Gezinme İskeleti (5 Sekmeli Akışkan Claymorphic Navigasyon)
class MainNavigationScaffold extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScaffold({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold>
    with WidgetsBindingObserver {
  late int _currentIndex;
  bool _isRefreshingNotifications = false;
  String? _lastScheduledLanguage;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_refreshNotifications(requestPermissionIfNeeded: true));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final languageCode = context.locale.languageCode;
    if (_lastScheduledLanguage != null &&
        _lastScheduledLanguage != languageCode) {
      unawaited(_refreshNotifications());
    }
    _lastScheduledLanguage = languageCode;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      unawaited(_scheduleAfterExitMessage());
    } else if (state == AppLifecycleState.resumed) {
      unawaited(_onAppResumed());
    }
  }

  Future<void> _onAppResumed() async {
    final notificationService = PregnancyNotificationService.instance;
    await notificationService.cancelAfterExitMessage();
    await _refreshNotifications();
  }

  Future<void> _scheduleAfterExitMessage() async {
    final languageCode = context.locale.languageCode;
    final notificationService = PregnancyNotificationService.instance;
    if (!notificationService.isSupportedPlatform) return;
    try {
      await notificationService.initialize();
      if (await notificationService.hasNotificationPermission()) {
        await notificationService.scheduleAfterExitMessage(
          languageCode: languageCode,
        );
      }
    } catch (error) {
      debugPrint('Could not schedule the after-exit baby message: $error');
    }
  }

  Future<void> _refreshNotifications({
    bool requestPermissionIfNeeded = false,
  }) async {
    if (_isRefreshingNotifications) return;
    final languageCode = context.locale.languageCode;
    final notificationService = PregnancyNotificationService.instance;
    if (!notificationService.isSupportedPlatform) return;
    _isRefreshingNotifications = true;
    try {
      await notificationService.initialize();
      var isGranted = await notificationService.hasNotificationPermission();

      if (requestPermissionIfNeeded && !isGranted) {
        final settings = DatabaseHelper.instance;
        final alreadyAsked =
            await settings.getSetting('notification_permission_requested');
        final rationaleWasSeen =
            await settings.getSetting('notification_permission_rationale_seen');
        if (alreadyAsked != 'true' && rationaleWasSeen != 'true') {
          if (!mounted) return;
          final wantsNotifications =
              await NotificationPermissionDialog.show(context);
          if (!mounted) return;
          await settings.setSetting(
            'notification_permission_rationale_seen',
            'true',
          );
          if (wantsNotifications == true) {
            isGranted =
                await notificationService.requestNotificationPermission();
            await settings.setSetting(
                'notification_permission_requested', 'true');
          }
        }
      }

      if (isGranted) {
        await notificationService.scheduleDailyMessages(
          languageCode: languageCode,
        );
      } else {
        await notificationService.clearDailyMessages();
      }
    } catch (error) {
      debugPrint('Could not refresh pregnancy notifications: $error');
    } finally {
      _isRefreshingNotifications = false;
    }
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(onNavigateTab: _onTabTapped),
      const WeeklyPanelScreen(),
      const DailyTrackerScreen(),
      const JournalScreen(),
      const MoreToolsScreen(),
      EmergencyScreen(onBack: () => setState(() => _currentIndex = 0)),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AmbientBackground(
        child: IndexedStack(
          key: ValueKey('nav_stack_${context.locale.languageCode}'),
          index: _currentIndex,
          children: screens,
        ),
      ),
      bottomNavigationBar: ValueListenableBuilder<bool>(
        valueListenable: AppNavObserver.instance.isModalOpen,
        builder: (context, isModalOpen, child) {
          final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
          final hideBottomBar =
              isModalOpen || isKeyboardOpen || _currentIndex == 5;

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            reverseDuration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1.2),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                )),
                child: child,
              );
            },
            child: hideBottomBar
                ? const SizedBox.shrink(key: ValueKey('empty_nav_bar'))
                : KeyedSubtree(
                    key: const ValueKey('fluid_nav_bar'),
                    child: child!,
                  ),
          );
        },
        child: FluidClayBottomNavBar(
          selectedIndex: _currentIndex.clamp(0, 4),
          onTabSelected: _onTabTapped,
          items: [
            FluidNavItem(
              icon: Icons.home_rounded,
              label: 'nav_home'.tr(),
            ),
            FluidNavItem(
              icon: Icons.auto_graph_rounded,
              label: 'nav_weekly'.tr(),
            ),
            FluidNavItem(
              icon: Icons.monitor_heart_rounded,
              label: 'nav_tracker'.tr(),
            ),
            FluidNavItem(
              icon: Icons.menu_book_rounded,
              label: 'nav_journal'.tr(),
            ),
            FluidNavItem(
              icon: Icons.grid_view_rounded,
              label: 'nav_more'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
