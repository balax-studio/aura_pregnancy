import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../services/pregnancy_notification_service.dart';

/// Aura Pregnancy - Bildirim ve Hatırlatıcı Yönetim Paneli
class NotificationSettingsSheet extends StatefulWidget {
  const NotificationSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const NotificationSettingsSheet(),
    );
  }

  @override
  State<NotificationSettingsSheet> createState() =>
      _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState extends State<NotificationSettingsSheet> {
  bool _isChecking = true;
  bool _isGranted = false;
  final _service = PregnancyNotificationService.instance;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final granted = await _service.hasNotificationPermission();
    if (mounted) {
      setState(() {
        _isGranted = granted;
        _isChecking = false;
      });
    }
  }

  Future<void> _toggleNotifications(bool enable) async {
    setState(() => _isChecking = true);
    final languageCode = context.locale.languageCode;

    if (enable) {
      final granted = await _service.requestNotificationPermission();
      if (granted) {
        await _service.scheduleDailyMessages(
          languageCode: languageCode,
          force: true,
        );
        _isGranted = true;
      } else {
        // Sistem ayarları açılsın mı uyarısı verilebilir
        await openAppSettings();
        _isGranted = await _service.hasNotificationPermission();
      }
    } else {
      await _service.clearDailyMessages();
      _isGranted = false;
    }

    if (mounted) {
      setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.primaryPink.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.clayRose,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: AppColors.primaryPink,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'notifications_settings_title'.tr(),
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isGranted
                            ? 'notifications_status_enabled'.tr()
                            : 'notifications_status_disabled'.tr(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _isGranted
                              ? AppColors.successGreen
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ClayCard(
              color: AppColors.clayCardSurface,
              padding: const EdgeInsets.all(16),
              borderRadius: 20,
              child: Column(
                children: [
                  _buildScheduleItem(
                    icon: Icons.wb_sunny_rounded,
                    color: AppColors.clayPeach,
                    iconColor: AppColors.secondaryPeach,
                    title: 'notifications_morning_desc'.tr(),
                  ),
                  const SizedBox(height: 12),
                  _buildScheduleItem(
                    icon: Icons.nightlight_round,
                    color: AppColors.clayLavender,
                    iconColor: AppColors.lavenderPurple,
                    title: 'notifications_evening_desc'.tr(),
                  ),
                  const SizedBox(height: 12),
                  _buildScheduleItem(
                    icon: Icons.volunteer_activism_rounded,
                    color: AppColors.clayRose,
                    iconColor: AppColors.primaryPink,
                    title: 'notifications_after_exit_desc'.tr(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _isChecking
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : ClayButton(
                    color: _isGranted ? AppColors.clayCream : AppColors.clayRose,
                    height: 50,
                    borderRadius: 18,
                    onPressed: () => _toggleNotifications(!_isGranted),
                    child: Text(
                      _isGranted
                          ? 'notifications_disable_button'.tr()
                          : 'notifications_enable_button'.tr(),
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required String title,
  }) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
