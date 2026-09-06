import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/inset_box_shadow.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../models/emergency_card_model.dart';

/// Claymorphic Acil Tıbbi Kart Düzenleme Bottom Sheet Formu
class EditEmergencyCardSheet extends StatefulWidget {
  final EmergencyCardModel card;
  final ValueChanged<EmergencyCardModel> onSave;

  const EditEmergencyCardSheet({
    super.key,
    required this.card,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    required EmergencyCardModel card,
    required ValueChanged<EmergencyCardModel> onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditEmergencyCardSheet(card: card, onSave: onSave),
    );
  }

  @override
  State<EditEmergencyCardSheet> createState() => _EditEmergencyCardSheetState();
}

class _EditEmergencyCardSheetState extends State<EditEmergencyCardSheet> {
  late TextEditingController _nameController;
  late TextEditingController _bloodTypeController;
  late TextEditingController _allergiesController;
  late TextEditingController _chronicController;
  late TextEditingController _medicationsController;
  late TextEditingController _doctorNameController;
  late TextEditingController _doctorPhoneController;
  late TextEditingController _hospitalController;
  late TextEditingController _contactNameController;
  late TextEditingController _contactPhoneController;
  late TextEditingController _symptomsController;

  static const List<String> _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', '0+', '0-'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.card.patientName);
    _bloodTypeController = TextEditingController(text: widget.card.bloodType);
    _allergiesController = TextEditingController(text: widget.card.allergies);
    _chronicController = TextEditingController(text: widget.card.chronicDiseases);
    _medicationsController = TextEditingController(text: widget.card.medications);
    _doctorNameController = TextEditingController(text: widget.card.doctorName);
    _doctorPhoneController = TextEditingController(text: widget.card.doctorPhone);
    _hospitalController = TextEditingController(text: widget.card.hospitalName);
    _contactNameController = TextEditingController(text: widget.card.emergencyContactName);
    _contactPhoneController = TextEditingController(text: widget.card.emergencyContactPhone);
    _symptomsController = TextEditingController(text: widget.card.recentSymptoms);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bloodTypeController.dispose();
    _allergiesController.dispose();
    _chronicController.dispose();
    _medicationsController.dispose();
    _doctorNameController.dispose();
    _doctorPhoneController.dispose();
    _hospitalController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _symptomsController.dispose();
    super.dispose();
  }

  void _save() {
    final updated = widget.card.copyWith(
      patientName: _nameController.text.trim(),
      bloodType: _bloodTypeController.text.trim(),
      allergies: _allergiesController.text.trim(),
      chronicDiseases: _chronicController.text.trim(),
      medications: _medicationsController.text.trim(),
      doctorName: _doctorNameController.text.trim(),
      doctorPhone: _doctorPhoneController.text.trim(),
      hospitalName: _hospitalController.text.trim(),
      emergencyContactName: _contactNameController.text.trim(),
      emergencyContactPhone: _contactPhoneController.text.trim(),
      recentSymptoms: _symptomsController.text.trim(),
    );

    widget.onSave(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        children: [
          // Çekme Tutamacı (Drag Handle)
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Başlık Satırı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: ClayTheme.clayDecoration(
                      color: AppColors.clayRose,
                      borderRadius: 14,
                    ),
                    child: const Center(
                      child: Icon(Icons.edit_note_rounded, color: AppColors.primaryPink, size: 22),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'emergency_edit_sheet_title'.tr(),
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Form Alanları (Kaydırılabilir)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionHeader('emergency_section_personal'.tr(), Icons.person_rounded),
                  _buildTextField(
                    controller: _nameController,
                    label: 'medical_card_patient'.tr(),
                    hint: 'emergency_hint_patient'.tr(),
                    icon: Icons.badge_rounded,
                  ),
                  const SizedBox(height: 10),

                  // Kan Grubu Seçici
                  Text(
                    'medical_card_blood'.tr(),
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _bloodTypes.map((type) {
                      final isSelected = _bloodTypeController.text == type;
                      return GestureDetector(
                        onTap: () => setState(() => _bloodTypeController.text = type),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: ClayTheme.clayDecoration(
                            color: isSelected ? AppColors.clayRose : Colors.white,
                            borderRadius: 14,
                            isPressed: isSelected,
                          ),
                          child: Text(
                            type,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? AppColors.primaryPink : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  _buildSectionHeader('emergency_section_medical'.tr(), Icons.medical_services_rounded),
                  _buildTextField(
                    controller: _allergiesController,
                    label: 'medical_card_allergies'.tr(),
                    hint: 'emergency_hint_allergies'.tr(),
                    icon: Icons.warning_amber_rounded,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _chronicController,
                    label: 'medical_card_chronic'.tr(),
                    hint: 'emergency_hint_chronic'.tr(),
                    icon: Icons.favorite_border_rounded,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _medicationsController,
                    label: 'medical_card_meds'.tr(),
                    hint: 'emergency_hint_meds'.tr(),
                    icon: Icons.medication_rounded,
                  ),
                  const SizedBox(height: 16),

                  _buildSectionHeader('emergency_section_doctor'.tr(), Icons.health_and_safety_rounded),
                  _buildTextField(
                    controller: _doctorNameController,
                    label: 'medical_card_doctor'.tr(),
                    hint: 'emergency_hint_doctor'.tr(),
                    icon: Icons.person_pin_rounded,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _doctorPhoneController,
                    label: 'medical_card_doc_phone'.tr(),
                    hint: 'emergency_hint_doc_phone'.tr(),
                    icon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _hospitalController,
                    label: 'medical_card_hospital'.tr(),
                    hint: 'emergency_hint_hospital'.tr(),
                    icon: Icons.local_hospital_rounded,
                  ),
                  const SizedBox(height: 16),

                  _buildSectionHeader('emergency_section_contact'.tr(), Icons.contact_phone_rounded),
                  _buildTextField(
                    controller: _contactNameController,
                    label: 'emergency_contact_name_label'.tr(),
                    hint: 'emergency_hint_contact_name'.tr(),
                    icon: Icons.account_circle_rounded,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    controller: _contactPhoneController,
                    label: 'emergency_contact_phone_label'.tr(),
                    hint: 'emergency_hint_contact_phone'.tr(),
                    icon: Icons.phone_android_rounded,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  _buildSectionHeader('medical_card_symptoms'.tr(), Icons.note_alt_rounded),
                  _buildTextField(
                    controller: _symptomsController,
                    label: 'emergency_symptoms_label'.tr(),
                    hint: 'emergency_hint_symptoms'.tr(),
                    icon: Icons.description_rounded,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Kaydet Butonu
          ClayButton(
            color: AppColors.primaryPink,
            height: 52,
            onPressed: _save,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'common_save'.tr(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryPink),
          const SizedBox(width: 6),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: ClayTheme.clayDecoration(
            color: Colors.white,
            borderRadius: 16,
            isPressed: true,
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.textMuted, size: 18),
              hintText: hint,
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
