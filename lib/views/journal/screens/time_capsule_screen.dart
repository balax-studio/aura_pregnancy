import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../models/time_capsule_model.dart';
import '../../../services/database_helper.dart';

/// Aura Pregnancy - Tam Ekran 18. Yaş Dijital Zaman Kapsülü & Geleceğe Mektuplar Ekranı
class TimeCapsuleScreen extends StatefulWidget {
  const TimeCapsuleScreen({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TimeCapsuleScreen()),
    );
  }

  @override
  State<TimeCapsuleScreen> createState() => _TimeCapsuleScreenState();
}

class _TimeCapsuleScreenState extends State<TimeCapsuleScreen> {
  List<TimeCapsuleLetter> _letters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLetters();
    DatabaseHelper.appDataRevision.addListener(_loadLetters);
  }

  @override
  void dispose() {
    DatabaseHelper.appDataRevision.removeListener(_loadLetters);
    super.dispose();
  }

  Future<void> _loadLetters() async {
    final list = await DatabaseHelper.instance.getTimeCapsuleLetters();
    if (mounted) {
      setState(() {
        _letters = list;
        _isLoading = false;
      });
    }
  }

  String _getLocalizedMilestone(String milestone) {
    switch (milestone) {
      case '1st_birthday':
        return 'time_capsule_milestone_1'.tr();
      case 'wedding':
        return 'time_capsule_milestone_wedding'.tr();
      case '18th_birthday':
      default:
        return 'time_capsule_milestone_18'.tr();
    }
  }

  void _showNewLetterDialog() {
    final titleCtrl = TextEditingController();
    final letterCtrl = TextEditingController();
    String milestone = '18th_birthday';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'time_capsule_dialog_title'.tr(),
            style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.primaryDark),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'time_capsule_unlock_time_label'.tr(),
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DropdownButton<String>(
                    value: milestone,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: [
                      DropdownMenuItem(value: '1st_birthday', child: Text('time_capsule_milestone_1'.tr())),
                      DropdownMenuItem(value: '18th_birthday', child: Text('time_capsule_milestone_18'.tr())),
                      DropdownMenuItem(value: 'wedding', child: Text('time_capsule_milestone_wedding'.tr())),
                    ],
                    onChanged: (v) {
                      if (v != null) setDialogState(() => milestone = v);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    hintText: 'time_capsule_input_title_hint'.tr(),
                    hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 13),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: letterCtrl,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'time_capsule_input_letter_hint'.tr(),
                    hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 13),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ClayButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  color: AppColors.clayCardSurface,
                  borderRadius: 14,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(
                    'doctor_vault_btn_cancel'.tr(),
                    style: GoogleFonts.outfit(color: AppColors.textSecondary, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 10),
                ClayButton(
                  onPressed: () async {
                    final t = titleCtrl.text.trim();
                    final l = letterCtrl.text.trim();
                    if (t.isEmpty || l.isEmpty) return;
                    HapticFeedback.mediumImpact();
                    await DatabaseHelper.instance.insertTimeCapsuleLetter(
                      TimeCapsuleLetter(
                        unlockMilestone: milestone,
                        title: t,
                        letterText: l,
                        createdDate: DateTime.now().toIso8601String(),
                        targetUnlockDate: '2044-09-07',
                      ),
                    );
                    if (ctx.mounted) {
                      Navigator.of(ctx).pop();
                    }
                  },
                  color: AppColors.accentGold,
                  borderRadius: 14,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  child: Text(
                    'time_capsule_seal_btn'.tr(),
                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLetterDetail(TimeCapsuleLetter letter) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.mark_email_unread_rounded, size: 20, color: AppColors.accentGold),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                letter.title,
                style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.primaryDark, fontSize: 16),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'time_capsule_target_label'.tr(args: [_getLocalizedMilestone(letter.unlockMilestone)]),
                  style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  letter.letterText,
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.primaryDark, height: 1.45),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.medicalAlertRed, size: 20),
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  await DatabaseHelper.instance.deleteTimeCapsuleLetter(letter.id!);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                },
              ),
              ClayButton(
                onPressed: () => Navigator.of(ctx).pop(),
                color: AppColors.clayCardSurface,
                borderRadius: 14,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'btn_close'.tr(),
                  style: GoogleFonts.outfit(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPink))
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      children: [
                        _buildIntroCard(),
                        const SizedBox(height: 16),
                        if (_letters.isEmpty)
                          _buildEmptyState()
                        else ...[
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 10),
                            child: Text(
                              'time_capsule_list_heading'.tr(args: [_letters.length.toString()]),
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textMuted,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          ..._letters.map((l) => _buildLetterCard(l)),
                        ],
                        const SizedBox(height: 84),
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: ClayButton(
        onPressed: _showNewLetterDialog,
        color: AppColors.accentGold,
        borderRadius: 22,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.edit_note_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              'time_capsule_btn_seal'.tr(),
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          ClayButton(
            onPressed: () => Navigator.of(context).pop(),
            color: AppColors.clayCardSurface,
            width: 44,
            height: 44,
            borderRadius: 16,
            padding: EdgeInsets.zero,
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'time_capsule_appbar_title'.tr(),
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                Text(
                  'time_capsule_appbar_sub'.tr(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.hourglass_top_rounded, size: 20, color: AppColors.accentGold),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard() {
    return ClayCard(
      color: AppColors.clayPeach,
      borderRadius: 22,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.mark_email_read_rounded, size: 26, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'time_capsule_intro_title'.tr(),
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'time_capsule_intro_desc'.tr(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history_edu_rounded, size: 44, color: AppColors.accentGold),
            ),
            const SizedBox(height: 14),
            Text(
              'time_capsule_empty_title'.tr(),
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
            ),
            const SizedBox(height: 6),
            Text(
              'time_capsule_empty_sub'.tr(),
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterCard(TimeCapsuleLetter letter) {
    return ClayCard(
      color: AppColors.clayCardSurface,
      borderRadius: 20,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: () => _showLetterDetail(letter),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.lock_rounded, size: 20, color: AppColors.accentGold),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  letter.title,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'time_capsule_seal_tag'.tr(args: [_getLocalizedMilestone(letter.unlockMilestone)]),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.accentGold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
