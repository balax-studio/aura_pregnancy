import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/clay_theme.dart';
import '../../services/database_helper.dart';
import '../../models/profile_model.dart';
import '../journal/widgets/watercolor_portrait_dialog.dart';
import '../journal/widgets/keepsake_card_dialog.dart';
import '../baby_names/baby_names_screen.dart';
import '../weekly_panel/screens/hospital_bag_screen.dart';
import '../weekly_panel/screens/birth_plan_screen.dart';
import '../weekly_panel/widgets/baby_zodiac_card.dart';
import '../journal/screens/time_capsule_screen.dart';
import '../postpartum/postpartum_bridge_screen.dart';
import '../dashboard/screens/womb_ambience_screen.dart';
import '../widgets/emergency_beacon_button.dart';
import '../widgets/medical_disclaimer_sheet.dart';

/// Aura Pregnancy - 5. Sekme: "Daha Fazlası" & Özel Araçlar Stüdyosu
class MoreToolsScreen extends StatefulWidget {
  const MoreToolsScreen({super.key});

  @override
  State<MoreToolsScreen> createState() => _MoreToolsScreenState();
}

class _MoreToolsScreenState extends State<MoreToolsScreen> {
  ProfileModel? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    DatabaseHelper.appDataRevision.addListener(_onAppDataChanged);
  }

  void _onAppDataChanged() {
    if (mounted) _loadProfile();
  }

  @override
  void dispose() {
    DatabaseHelper.appDataRevision.removeListener(_onAppDataChanged);
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final p = await DatabaseHelper.instance.getProfile();
      if (mounted) {
        setState(() {
          _profile = p;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showZodiacModal() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.primaryPink.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'more_tool_zodiac_title'.tr(),
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      BabyZodiacCard(
                        dueDate: _profile?.dueDate,
                        momName: _profile?.momName,
                        babyName: _profile?.babyName,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClinicalSummaryModal() {
    HapticFeedback.selectionClick();
    final week = _profile?.currentWeek ?? 12;
    final babyName = _profile?.babyDisplayName ?? 'Bebeğiniz';
    final momName = _profile?.momName ?? 'Anne Adayı';
    final dueDate = _profile?.dueDate ?? '-';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.clayMint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.medical_services_rounded, color: AppColors.successGreen, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'more_tool_clinic_title'.tr(),
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        'more_tool_clinic_sub'.tr(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ClayCard(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildClinicRow('clinic_row_mom'.tr(), momName),
                  const Divider(height: 16),
                  _buildClinicRow('clinic_row_baby'.tr(), babyName),
                  const Divider(height: 16),
                  _buildClinicRow('clinic_row_week'.tr(), 'week_num_format'.tr(args: [week.toString()])),
                  const Divider(height: 16),
                  _buildClinicRow('clinic_row_edd'.tr(), dueDate),
                  const Divider(height: 16),
                  _buildClinicRow('clinic_row_weight'.tr(), '${_profile?.prePregnancyWeight ?? '-'} kg (${'clinic_weight_initial'.tr()})'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ClayButton(
              color: AppColors.primaryPink,
              height: 48,
              borderRadius: 16,
              onPressed: () {
                Clipboard.setData(ClipboardData(
                  text: 'Aura Gebelik Özeti:\nAnne: $momName\nBebek: $babyName\nHafta: $week\nEDD: $dueDate',
                ));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('clinic_copied_toast'.tr()),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Center(
                child: Text(
                  'clinic_copy_btn'.tr(),
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryPink)),
      );
    }

    final tools = [
      _ToolItem(
        emoji: '🔮',
        icon: Icons.auto_awesome_rounded,
        title: 'more_tool_zodiac_title'.tr(),
        subtitle: 'more_tool_zodiac_sub'.tr(),
        color: AppColors.clayLavender,
        accentColor: AppColors.lavenderPurple,
        onTap: _showZodiacModal,
      ),
      _ToolItem(
        emoji: '👶',
        icon: Icons.stars_rounded,
        title: 'more_tool_names_title'.tr(),
        subtitle: 'more_tool_names_sub'.tr(),
        color: AppColors.clayPeach,
        accentColor: AppColors.secondaryPeach,
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BabyNamesScreen()),
          );
        },
      ),
      _ToolItem(
        emoji: '💌',
        icon: Icons.mark_email_unread_rounded,
        title: 'more_tool_capsule_title'.tr(),
        subtitle: 'more_tool_capsule_sub'.tr(),
        color: AppColors.clayRose,
        accentColor: AppColors.primaryPink,
        onTap: () {
          HapticFeedback.selectionClick();
          TimeCapsuleScreen.open(context);
        },
      ),
      _ToolItem(
        emoji: '🎒',
        icon: Icons.backpack_rounded,
        title: 'more_tool_bag_title'.tr(),
        subtitle: 'more_tool_bag_sub'.tr(),
        color: AppColors.claySky,
        accentColor: AppColors.waterBlue,
        onTap: () {
          HapticFeedback.selectionClick();
          HospitalBagScreen.open(context);
        },
      ),
      _ToolItem(
        emoji: '📜',
        icon: Icons.description_rounded,
        title: 'more_tool_plan_title'.tr(),
        subtitle: 'more_tool_plan_sub'.tr(),
        color: AppColors.clayMint,
        accentColor: AppColors.successGreen,
        onTap: () {
          HapticFeedback.selectionClick();
          BirthPlanScreen.open(context, profile: _profile);
        },
      ),
      _ToolItem(
        emoji: '🎨',
        icon: Icons.palette_rounded,
        title: 'more_tool_portrait_title'.tr(),
        subtitle: 'more_tool_portrait_sub'.tr(),
        color: AppColors.clayPeach,
        accentColor: AppColors.secondaryPeach,
        onTap: () {
          HapticFeedback.selectionClick();
          WatercolorPortraitDialog.show(context);
        },
      ),
      _ToolItem(
        emoji: '🖼️',
        icon: Icons.card_giftcard_rounded,
        title: 'more_tool_keepsake_title'.tr(),
        subtitle: 'more_tool_keepsake_sub'.tr(),
        color: AppColors.clayRose,
        accentColor: AppColors.primaryPink,
        onTap: () {
          HapticFeedback.selectionClick();
          KeepsakeCardDialog.show(context);
        },
      ),
      _ToolItem(
        emoji: '🩺',
        icon: Icons.medical_information_rounded,
        title: 'more_tool_clinic_title'.tr(),
        subtitle: 'more_tool_clinic_sub'.tr(),
        color: AppColors.clayLavender,
        accentColor: AppColors.lavenderPurple,
        onTap: _showClinicalSummaryModal,
      ),
      _ToolItem(
        emoji: '🌸',
        icon: Icons.child_friendly_rounded,
        title: 'more_tool_birth_title'.tr(),
        subtitle: 'more_tool_birth_sub'.tr(),
        color: AppColors.clayMint,
        accentColor: AppColors.successGreen,
        onTap: () {
          HapticFeedback.selectionClick();
          PostpartumBridgeScreen.show(context, profile: _profile);
        },
      ),
      _ToolItem(
        emoji: '🔔',
        icon: Icons.spa_rounded,
        title: 'dashboard_womb_bell'.tr(),
        subtitle: 'womb_ambience_subtitle'.tr(),
        color: AppColors.clayLavender,
        accentColor: AppColors.lavenderPurple,
        onTap: () {
          HapticFeedback.selectionClick();
          WombAmbienceScreen.open(context);
        },
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'more_tools_title'.tr(),
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
          ),
        ),
        actions: const [
          MedicalInfoButton(),
          SizedBox(width: 4),
          Padding(
            padding: EdgeInsets.only(right: 14),
            child: EmergencyBeaconButton(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Üst Karşılama Kartı
            ClayCard(
              color: AppColors.clayCardSurface,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.clayRose,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.grid_view_rounded, color: AppColors.primaryPink, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'more_tools_welcome_title'.tr(),
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'more_tools_welcome_desc'.tr(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 2 Sütunlu Zengin Görsel Clay Grid Butonlar (Haftalıktan aktarılan tarzda)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.05,
              ),
              itemCount: tools.length,
              itemBuilder: (context, index) {
                final tool = tools[index];
                return ClayCard(
                  onTap: tool.onTap,
                  color: tool.color,
                  borderRadius: 22,
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: tool.accentColor.withValues(alpha: 0.25),
                                width: 1.2,
                              ),
                            ),
                            child: Center(
                              child: Icon(tool.icon, color: tool.accentColor, size: 22),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, size: 13, color: tool.accentColor.withValues(alpha: 0.6)),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        tool.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tool.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 18),
            const MedicalDisclaimerBanner(),
            const SizedBox(height: 84), // Alt gezinme barı payı
          ],
        ),
      ),
    );
  }
}

class _ToolItem {
  final String emoji;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color accentColor;
  final VoidCallback onTap;

  const _ToolItem({
    required this.emoji,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.accentColor,
    required this.onTap,
  });
}
