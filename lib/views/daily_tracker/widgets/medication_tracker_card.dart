import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../models/medication_model.dart';
import '../../../services/database_helper.dart';
import '../../../utils/date_utils.dart';

/// Claymorphic İlaç & Vitamin Takip Kartı
class MedicationTrackerCard extends StatefulWidget {
  const MedicationTrackerCard({super.key});

  @override
  State<MedicationTrackerCard> createState() => _MedicationTrackerCardState();
}

class _MedicationTrackerCardState extends State<MedicationTrackerCard> {
  List<MedicationModel> _medications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
    DatabaseHelper.appDataRevision.addListener(_onDataChanged);
  }

  void _onDataChanged() {
    if (mounted) _loadMedications();
  }

  @override
  void dispose() {
    DatabaseHelper.appDataRevision.removeListener(_onDataChanged);
    super.dispose();
  }

  Future<void> _loadMedications() async {
    try {
      final list = await DatabaseHelper.instance.getMedications();
      if (mounted) {
        setState(() {
          _medications = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Load medications error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleTaken(MedicationModel med) async {
    final today = AppDateUtils.todayIso();
    final isCurrentlyTaken = med.isTakenOnDate(today);
    final nextState = !isCurrentlyTaken;

    await DatabaseHelper.instance.toggleMedicationTaken(med.id!, today, nextState);
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nextState
              ? 'med_marked_taken'.tr(args: [med.name])
              : 'med_marked_untaken'.tr(args: [med.name]),
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        backgroundColor: nextState ? AppColors.successGreen : AppColors.secondaryPeach,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openAddMedicationSheet() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController(text: '1 Tablet');
    String selectedTime = 'Sabah Tok';
    String selectedCategory = 'Vitamin';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.medication_rounded, color: AppColors.primaryDark, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'med_add_title'.tr(),
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // İlaç Adı
                  TextField(
                    controller: nameController,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                    decoration: InputDecoration(
                      labelText: 'med_name_label'.tr(),
                      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary),
                      hintText: 'med_name_hint'.tr(),
                      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textMuted),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Dozaj
                  TextField(
                    controller: dosageController,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                    decoration: InputDecoration(
                      labelText: 'med_dosage_label'.tr(),
                      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textSecondary),
                      hintText: 'med_dosage_hint'.tr(),
                      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textMuted),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Öğün / Saat Seçimi
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedTime,
                          decoration: InputDecoration(
                            labelText: 'med_time_label'.tr(),
                            labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                          items: [
                            DropdownMenuItem(value: 'Sabah Aç', child: Text('med_time_morning_empty'.tr(), style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textPrimary))),
                            DropdownMenuItem(value: 'Sabah Tok', child: Text('med_time_morning_full'.tr(), style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textPrimary))),
                            DropdownMenuItem(value: 'Öğle', child: Text('med_time_noon'.tr(), style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textPrimary))),
                            DropdownMenuItem(value: 'Akşam Tok', child: Text('med_time_evening_full'.tr(), style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textPrimary))),
                            DropdownMenuItem(value: 'Gece Yatarken', child: Text('med_time_night'.tr(), style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textPrimary))),
                          ],
                          onChanged: (val) => setSheetState(() => selectedTime = val ?? selectedTime),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedCategory,
                          decoration: InputDecoration(
                            labelText: 'med_category_label'.tr(),
                            labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                          ),
                          items: [
                            DropdownMenuItem(value: 'Vitamin', child: Text('med_cat_vitamin'.tr(), style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textPrimary))),
                            DropdownMenuItem(value: 'Mineral', child: Text('med_cat_mineral'.tr(), style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textPrimary))),
                            DropdownMenuItem(value: 'Demir', child: Text('med_cat_iron'.tr(), style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textPrimary))),
                            DropdownMenuItem(value: 'İlaç', child: Text('med_cat_medication'.tr(), style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textPrimary))),
                            DropdownMenuItem(value: 'Takviye', child: Text('med_cat_supplement'.tr(), style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppColors.textPrimary))),
                          ],
                          onChanged: (val) => setSheetState(() => selectedCategory = val ?? selectedCategory),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  ClayButton(
                    color: AppColors.clayMint,
                    onPressed: () async {
                      final name = nameController.text.trim();
                      if (name.isEmpty) return;

                      final newMed = MedicationModel(
                        name: name,
                        dosage: dosageController.text.trim().isNotEmpty ? dosageController.text.trim() : '1 Tablet',
                        time: selectedTime,
                        category: selectedCategory,
                      );

                      await DatabaseHelper.instance.insertMedication(newMed);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_rounded, color: AppColors.successGreen, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'med_save_button'.tr(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.successGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayIso = AppDateUtils.todayIso();
    final takenCount = _medications.where((m) => m.isTakenOnDate(todayIso)).length;
    final totalCount = _medications.length;

    return ClayCard(
      color: AppColors.clayLavender,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst Başlık ve İlaç Ekle Butonu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: ClayTheme.clayDecoration(
                      color: Colors.white,
                      borderRadius: 12,
                    ),
                    child: const Center(
                      child: Icon(Icons.medication_rounded, color: AppColors.lavenderPurple, size: 20),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'med_tracker_title'.tr(),
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        'med_taken_summary'.tr(args: [takenCount.toString(), totalCount.toString()]),
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
              ClayButton(
                color: AppColors.clayRose,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                onPressed: _openAddMedicationSheet,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded, size: 16, color: AppColors.primaryPink),
                    const SizedBox(width: 2),
                    Text(
                      'med_add_button'.tr(),
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(color: AppColors.primaryPink)))
          else if (_medications.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(16)),
              child: Center(
                child: Text(
                  'med_empty_state'.tr(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
              ),
            )
          else
            Column(
              children: _medications.map((med) {
                final isTaken = med.isTakenOnDate(todayIso);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: ClayTheme.clayDecoration(
                    color: isTaken ? AppColors.clayMint : Colors.white,
                    borderRadius: 16,
                    isPressed: isTaken,
                  ),
                  child: Row(
                    children: [
                      // Alındı / Alınmadı Checkbox Butonu
                      GestureDetector(
                        onTap: () => _toggleTaken(med),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: ClayTheme.clayDecoration(
                            color: isTaken ? AppColors.successGreen : AppColors.clayCardSurface,
                            borderRadius: 10,
                            isPressed: isTaken,
                          ),
                          child: Center(
                            child: Icon(
                              isTaken ? Icons.check_rounded : Icons.circle_outlined,
                              size: 18,
                              color: isTaken ? Colors.white : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // İlaç Detayları
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              med.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isTaken ? AppColors.successGreen : AppColors.primaryDark,
                                decoration: isTaken ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${med.dosage} • ${med.time}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Silme Butonu
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
                        tooltip: 'common_delete'.tr(),
                        onPressed: () async {
                          await DatabaseHelper.instance.deleteMedication(med.id!);
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.verified_user_outlined, color: AppColors.secondaryPeach, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'disclaimer_medication'.tr(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
