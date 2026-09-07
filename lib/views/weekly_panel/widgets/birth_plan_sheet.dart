import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/clay_theme.dart';
import '../../../models/birth_plan_model.dart';
import '../../../models/profile_model.dart';
import '../../../services/database_helper.dart';
import '../../../services/birth_plan_pdf_service.dart';

import '../screens/birth_plan_screen.dart';

/// Aura Pregnancy - Kişisel Doğum Tercihleri ve Planı
class BirthPlanSheet extends StatefulWidget {
  final ProfileModel? profile;

  const BirthPlanSheet({super.key, this.profile});

  static Future<void> show(BuildContext context, {ProfileModel? profile}) {
    return BirthPlanScreen.open(context, profile: profile);
  }

  @override
  State<BirthPlanSheet> createState() => _BirthPlanSheetState();
}

class _BirthPlanSheetState extends State<BirthPlanSheet> {
  BirthPlanModel _plan = const BirthPlanModel();
  bool _isLoading = true;
  bool _isExporting = false;
  final TextEditingController _specialWishesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  @override
  void dispose() {
    _specialWishesController.dispose();
    super.dispose();
  }

  Future<void> _loadPlan() async {
    final plan = await DatabaseHelper.instance.getBirthPlan();
    if (mounted) {
      setState(() {
        _plan = plan;
        _specialWishesController.text = plan.specialWishes;
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePlan(BirthPlanModel newPlan) async {
    HapticFeedback.selectionClick();
    setState(() => _plan = newPlan);
    await DatabaseHelper.instance.saveBirthPlan(newPlan);
  }

  Future<void> _exportPdf() async {
    HapticFeedback.mediumImpact();
    setState(() => _isExporting = true);
    try {
      final updatedPlan = _plan.copyWith(specialWishes: _specialWishesController.text.trim());
      await DatabaseHelper.instance.saveBirthPlan(updatedPlan);
      await BirthPlanPdfService.instance.generateAndShareBirthPlan(
        profile: widget.profile,
        plan: updatedPlan,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF oluşturma hatası: $e'),
            backgroundColor: AppColors.medicalAlertRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

          // Başlık ve Altın Mühür Rozeti
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('📜', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kişisel Doğum Tercihleri',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        'Hekim ve Ebe Ekibine Resmi Tercih Formu',
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

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPink))
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Ortam & Ruh Hali
                        _buildSectionCard(
                          title: '1. Doğum Odası Ortamı ve Destek',
                          emoji: '🕯️',
                          children: [
                            _buildToggleRow('Loş ve Sakin Işıklandırma', _plan.dimLights, (v) => _updatePlan(_plan.copyWith(dimLights: v))),
                            _buildToggleRow('Kişisel Fon Müziği / Ninni', _plan.ambientMusic, (v) => _updatePlan(_plan.copyWith(ambientMusic: v))),
                            _buildToggleRow('Aromaterapi / Lavanta Kokusu', _plan.aromatherapy, (v) => _updatePlan(_plan.copyWith(aromatherapy: v))),
                            _buildToggleRow('Gereksiz Personel Girişinin Önlenmesi', _plan.quietEnvironment, (v) => _updatePlan(_plan.copyWith(quietEnvironment: v))),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // 2. Ağrı Yönetimi
                        _buildSectionCard(
                          title: '2. Doğal Akış & Ağrı Yönetimi',
                          emoji: '💧',
                          children: [
                            _buildToggleRow('Epidural Analjezi Talebi (İhtiyaç Halinde)', _plan.epiduralPreferred, (v) => _updatePlan(_plan.copyWith(epiduralPreferred: v))),
                            _buildToggleRow('Doğal Nefes ve Hareket Serbestisi', _plan.naturalPainRelief, (v) => _updatePlan(_plan.copyWith(naturalPainRelief: v))),
                            _buildToggleRow('Pilates Topu Kullanımı', _plan.birthingBall, (v) => _updatePlan(_plan.copyWith(birthingBall: v))),
                            _buildToggleRow('Ilık Duş / Su Masajı Desteği', _plan.warmWaterShower, (v) => _updatePlan(_plan.copyWith(warmWaterShower: v))),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // 3. Doğum Anı ve Tıbbi İletişim
                        _buildSectionCard(
                          title: '3. Doğum Anı & Karar Paylaşımı',
                          emoji: '🤝',
                          children: [
                            _buildToggleRow('Müdahaleleri (Epizyotomi vb.) Önceden Açıklama', _plan.discussBeforeIntervention, (v) => _updatePlan(_plan.copyWith(discussBeforeIntervention: v))),
                            _buildToggleRow('Spontan ve Zorlamasız Ikınma Rehberliği', _plan.spontaneousPushing, (v) => _updatePlan(_plan.copyWith(spontaneousPushing: v))),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // 4. İlk Dakikalar (Altın Saat)
                        _buildSectionCard(
                          title: '4. İlk Dakikalar (Altın Saat / Golden Hour)',
                          emoji: '👶',
                          children: [
                            _buildToggleRow('Kordonun Geç Klemplenmesi (En az 60 sn)', _plan.delayedCordClamping, (v) => _updatePlan(_plan.copyWith(delayedCordClamping: v))),
                            _buildToggleRow('Babanın / Eşin Kordonu Kesmesi', _plan.partnerCutsCord, (v) => _updatePlan(_plan.copyWith(partnerCutsCord: v))),
                            _buildToggleRow('Doğumdan Hemen Sonra Kesintisiz Ten Tene Temas', _plan.immediateSkinToSkin, (v) => _updatePlan(_plan.copyWith(immediateSkinToSkin: v))),
                            _buildToggleRow('İlk Bebek Banyosunun 24 Saat Ertelenmesi (Vernix Koruması)', _plan.delayNewbornBath24h, (v) => _updatePlan(_plan.copyWith(delayNewbornBath24h: v))),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Özel Dilekler
                        ClayCard(
                          color: AppColors.clayCardSurface,
                          borderRadius: 20,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ek Özel Dilekleriniz & Hekime Not',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _specialWishesController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: 'Örn: Doğum anında fotoğraflarımızın çekilmesini istiyoruz...',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // PDF Çıktı Butonu
                        InkWell(
                          onTap: _isExporting ? null : _exportPdf,
                          borderRadius: BorderRadius.circular(20),
                          child: ClayCard(
                            color: AppColors.accentGold.withValues(alpha: 0.25),
                            borderRadius: 20,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isExporting)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: AppColors.accentGold, strokeWidth: 2),
                                  )
                                else ...[
                                  const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primaryDark, size: 22),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Altın Mühürlü PDF Belgesini İndir / Paylaş',
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 84),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String emoji,
    required List<Widget> children,
  }) {
    return ClayCard(
      color: AppColors.clayCardSurface,
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildToggleRow(String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.primaryPink,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
