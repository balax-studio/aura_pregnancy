import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../models/profile_model.dart';
import '../../../services/database_helper.dart';
import '../../widgets/medical_disclaimer_sheet.dart';
import '../../welcome/language_selection_screen.dart';
import '../../weekly_panel/widgets/ad_reward_dialog.dart';
import 'package:easy_localization/easy_localization.dart';

/// Aura Pregnancy - Bebek & Anne Bilgilerini Düzenleme Modalı (Liquid Glass & Glazed Ceramic)
class ProfileEditSheet extends StatefulWidget {
  final ProfileModel profile;
  final VoidCallback onSaved;

  const ProfileEditSheet({
    super.key,
    required this.profile,
    required this.onSaved,
  });

  @override
  State<ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends State<ProfileEditSheet> {
  late TextEditingController _momNameController;
  late TextEditingController _babyNameController;
  late String _selectedGender;
  String? _selectedLanguageCode;
  bool _isSaving = false;
  int _resetCount = 0;

  @override
  void initState() {
    super.initState();
    _momNameController = TextEditingController(text: widget.profile.momName ?? '');
    _babyNameController = TextEditingController(text: widget.profile.babyName ?? '');
    _selectedGender = widget.profile.babyGender ?? 'surprise';
    _loadResetCount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selectedLanguageCode ??= context.locale.languageCode;
  }

  Future<void> _changeLanguage(String langCode) async {
    if (_selectedLanguageCode == langCode) return;
    HapticFeedback.lightImpact();
    setState(() {
      _selectedLanguageCode = langCode;
    });
    final newLocale = Locale(langCode);
    await context.setLocale(newLocale);
    try {
      await DatabaseHelper.instance.setSetting('app_language', langCode);
      DatabaseHelper.notifyDataChanged();
    } catch (e) {
      debugPrint('ProfileEditSheet changeLanguage error: $e');
    }
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('language_changed_toast'.tr()),
          backgroundColor: AppColors.successGreen,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _loadResetCount() async {
    final count = await DatabaseHelper.instance.getResetCount();
    if (mounted) {
      setState(() => _resetCount = count);
    }
  }

  @override
  void dispose() {
    _momNameController.dispose();
    _babyNameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    final updated = widget.profile.copyWith(
      momName: _momNameController.text.trim().isEmpty ? null : _momNameController.text.trim(),
      babyName: _babyNameController.text.trim().isEmpty ? null : _babyNameController.text.trim(),
      babyGender: _selectedGender,
    );

    await DatabaseHelper.instance.saveProfile(updated);
    widget.onSaved();
    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('profile_edit_saved'.tr()),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
  }

  Future<void> _confirmResetData() async {
    final resetCount = await DatabaseHelper.instance.getResetCount();
    final isFree = resetCount == 0;

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.medicalAlertRed.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_forever_rounded, color: AppColors.medicalAlertRed, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'profile_edit_reset_confirm_title'.tr(),
                style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 17, color: AppColors.primaryDark),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isFree
                  ? 'profile_edit_reset_confirm_desc_free'.tr()
                  : 'profile_edit_reset_confirm_desc_ad'.tr(),
              style: GoogleFonts.plusJakartaSans(fontSize: 13, height: 1.45, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isFree ? AppColors.clayMint : AppColors.clayPeach,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isFree ? AppColors.successGreen.withValues(alpha: 0.4) : AppColors.secondaryPeach.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFree ? Icons.check_circle_rounded : Icons.smart_display_rounded,
                    size: 14,
                    color: isFree ? AppColors.successGreen : AppColors.secondaryPeach,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isFree
                        ? 'profile_edit_reset_badge_free'.tr()
                        : 'profile_edit_reset_badge_ad'.tr(),
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isFree ? AppColors.successGreen : AppColors.secondaryPeach,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: ClayButton(
                  color: AppColors.clayCardSurface,
                  height: 44,
                  borderRadius: 14,
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Center(
                    child: Text(
                      'profile_edit_reset_cancel_btn'.tr(),
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ClayButton(
                  color: AppColors.medicalAlertRed,
                  height: 44,
                  borderRadius: 14,
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Center(
                    child: Text(
                      isFree
                          ? 'profile_edit_reset_confirm_btn_free'.tr()
                          : 'profile_edit_reset_confirm_btn_ad'.tr(),
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (isFree) {
      // 1. Ücretsiz Reklamsız İlk Sıfırlama
      await DatabaseHelper.instance.incrementResetCount();
      await DatabaseHelper.instance.clearAllData(preserveResetCount: true);
      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
        (route) => false,
      );
    } else {
      // 2. ve Sonraki Sıfırlamalar: Reklam Şartı
      if (!mounted) return;
      final rewardEarned = await AdRewardDialog.show(
        context: context,
        title: 'profile_edit_reset_ad_title'.tr(),
        subtitle: 'profile_edit_reset_ad_sub'.tr(),
        unlockTargetName: 'profile_edit_reset_ad_target'.tr(),
      );

      if (rewardEarned == true) {
        await DatabaseHelper.instance.incrementResetCount();
        await DatabaseHelper.instance.clearAllData(preserveResetCount: true);
        if (!mounted) return;

        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LanguageSelectionScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: ClayTheme.glazedGlassDecoration(
            surfaceColor: AppColors.background,
            borderRadius: 32,
            opacity: 0.92,
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 18,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Üst Tutamaç Çukuru
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: ClayTheme.concaveDecoration(
                      color: Colors.black.withValues(alpha: 0.12),
                      borderRadius: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Başlık
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: ClayTheme.clayDecoration(
                        color: AppColors.clayRose,
                        borderRadius: 10,
                      ),
                      child: const Center(
                        child: Icon(Icons.child_care_rounded, color: AppColors.primaryPink, size: 18),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'profile_edit_title'.tr(),
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
            const SizedBox(height: 4),
            Text(
              'profile_edit_desc'.tr(),
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // 1. Anne İsmi
            ClayCard(
              color: AppColors.clayCardSurface,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.face_rounded, size: 15, color: AppColors.primaryPink),
                      const SizedBox(width: 6),
                      Text(
                        'profile_edit_mom_label'.tr(),
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _momNameController,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'onboarding_step3_mom_hint'.tr(),
                      hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 13),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.clayOuterDrop.withValues(alpha: 0.15), width: 1)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.clayOuterDrop.withValues(alpha: 0.15), width: 1)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primaryPink, width: 1.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 2. Bebeğin İsmi
            ClayCard(
              color: AppColors.clayCardSurface,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.child_friendly_rounded, size: 15, color: AppColors.primaryPink),
                      const SizedBox(width: 6),
                      Text(
                        'profile_edit_baby_label'.tr(),
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'profile_edit_baby_desc'.tr(),
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _babyNameController,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'onboarding_step3_baby_hint'.tr(),
                      hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 13),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.clayOuterDrop.withValues(alpha: 0.15), width: 1)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.clayOuterDrop.withValues(alpha: 0.15), width: 1)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primaryPink, width: 1.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 3. Cinsiyet Seçimi
            ClayCard(
              color: AppColors.clayCardSurface,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.stars_rounded, size: 15, color: AppColors.secondaryPeach),
                      const SizedBox(width: 6),
                      Text(
                        'profile_edit_gender_label'.tr(),
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildGenderPill('onboarding_step3_gender_girl'.tr(), 'girl', Icons.female_rounded, AppColors.clayRose, AppColors.primaryPink),
                      const SizedBox(width: 8),
                      _buildGenderPill('onboarding_step3_gender_boy'.tr(), 'boy', Icons.male_rounded, AppColors.claySky, AppColors.waterBlue),
                      const SizedBox(width: 8),
                      _buildGenderPill('onboarding_step3_gender_surprise'.tr(), 'surprise', Icons.help_outline_rounded, AppColors.clayCream, AppColors.accentGold),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 4. Uygulama Dili Seçeneği
            ClayCard(
              color: AppColors.clayCardSurface,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.language_rounded, size: 16, color: AppColors.primaryPink),
                      const SizedBox(width: 6),
                      Text(
                        'profile_edit_language_label'.tr(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'profile_edit_language_desc'.tr(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildLanguagePill(
                        label: 'profile_edit_language_tr'.tr(),
                        code: 'tr',
                        flagEmoji: '🇹🇷',
                        activeColor: AppColors.clayMint,
                        activeBorderColor: AppColors.successGreen,
                      ),
                      const SizedBox(width: 10),
                      _buildLanguagePill(
                        label: 'profile_edit_language_en'.tr(),
                        code: 'en',
                        flagEmoji: '🇬🇧',
                        activeColor: AppColors.clayPeach,
                        activeBorderColor: AppColors.secondaryPeach,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 5. Hukuki & Online Gizlilik Sözleşmesi Kartı
            ClayCard(
              color: AppColors.clayLavender,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.security_rounded, size: 15, color: AppColors.lavenderPurple),
                      const SizedBox(width: 6),
                      Text(
                        'profile_edit_legal_title'.tr(),
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClayButton(
                    color: AppColors.claySky,
                    height: 46,
                    borderRadius: 14,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    onPressed: () async {
                      final uri = Uri.parse(
                        'https://docs.google.com/document/d/e/2PACX-1vS6uFWNKKhE-D5MateR98z1d6ytQNssL6iSWYryOd-Uy2UcAewmrHo6YvSHG0YRmz3CNmWtCxdkn-l_/pub',
                      );
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.waterBlue),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'profile_edit_online_privacy_btn'.tr(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClayButton(
                    color: AppColors.clayRose,
                    height: 46,
                    borderRadius: 14,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    onPressed: () => MedicalDisclaimerSheet.show(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.health_and_safety_outlined, size: 17, color: AppColors.primaryPink),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'profile_edit_medical_disclaimer_btn'.tr(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClayButton(
                    color: AppColors.medicalAlertBg,
                    height: 48,
                    borderRadius: 14,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    onPressed: _confirmResetData,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delete_forever_rounded, size: 17, color: AppColors.medicalAlertRed),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'profile_edit_reset_title'.tr(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.medicalAlertRed,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: _resetCount == 0 ? AppColors.clayMint : AppColors.clayPeach,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _resetCount == 0 ? Icons.check_circle_outline_rounded : Icons.smart_display_rounded,
                                size: 11,
                                color: _resetCount == 0 ? AppColors.successGreen : AppColors.secondaryPeach,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                _resetCount == 0
                                    ? 'profile_edit_reset_badge_free'.tr()
                                    : 'profile_edit_reset_badge_ad'.tr(),
                                style: GoogleFonts.nunito(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: _resetCount == 0 ? AppColors.successGreen : AppColors.secondaryPeach,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Kaydet Butonu
            ClayButton(
              color: AppColors.clayMint,
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving
                  ? const CircularProgressIndicator(color: AppColors.successGreen)
                  : Text(
                      'profile_edit_save'.tr(),
                      style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.successGreen),
                    ),
            ),
          ],
        ),
      ),
    ),
  ),
);
}

  Widget _buildGenderPill(String label, String value, IconData icon, Color bgColor, Color activeColor) {
    final isSelected = _selectedGender == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: ClayTheme.clayDecoration(
            color: isSelected ? activeColor : bgColor,
            borderRadius: 14,
            isPressed: isSelected,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguagePill({
    required String label,
    required String code,
    required String flagEmoji,
    required Color activeColor,
    required Color activeBorderColor,
  }) {
    final currentCode = _selectedLanguageCode ?? context.locale.languageCode;
    final isSelected = currentCode == code;

    return Expanded(
      child: GestureDetector(
        onTap: () => _changeLanguage(code),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
          decoration: ClayTheme.clayDecoration(
            color: isSelected ? activeColor : AppColors.background,
            borderRadius: 14,
            isPressed: isSelected,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                flagEmoji,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: activeBorderColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
