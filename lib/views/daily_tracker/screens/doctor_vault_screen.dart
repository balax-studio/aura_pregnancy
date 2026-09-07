import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../models/doctor_question_model.dart';
import '../../../services/database_helper.dart';

/// Aura Pregnancy - Tam Ekran Doktora Sorulacak Sorular Kasası & Muayene Notları
class DoctorVaultScreen extends StatefulWidget {
  final int currentWeek;

  const DoctorVaultScreen({super.key, this.currentWeek = 1});

  static Future<void> open(BuildContext context, {int currentWeek = 1}) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DoctorVaultScreen(currentWeek: currentWeek)),
    );
  }

  @override
  State<DoctorVaultScreen> createState() => _DoctorVaultScreenState();
}

class _DoctorVaultScreenState extends State<DoctorVaultScreen> with SingleTickerProviderStateMixin {
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
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Muayenede hekime sormak istediğiniz konuyu yazın...',
            hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 13),
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
              elevation: 0,
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
          'Hekimin Yanıtı / Notu',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.primaryDark),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.claySky.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                q.question,
                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: answerCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Hekimin önerisini veya muayene sonucunu buraya not edin...',
                hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textMuted, fontSize: 12),
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
              elevation: 0,
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

    final answeredCount = _questions.where((q) => q.isAnswered).length;

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
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                          child: _buildSummaryCard(answeredCount),
                        ),
                        _buildTabBar(),
                        const SizedBox(height: 10),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildTrimesterList(t1List, 1),
                              _buildTrimesterList(t2List, 2),
                              _buildTrimesterList(t3List, 3),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddQuestionDialog(_tabController.index + 1),
        backgroundColor: AppColors.primaryPink,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'Soru Ekle',
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
                  'Soru Kasası',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                Text(
                  'Muayenede Hekime Sorulacak Sorular',
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
              color: AppColors.claySky,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text('🩺', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int answeredCount) {
    return ClayCard(
      color: AppColors.claySky,
      borderRadius: 20,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Muayene Hazırlığı & Notlar',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Toplam ${_questions.length} sorudan $answeredCount tanesi hekim tarafından yanıtlandı.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.primaryPink,
          borderRadius: BorderRadius.circular(14),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: '1. Trimester (1-13)'),
          Tab(text: '2. Trimester (14-27)'),
          Tab(text: '3. Trimester (28-40)'),
        ],
      ),
    );
  }

  Widget _buildTrimesterList(List<DoctorQuestion> list, int trimester) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🩺', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 12),
            Text(
              '$trimester. Trimester için soru yok.',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Aşağıdaki butona basarak aklınıza takılanları ekleyin.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 84),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: list.length + 1,
      itemBuilder: (context, index) {
        if (index == list.length) {
          return const SizedBox(height: 84);
        }
        final q = list[index];
        return _buildQuestionCard(q);
      },
    );
  }

  Widget _buildQuestionCard(DoctorQuestion q) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () async {
                      HapticFeedback.selectionClick();
                      await DatabaseHelper.instance.updateDoctorQuestionAnswer(
                        q.id!,
                        q.answerNote ?? '',
                        !q.isAnswered,
                      );
                    },
                    child: Container(
                      width: 26,
                      height: 26,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: q.isAnswered ? AppColors.successGreen : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: q.isAnswered ? AppColors.successGreen : AppColors.textMuted.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                      child: q.isAnswered
                          ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
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
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: q.isAnswered ? AppColors.textMuted : AppColors.primaryDark,
                            decoration: q.isAnswered ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${q.pregnancyWeek}. Hafta Sorusudur',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (q.answerNote != null && q.answerNote!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.clayMint.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.medical_services_outlined, size: 14, color: AppColors.successGreen),
                          const SizedBox(width: 6),
                          Text(
                            'Doktorun Yanıtı / Önerisi:',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        q.answerNote!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppColors.primaryDark,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => _showAnswerDialog(q),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            q.answerNote != null && q.answerNote!.isNotEmpty
                                ? Icons.edit_note_rounded
                                : Icons.add_comment_outlined,
                            size: 16,
                            color: AppColors.primaryDark,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            q.answerNote != null && q.answerNote!.isNotEmpty ? 'Yanıtı Düzenle' : 'Cevap / Not Ekle',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.medicalAlertRed),
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      await DatabaseHelper.instance.deleteDoctorQuestion(q.id!);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
