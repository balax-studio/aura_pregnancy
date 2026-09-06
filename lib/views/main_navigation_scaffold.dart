import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/ambient_background.dart';
import '../core/widgets/fluid_clay_bottom_bar.dart';
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
      const TimelineScreen(),
      const JournalScreen(),
      const EmergencyScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AmbientBackground(
        child: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
      ),

      bottomNavigationBar: FluidClayBottomNavBar(
        selectedIndex: _currentIndex,
        onTabSelected: _onTabTapped,
        items: [
          FluidNavItem(
            icon: Icons.home_rounded,
            label: 'nav_home'.tr(),
          ),
          FluidNavItem(
            icon: Icons.calendar_month_rounded,
            label: 'nav_weekly'.tr(),
          ),
          FluidNavItem(
            icon: Icons.monitor_heart_rounded, // Sağlık & Rutin Takibi
            label: 'nav_tracker'.tr(),
          ),
          FluidNavItem(
            icon: Icons.auto_graph_rounded, // Yolculuk / Timeline grafiği
            label: 'nav_journey'.tr(),
          ),
          FluidNavItem(
            icon: Icons.menu_book_rounded,
            label: 'nav_journal'.tr(),
          ),
          FluidNavItem(
            icon: Icons.emergency_rounded,
            label: 'nav_emergency'.tr(),
            isEmergency: true,
          ),
        ],
      ),
    );
  }
}


