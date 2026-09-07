import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
            'Geleceğe Mektup Mühürle 💌',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.primaryDark),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mühür Açılış Zamanı:',
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
                    items: const [
                      DropdownMenuItem(value: '1st_birthday', child: Text('🎂 1. Yaş Doğum Günü')),
                      DropdownMenuItem(value: '18th_birthday', child: Text('🎓 18. Yaş Doğum Günü')),
                      DropdownMenuItem(value: 'wedding', child: Text('💍 Evlendiği Gün')),
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
                    hintText: 'Mektup Başlığı (Örn: İlk tekmendeki hislerim...)',
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
                    hintText: 'Bebeğinize gelecekte okuyacağı sevgi dolu cümlelerinizi yazın...',
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
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Vazgeç', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGold,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Kapsülü Mühürle 🔒', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
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
            const Text('💌', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
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
                  'Mühür Hedefi: ${letter.milestoneTitle}',
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
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Kapat', style: GoogleFonts.outfit(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.medicalAlertRed, size: 20),
            onPressed: () async {
              HapticFeedback.lightImpact();
              await DatabaseHelper.instance.deleteTimeCapsuleLetter(letter.id!);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
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
                              'MÜHÜRLÜ MEKTUPLAR (${_letters.length})',
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewLetterDialog,
        backgroundColor: AppColors.accentGold,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.edit_note_rounded, color: Colors.white),
        label: Text(
          'Mektup Mühürle',
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).pop();
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.primaryDark),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Zaman Kapsülü',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                Text(
                  'Bebeğinize Geleceğe Mühürlü Mektuplar',
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
            child: const Text('⏳', style: TextStyle(fontSize: 20)),
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
          const Text('💌', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '18 Yıl Sonra Açılacak Bir Miras',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Şu an hissettiğiniz heyecan ve sevgiyi kelimelere dökün. Zamanı geldiğinde bebeğiniz bu satırları gözyaşlarıyla okuyacak.',
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
            const Text('📜', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'Henüz mühürlenmiş mektup yok.',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
            ),
            const SizedBox(height: 6),
            Text(
              'Aşağıdaki butona basarak ilk sevgi mektubunuzu yazın.',
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterCard(TimeCapsuleLetter letter) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showLetterDetail(letter),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                offset: const Offset(0, 4),
                blurRadius: 10,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(child: Text('🔒', style: TextStyle(fontSize: 20))),
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
                        'Mühür: ${letter.milestoneTitle}',
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
          ),
        ),
      ),
    );
  }
}
