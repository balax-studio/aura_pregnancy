import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/clay_theme.dart';
import '../../controllers/journal_controller.dart';
import 'widgets/journal_entry_card.dart';
import 'widgets/video_renderer_dialog.dart';
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
                    ClayCard(
                      color: AppColors.clayCardSurface,
                      borderRadius: 22,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: AppColors.clayRose,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryPink.withValues(alpha: 0.25),
                                width: 1.5,
                              ),
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
      floatingActionButton: ClayButton(
        color: AppColors.primaryPink,
        height: 50,
        borderRadius: 22,
        padding: const EdgeInsets.symmetric(horizontal: 20),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              'journal_write_memory'.tr(),
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontSize: 13,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
