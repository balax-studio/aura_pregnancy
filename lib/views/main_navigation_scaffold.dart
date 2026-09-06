import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/ambient_background.dart';
import '../core/widgets/fluid_clay_bottom_bar.dart';
import '../services/app_nav_observer.dart';
import 'dashboard/dashboard_screen.dart';
import 'weekly_panel/weekly_panel_screen.dart';
import 'daily_tracker/daily_tracker_screen.dart';
import 'timeline/timeline_screen.dart';
import 'journal/journal_screen.dart';
import 'emergency/emergency_screen.dart';

/// Aura Pregnancy - Ana Gezinme İskeleti (6 Sekmeli Akışkan Claymorphic Navigasyon)
class MainNavigationScaffold extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScaffold({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardScreen(onNavigateTab: _onTabTapped),
      const WeeklyPanelScreen(),
      const DailyTrackerScreen(),
      const JournalScreen(),
      EmergencyScreen(onBack: () => setState(() => _currentIndex = 0)),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AmbientBackground(
        child: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
      ),

      bottomNavigationBar: ValueListenableBuilder<bool>(
        valueListenable: AppNavObserver.instance.isModalOpen,
        builder: (context, isModalOpen, child) {
          final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
          final hideBottomBar = isModalOpen || isKeyboardOpen || _currentIndex == 4;

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
          selectedIndex: _currentIndex.clamp(0, 3),
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
          ],
        ),
      ),
    );
  }
}


