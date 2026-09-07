import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../models/time_capsule_model.dart';
import '../../../services/database_helper.dart';

import '../screens/time_capsule_screen.dart';

/// Aura Pregnancy - 18. Yaş Dijital Zaman Kapsülü & Bebeğime Mektuplar
class TimeCapsuleSheet extends StatefulWidget {
  const TimeCapsuleSheet({super.key});

  static Future<void> show(BuildContext context) {
    return TimeCapsuleScreen.open(context);
  }

  @override
  State<TimeCapsuleSheet> createState() => _TimeCapsuleSheetState();
}

class _TimeCapsuleSheetState extends State<TimeCapsuleSheet> {
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
                const SizedBox(height: 4),
                DropdownButton<String>(
                  value: milestone,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: '1st_birthday', child: Text('🎂 1. Yaş Doğum Günü')),
                    DropdownMenuItem(value: '18th_birthday', child: Text('🎓 18. Yaş Doğum Günü')),
                    DropdownMenuItem(value: 'wedding', child: Text('💍 Evlendiği Gün')),
                  ],
                  onChanged: (v) {
                    if (v != null) setDialogState(() => milestone = v);
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    hintText: 'Mektup Başlığı (Örn: İlk hissettiğim an...)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: letterCtrl,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Bebeğine gelecekte okuyacağı nasihat ve sevgilerini yaz...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Kapsülü Mühürle 🔒', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
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
              color: AppColors.textMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 14),

          // Başlık
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('⏳', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '18. Yaş Zaman Kapsülü',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        'Geleceğe Mühürlü Sevgi Mektupları',
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
          ),
          const SizedBox(height: 16),

          // Liste
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.accentGold))
                : _letters.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🔒', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 10),
                            Text(
                              'Henüz Mühürlü Mektup Yok',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Bebeğinizin 18. yaşına ilk mektubu bırakın.',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: _letters.length,
                        itemBuilder: (context, index) {
                          final item = _letters[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ClayCard(
                              color: AppColors.clayCardSurface,
                              borderRadius: 20,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.accentGold.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          item.milestoneTitle,
                                          style: GoogleFonts.outfit(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.accentGold,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      const Icon(Icons.lock_rounded, color: AppColors.accentGold, size: 18),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    item.title,
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.letterText,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Mühürlenme Tarihi: ${item.createdDate.split("T")[0]}',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 10,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // Yeni Mektup Ekle Butonu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: InkWell(
              onTap: _showNewLetterDialog,
              borderRadius: BorderRadius.circular(18),
              child: ClayCard(
                color: AppColors.accentGold.withValues(alpha: 0.25),
                borderRadius: 18,
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline_rounded, color: AppColors.primaryDark, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Yeni Gelecek Mektubu Mühürle',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
