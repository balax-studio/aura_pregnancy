import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/clay_theme.dart';

import '../../models/profile_model.dart';
import '../../models/timeline_day_entry.dart';
import '../../services/database_helper.dart';
import '../../utils/date_utils.dart';
import '../journal/widgets/journal_entry_card.dart';
import '../journal/new_entry_screen.dart';
import '../weekly_panel/widgets/ad_reward_dialog.dart';
import '../widgets/clay_native_ad_card.dart';
import '../widgets/medical_disclaimer_sheet.dart';
import '../widgets/emergency_beacon_button.dart';
import 'widgets/clinical_summary_dialog.dart';

enum TimelineFilter { all, diaries, steps, waterCaffeine, weight }

/// Aura Pregnancy - Birleştirilmiş Girişler Zaman Tüneli (Timeline)
class TimelineScreen extends StatefulWidget {
  final bool showAppBar;
  const TimelineScreen({super.key, this.showAppBar = true});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  ProfileModel? _profile;
  List<TimelineDayEntry> _timelineEntries = [];
  bool _isLoading = true;
  TimelineFilter _selectedFilter = TimelineFilter.all;

  // İstatistik Sayaçları
  int _totalSteps = 0;
  int _totalWaterMl = 0;
  int _totalDiariesCount = 0;
  int _totalAudioLettersCount = 0;

  @override
  void initState() {
    super.initState();
    _loadTimelineData();
    DatabaseHelper.appDataRevision.addListener(_onAppDataChanged);
  }

  void _onAppDataChanged() {
    if (mounted) {
      _loadTimelineData();
    }
  }

  @override
  void dispose() {
    DatabaseHelper.appDataRevision.removeListener(_onAppDataChanged);
    super.dispose();
  }

  Future<void> _loadTimelineData() async {
    setState(() => _isLoading = true);
    try {
      _profile = await DatabaseHelper.instance.getProfile();
      final currentWeek = _profile?.currentWeek ?? 12;

      final allLogs = await DatabaseHelper.instance.getAllDailyLogs();
      final allDiaries = await DatabaseHelper.instance.getAllDiaries();

      // İstatistik toplamları
      _totalSteps = allLogs.fold(0, (sum, log) => sum + log.stepCount);
      _totalWaterMl = allLogs.fold(0, (sum, log) => sum + log.waterIntakeMl);
      _totalDiariesCount = allDiaries.length;
      _totalAudioLettersCount = allDiaries.where((d) => d.audioPath != null && d.audioPath!.isNotEmpty).length;

      // Tarihlere göre birleştirme haritası
      final Map<String, TimelineDayEntry> map = {};

      // 1. Günlük Takipleri ekle
      for (final log in allLogs) {
        map[log.date] = TimelineDayEntry(
          date: log.date,
          pregnancyWeek: currentWeek,
          dailyLog: log,
          diaries: [],
        );
      }

      // 2. Anıları tarihlerine göre eşleştir
      for (final diary in allDiaries) {
        if (map.containsKey(diary.date)) {
          final existing = map[diary.date]!;
          map[diary.date] = TimelineDayEntry(
            date: diary.date,
            pregnancyWeek: diary.pregnancyWeek,
            dailyLog: existing.dailyLog,
            diaries: [...existing.diaries, diary],
          );
        } else {
          map[diary.date] = TimelineDayEntry(
            date: diary.date,
            pregnancyWeek: diary.pregnancyWeek,
            dailyLog: null,
            diaries: [diary],
          );
        }
      }

      // Bugünün tarihi haritada yoksa ekle
      final today = AppDateUtils.todayIso();
      if (!map.containsKey(today)) {
        final todayLog = await DatabaseHelper.instance.getOrCreateDailyLog(today);
        map[today] = TimelineDayEntry(
          date: today,
          pregnancyWeek: currentWeek,
          dailyLog: todayLog,
          diaries: [],
        );
      }

      // Tarihe göre sırala (En yeniden eskiye)
      final sortedList = map.values.toList();
      sortedList.sort((a, b) => b.date.compareTo(a.date));

      _timelineEntries = sortedList;
    } catch (e) {
      debugPrint('Timeline load error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<TimelineDayEntry> get _filteredEntries {
    switch (_selectedFilter) {
      case TimelineFilter.all:
        return _timelineEntries;
      case TimelineFilter.diaries:
        return _timelineEntries.where((e) => e.hasDiaries).toList();
      case TimelineFilter.steps:
        return _timelineEntries.where((e) => e.totalSteps > 0).toList();
      case TimelineFilter.waterCaffeine:
        return _timelineEntries.where((e) => e.totalWaterMl > 0 || e.totalCaffeineMg > 0).toList();
      case TimelineFilter.weight:
        return _timelineEntries.where((e) => e.weightEntry != null).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryPink)),
      );
    }

