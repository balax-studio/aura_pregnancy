import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../models/diary_model.dart';
import '../../../utils/date_utils.dart';
import '../../../services/media_service.dart';
import 'clay_audio_player.dart';
import 'photo_view_dialog.dart';

/// Claymorphic Günlük Anı Kartı (Timeline formatı, fotoğraf, ses ve highlight rozeti)
class JournalEntryCard extends StatelessWidget {
  final DiaryModel entry;
  final VoidCallback? onDelete;

  const JournalEntryCard({
    super.key,
    required this.entry,
    this.onDelete,
  });

  IconData _getMoodIcon(int mood) {
    switch (mood) {
      case 1: return Icons.sentiment_very_dissatisfied_rounded;
      case 2: return Icons.sentiment_neutral_rounded;
      case 3: return Icons.sentiment_satisfied_rounded;
      case 4: return Icons.sentiment_very_satisfied_rounded;
      case 5: return Icons.favorite_rounded;
      default: return Icons.favorite_rounded;
    }
  }

  Color _getMoodColor(int mood) {
    switch (mood) {
      case 1: return AppColors.moodTired;
      case 2: return AppColors.moodNeutral;
      case 3: return AppColors.moodGood;
      case 4: return AppColors.moodHappy;
      case 5: return AppColors.moodPeaceful;
      default: return AppColors.primaryPink;
    }
  }

  String _getLocalizedNoteText(String note) {
    const sample1Tr = 'Bugün ilk defa ultrason görüntünde ellerini kıpırdattığını gördük bebeğim. O kadar minik ve masumdun ki... Hayatımızın en güzel anıydı.';
    const sample1En = 'Today for the first time we saw you moving your tiny hands in the ultrasound, my baby. You were so little and pure... It was the most beautiful moment of our lives.';
    const sample2Tr = 'Bugün ilk kez minik kalbinin pıt pıt atışlarını duyduk. Dünyanın en güzel ve huzur verici melodisiydi 🫐';
    const sample2En = 'Today we heard your tiny heartbeat flutter for the first time. It was the most peaceful and sweetest melody in the world 🫐';

    if (note == sample1Tr || note == sample1En || note == 'sample_diary_note_1') {
      return 'sample_diary_note_1'.tr();
    }
    if (note == sample2Tr || note == sample2En || note == 'sample_diary_note_2') {
      return 'sample_diary_note_2'.tr();
    }
    return note;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClayCard(
        color: entry.isRomanticHighlight ? AppColors.clayRose : AppColors.clayCardSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Bilgi Başlığı
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: ClayTheme.clayDecoration(
                        color: Colors.white,
                        borderRadius: 10,
                      ),
                      child: Center(
                        child: Icon(
                          _getMoodIcon(entry.moodRating),
                          color: _getMoodColor(entry.moodRating),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'journal_week_entry_title'.tr(args: [entry.pregnancyWeek.toString()]),
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        Text(
                          AppDateUtils.formatDisplay(entry.date, locale: context.locale.languageCode),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (entry.isRomanticHighlight)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPink,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'journal_highlight_badge'.tr(),
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.textMuted),
                        onPressed: onDelete,
                        tooltip: 'journal_delete_tooltip'.tr(),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Anı Notu
            if (entry.noteText != null && entry.noteText!.isNotEmpty)
              Text(
                _getLocalizedNoteText(entry.noteText!),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.45,
                ),
              ),

            // Fotoğraf Alanı (Varsa)
            if (entry.photoPath != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => PhotoViewDialog.show(
                  context,
                  entry.photoPath!,
                  title: 'journal_week_entry_title'.tr(args: [entry.pregnancyWeek.toString()]),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      MediaService.buildPhotoWidget(
                        entry.photoPath!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'journal_zoom'.tr(),
                              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Ses Kaydı / Çalma Alanı (Varsa)
            if (entry.audioPath != null) ...[
              const SizedBox(height: 12),
              ClayAudioPlayer(
                audioPath: entry.audioPath!,
                title: 'journal_audio_letter_title'.tr(args: [entry.pregnancyWeek.toString()]),
                durationSeconds: 30,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
