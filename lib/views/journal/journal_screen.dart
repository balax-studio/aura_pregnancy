import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/clay_theme.dart';
import '../../controllers/journal_controller.dart';
import 'widgets/journal_entry_card.dart';
import 'widgets/video_renderer_dialog.dart';
import 'widgets/watercolor_portrait_dialog.dart';
import 'widgets/keepsake_card_dialog.dart';
import 'widgets/time_capsule_sheet.dart';
import '../widgets/emergency_beacon_button.dart';
import 'new_entry_screen.dart';

import '../../services/database_helper.dart';

/// Aura Journal (Romantik Anı Günlüğü) Ana Ekranı
class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final JournalController _controller = JournalController();

  @override
  void initState() {
    super.initState();
    _controller.loadDiaries();
    _controller.addListener(_onControllerUpdate);
    DatabaseHelper.appDataRevision.addListener(_onAppDataChanged);
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  void _onAppDataChanged() {
    if (mounted) {
      _controller.loadDiaries();
    }
  }

  @override
  void dispose() {
    DatabaseHelper.appDataRevision.removeListener(_onAppDataChanged);
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'journal_app_bar_title'.tr(),
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
          ),
        ),
        actions: [
          // Time-Lapse Video Üretici Butonu
          IconButton(
            icon: const Icon(Icons.movie_creation_rounded, color: AppColors.primaryPink),
            tooltip: 'journal_create_video_tooltip'.tr(),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => VideoRendererDialog(
                  highlightEntries: _controller.highlightEntries,
                ),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.only(right: 14),
            child: EmergencyBeaconButton(),
          ),
        ],
      ),
      body: SafeArea(
        child: _controller.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPink))
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  // Aura Yaratıcı Atölye (Suluboya, Hatıra Kartı, Time-Lapse Video Konsolide Vitrini)
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: AppColors.primaryPink, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'studio_section_title'.tr(),
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.clayLavender,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '4 Atölye',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryPink,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Yatay Kaydırılabilir Stüdyo Kartları
                  SizedBox(
                    height: 160,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      children: [
                        // 1. Masalsı Suluboya Portresi
                        SizedBox(
                          width: 190,
                          child: GestureDetector(
                            onTap: () => WatercolorPortraitDialog.show(context),
                            child: ClayCard(
                              color: AppColors.clayRose,
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.90),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.palette_rounded, color: AppColors.primaryPink, size: 20),
                                      ),
                                      const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.primaryPink),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    'portrait_watercolor_title'.tr(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'portrait_watercolor_badge'.tr(),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryPink,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // 2. Özel Hatıra Kartı
                        SizedBox(
                          width: 190,
                          child: GestureDetector(
                            onTap: () => KeepsakeCardDialog.show(context),
                            child: ClayCard(
                              color: AppColors.clayPeach,
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.90),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.card_giftcard_rounded, color: AppColors.secondaryPeach, size: 20),
                                      ),
                                      const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.secondaryPeach),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    'keepsake_card_title'.tr(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'keepsake_card_badge'.tr(),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.secondaryPeach,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // 3. Time-Lapse Video Üretici
                        SizedBox(
                          width: 190,
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => VideoRendererDialog(
                                  highlightEntries: _controller.highlightEntries,
                                ),
                              );
                            },
                            child: ClayCard(
                              color: AppColors.clayLavender,
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.90),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.movie_creation_rounded, color: AppColors.primaryPink, size: 20),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.6),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${_controller.highlightEntries.length}',
                                          style: GoogleFonts.outfit(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primaryPink,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    'journal_timelapse_title'.tr(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'journal_generate_btn'.tr(),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryPink,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // 4. 18. Yaş Dijital Zaman Kapsülü
                        SizedBox(
                          width: 190,
                          child: GestureDetector(
                            onTap: () => TimeCapsuleSheet.show(context),
                            child: ClayCard(
                              color: AppColors.clayMint,
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.90),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.mark_email_unread_rounded, color: AppColors.successGreen, size: 20),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.6),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '18. YAŞ',
                                          style: GoogleFonts.outfit(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.successGreen,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    '18. Yaş Kapsülü',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Bebeğime Mektup 💌',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.successGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'journal_timeline_heading'.tr(),
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Günlük Kartları veya Boş Durum (Empty State)
                  if (_controller.entries.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                      decoration: ClayTheme.clayDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: 22,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: ClayTheme.clayDecoration(
                              color: AppColors.clayRose,
                              borderRadius: 27,
                            ),
                            child: const Center(
                              child: Icon(Icons.edit_note_rounded, color: AppColors.primaryPink, size: 28),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'journal_empty_title'.tr(),
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'journal_empty_desc'.tr(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.quicksand(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._controller.entries.map(
                      (entry) => JournalEntryCard(
                        entry: entry,
                        onDelete: () => _controller.deleteEntry(entry.id!),
                      ),
                    ),
                  const SizedBox(height: 84),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryPink,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => NewEntryScreen(
                currentWeek: _controller.currentWeek,
                onSave: (entry) => _controller.addEntry(entry),
              ),
            ),
          );
        },
        icon: const Icon(Icons.favorite_rounded, color: Colors.white),
        label: Text(
          'journal_write_memory'.tr(),
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.2),
        ),
      ),
    );
  }
}