    final filtered = _filteredEntries;

    final bodyContent = RefreshIndicator(
      onRefresh: _loadTimelineData,
      color: AppColors.primaryPink,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Genel İstatistik Hero Kartı
            _buildOverallSummaryCard(),
            const SizedBox(height: 10),

            // Hekim Klinik Raporu (Ödüllü Reklam ile Oluşturma)
            _buildDoctorReportAction(),
            const SizedBox(height: 14),

            // 2. Filtre Butonları (Chips)
            _buildFilterChips(),
            const SizedBox(height: 10),

            // Sponsorlu Destekçi Native Ad Kartı
            const ClayNativeAdCard(
              cardColor: Color(0xFFD6E4F0),
              icon: Icons.health_and_safety_rounded,
            ),
            const SizedBox(height: 14),

            // 3. Zaman Tüneli Akışı
            if (filtered.isEmpty)
              _buildEmptyState()
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final dayEntry = filtered[index];
                  return _buildTimelineDayItem(dayEntry, isFirst: index == 0, isLast: index == filtered.length - 1);
                },
              ),
            const SizedBox(height: 16),

            // Tıbbi Sorumluluk Reddi Bannerı
            const MedicalDisclaimerBanner(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Column(
                children: [
                  Text(
                    'timeline_appbar_title'.tr(),
                    style: GoogleFonts.outfit(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'timeline_appbar_subtitle'.tr(),
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
              actions: const [
                MedicalInfoButton(),
                SizedBox(width: 4),
                Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: EmergencyBeaconButton(),
                ),
              ],
            )
          : null,
      body: widget.showAppBar ? SafeArea(child: bodyContent) : bodyContent,
      floatingActionButton: ClayButton(
        color: AppColors.primaryPink,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NewEntryScreen(
                currentWeek: _profile?.currentWeek ?? 12,
                onSave: (entry) async {
                  await DatabaseHelper.instance.insertDiary(entry);
                  _loadTimelineData();
                },
              ),
            ),
          );
          _loadTimelineData();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.edit_note_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'journal_write_memory'.tr(),
              style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  /// Genel Toplam İstatistik Kartı
  Widget _buildOverallSummaryCard() {
    final distanceKm = (_totalSteps * 0.0007).toStringAsFixed(1);
    final waterLiters = (_totalWaterMl / 1000.0).toStringAsFixed(1);

    return ClayCard(
      color: AppColors.clayLavender,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: AppColors.primaryPink, size: 20),
              const SizedBox(width: 8),
              Text(
                'timeline_summary_title'.tr(),
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryBox('timeline_stat_steps'.tr(), '$_totalSteps', 'timeline_stat_distance_val'.tr(args: [distanceKm]), Icons.directions_walk_rounded, AppColors.clayMint),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryBox('timeline_stat_water'.tr(), '$waterLiters L', 'timeline_stat_water_val'.tr(args: [_totalWaterMl.toString()]), Icons.water_drop_rounded, AppColors.claySky),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSummaryBox('timeline_stat_diaries'.tr(), 'timeline_stat_count'.tr(args: [_totalDiariesCount.toString()]), 'timeline_stat_diaries_sub'.tr(), Icons.menu_book_rounded, AppColors.clayRose),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryBox('timeline_stat_audio'.tr(), 'timeline_stat_count'.tr(args: [_totalAudioLettersCount.toString()]), 'timeline_stat_audio_sub'.tr(), Icons.mic_rounded, AppColors.clayPeach),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Hekim Klinik Raporu (Ödüllü Reklam ile Oluşturma)
  Widget _buildDoctorReportAction() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: ClayTheme.clayDecoration(
        color: AppColors.clayMint,
        borderRadius: 20,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: ClayTheme.concaveDecoration(
              color: Colors.white,
              borderRadius: 14,
            ),
            child: const Center(
              child: Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF2E6135), size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'timeline_pdf_report_title'.tr(),
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2E6135),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'timeline_pdf_report_sub'.tr(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4A6B50),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ClayButton(
            color: Colors.white,
            height: 40,
            borderRadius: 12,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            onPressed: _openDoctorReportWithReward,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_circle_fill_rounded, color: Color(0xFF2E6135), size: 16),
                const SizedBox(width: 6),
                Text(
                  'timeline_pdf_report_btn'.tr(),
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2E6135),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openDoctorReportWithReward() {
    AdRewardDialog.show(
      context: context,
      title: 'timeline_pdf_report_title'.tr(),
      subtitle: 'timeline_pdf_report_sub'.tr(),
      unlockTargetName: 'timeline_pdf_report_title'.tr(),
      onRewardEarned: () {
        if (!mounted) return;
        ClinicalSummaryDialog.show(context);
      },
    );
  }

  Widget _buildSummaryBox(String title, String mainValue, String subValue, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: ClayTheme.clayDecoration(
        color: color,
        borderRadius: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.primaryDark),
              const SizedBox(width: 4),
              Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 4),
          Text(mainValue, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryDark)),
          Text(subValue, style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  /// Filtreleme Butonları
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('filter_all'.tr(), TimelineFilter.all, Icons.dashboard_rounded),
          _buildFilterChip('filter_diaries'.tr(), TimelineFilter.diaries, Icons.menu_book_rounded),
          _buildFilterChip('filter_steps'.tr(), TimelineFilter.steps, Icons.directions_walk_rounded),
          _buildFilterChip('filter_water_caffeine'.tr(), TimelineFilter.waterCaffeine, Icons.water_drop_rounded),
          _buildFilterChip('filter_weight'.tr(), TimelineFilter.weight, Icons.monitor_weight_rounded),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, TimelineFilter filter, IconData icon) {
    final isSelected = _selectedFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: ClayTheme.clayDecoration(
            color: isSelected ? AppColors.clayRose : Colors.white,
            borderRadius: 18,
            isPressed: isSelected,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: isSelected ? AppColors.primaryPink : AppColors.textSecondary),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? AppColors.primaryPink : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Zaman Tüneli Tek Bir Günlük Kartı
  Widget _buildTimelineDayItem(TimelineDayEntry day, {required bool isFirst, required bool isLast}) {
    final isToday = day.date == AppDateUtils.todayIso();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sol Dikey Çizgi ve Düğüm (Timeline Node)
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isToday ? AppColors.primaryPink : AppColors.clayRose,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPink.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  isToday ? Icons.star_rounded : Icons.fiber_manual_record_rounded,
                  size: isToday ? 12 : 8,
                  color: isToday ? Colors.white : AppColors.primaryPink,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 160 + (day.diaries.length * 120.0),
                color: AppColors.primaryPink.withValues(alpha: 0.2),
              ),
          ],
        ),
        const SizedBox(width: 12),

        // Sağ Ana Kart Gövdesi
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            child: ClayCard(
              color: isToday ? AppColors.clayRose : AppColors.clayCardSurface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gün Başlığı ve Hafta Rozeti
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            AppDateUtils.formatDisplay(day.date),
                            style: GoogleFonts.outfit(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          if (isToday) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryPink,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('common_today'.tr(), style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'weekly_week_range'.tr(args: [day.pregnancyWeek.toString()]),
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.secondaryPeach),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Günlük Takip Rozetleri
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (day.totalSteps > 0)
                        _buildBadgeChip('timeline_badge_steps'.tr(args: [day.totalSteps.toString()]), Icons.directions_walk_rounded, AppColors.clayMint, AppColors.successGreen),
                      if (day.totalWaterMl > 0)
                        _buildBadgeChip('timeline_badge_water'.tr(args: [day.totalWaterMl.toString()]), Icons.water_drop_rounded, AppColors.claySky, AppColors.waterBlue),
                      if (day.totalCaffeineMg > 0)
                        _buildBadgeChip(
                          'timeline_badge_caffeine'.tr(args: [day.totalCaffeineMg.toString()]),
                          Icons.local_cafe_rounded,
                          day.totalCaffeineMg > 200 ? AppColors.medicalAlertBg : AppColors.clayPeach,
                          day.totalCaffeineMg > 200 ? AppColors.medicalAlertRed : AppColors.secondaryPeach,
                        ),
                      if (day.weightEntry != null)
                        _buildBadgeChip('${day.weightEntry} kg', Icons.monitor_weight_rounded, AppColors.clayLavender, AppColors.primaryDark),
                    ],
                  ),

                  // Semptom Notu (Varsa)
                  if (day.symptomNotes != null && day.symptomNotes!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.medical_information_rounded, size: 14, color: AppColors.primaryPink),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              day.symptomNotes!,
                              style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Bu Güne Ait Anı Kartları (Varsa)
                  if (day.diaries.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Colors.black12),
                    const SizedBox(height: 12),
                    ...day.diaries.map((diary) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: JournalEntryCard(
                          entry: diary,
                          onDelete: () async {
                            if (diary.id != null) {
                              await DatabaseHelper.instance.deleteDiary(diary.id!);
                              _loadTimelineData();
                            }
                          },
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeChip(String label, IconData icon, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: ClayTheme.clayDecoration(
        color: bg,
        borderRadius: 14,
        isPressed: true,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.calendar_month_rounded, size: 48, color: AppColors.primaryPink),
            const SizedBox(height: 12),
            Text(
              'timeline_empty_title'.tr(),
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
            ),
            const SizedBox(height: 6),
            Text(
              'timeline_empty_desc'.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
