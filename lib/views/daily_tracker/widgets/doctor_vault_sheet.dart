import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../models/doctor_question_model.dart';
import '../../../services/database_helper.dart';

/// Aura Pregnancy - Doktora Sorulacak Sorular Kasası & Muayene Notları Modal Sheet
class DoctorVaultSheet extends StatefulWidget {
  final int currentWeek;

  const DoctorVaultSheet({super.key, this.currentWeek = 1});

  static Future<void> show(BuildContext context, {int currentWeek = 1}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DoctorVaultSheet(currentWeek: currentWeek),
    );
  }

  @override
  State<DoctorVaultSheet> createState() => _DoctorVaultSheetState();
}

class _DoctorVaultSheetState extends State<DoctorVaultSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _newQuestionController = TextEditingController();
  List<DoctorQuestion> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    int initialTab = 0;
    if (widget.currentWeek > 13 && widget.currentWeek <= 27) initialTab = 1;
    if (widget.currentWeek > 27) initialTab = 2;
    _tabController = TabController(length: 3, vsync: this, initialIndex: initialTab);
    _loadQuestions();
    DatabaseHelper.appDataRevision.addListener(_loadQuestions);
  }

  @override
  void dispose() {
    DatabaseHelper.appDataRevision.removeListener(_loadQuestions);
    _tabController.dispose();
    _newQuestionController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final list = await DatabaseHelper.instance.getDoctorQuestions();
    if (mounted) {
      setState(() {
        _questions = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _addQuestion(int trimester) async {
    final text = _newQuestionController.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.mediumImpact();
    await DatabaseHelper.instance.insertDoctorQuestion(
      DoctorQuestion(
        pregnancyWeek: widget.currentWeek,
        trimester: trimester,
        question: text,
        createdDate: DateTime.now().toIso8601String(),
      ),
    );
    _newQuestionController.clear();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showAddQuestionDialog(int trimester) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Doktora Yeni Soru Ekle',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.primaryDark),
        ),
        content: TextField(
          controller: _newQuestionController,
          autofocus: true,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Muayenede hekime sormak istediğiniz konuyu yazın...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('İptal', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => _addQuestion(trimester),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPink,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('Kaydet', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAnswerDialog(DoctorQuestion q) {
    final answerCtrl = TextEditingController(text: q.answerNote ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Doktorun Yanıtı / Notu',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.primaryDark),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              q.question,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: answerCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Hekimin önerisini veya muayene sonucunu buraya not edin...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Vazgeç', style: GoogleFonts.outfit(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              HapticFeedback.lightImpact();
              await DatabaseHelper.instance.updateDoctorQuestionAnswer(
                q.id!,
                answerCtrl.text.trim(),
                answerCtrl.text.trim().isNotEmpty,
              );
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPink,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('Kaydet & İşaretle', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t1List = _questions.where((q) => q.trimester == 1).toList();
    final t2List = _questions.where((q) => q.trimester == 2).toList();
    final t3List = _questions.where((q) => q.trimester == 3).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
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
                    color: AppColors.clayLavender,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('🩺', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Doktora Sorulacaklar Kasası',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        'Unutkanlığa Son: Muayene Not Kasası',
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
          const SizedBox(height: 14),

          // Trimester Sekmeleri
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.clayCardSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primaryPink,
                borderRadius: BorderRadius.circular(14),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12.5),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: '1. Trimester (1-13)'),
                Tab(text: '2. Trimester (14-27)'),
                Tab(text: '3. Trimester (28-40)'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPink))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTrimesterTab(t1List, 1),
                      _buildTrimesterTab(t2List, 2),
                      _buildTrimesterTab(t3List, 3),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrimesterTab(List<DoctorQuestion> list, int trimester) {
    return Column(
      children: [
        Expanded(
          child: list.isEmpty
              ? Center(
                  child: Text(
                    'Henüz soru eklenmedi.',
                    style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textMuted),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final q = list[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ClayCard(
                        color: q.isAnswered ? AppColors.clayMint : AppColors.clayCardSurface,
                        borderRadius: 20,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    HapticFeedback.lightImpact();
                                    await DatabaseHelper.instance.updateDoctorQuestionAnswer(
                                      q.id!,
                                      q.answerNote ?? '',
                                      !q.isAnswered,
                                    );
                                  },
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: q.isAnswered ? AppColors.successGreen : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: q.isAnswered ? AppColors.successGreen : AppColors.textMuted.withValues(alpha: 0.5),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: q.isAnswered
                                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        q.question,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: q.isAnswered ? AppColors.textMuted : AppColors.textPrimary,
                                          decoration: q.isAnswered ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                      if (q.isPredefined)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            'Önerilen Klinik Soru 💡',
                                            style: GoogleFonts.outfit(
                                              fontSize: 10.5,
                                              color: AppColors.primaryPink,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (!q.isPredefined)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.textMuted),
                                    onPressed: () async {
                                      HapticFeedback.selectionClick();
                                      await DatabaseHelper.instance.deleteDoctorQuestion(q.id!);
                                    },
                                  ),
                              ],
                            ),
                            // Varsa Hekim Yanıtı
                            if (q.answerNote != null && q.answerNote!.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Doktorun Yanıtı:',
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      q.answerNote!,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () => _showAnswerDialog(q),
                                icon: const Icon(Icons.edit_note_rounded, size: 16, color: AppColors.primaryPink),
                                label: Text(
                                  q.answerNote == null || q.answerNote!.isEmpty ? 'Hekim Notu Ekle' : 'Notu Düzenle',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryPink,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        // Soru Ekleme Butonu
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: InkWell(
            onTap: () => _showAddQuestionDialog(trimester),
            borderRadius: BorderRadius.circular(18),
            child: ClayCard(
              color: AppColors.clayLavender,
              borderRadius: 18,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_circle_outline_rounded, color: AppColors.lavenderPurple, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Bu Trimester İçin Soru Ekle',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.lavenderPurple,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
